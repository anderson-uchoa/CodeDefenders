<% String pageTitle="In Game"; %>
<%@ page import="org.codedefenders.multiplayer.MultiplayerGame" %>
<%@ page import="org.codedefenders.*" %>
<%@ page import="org.codedefenders.util.DatabaseAccess" %>
<%@ page import="org.codedefenders.events.Event" %>
<%@ page import="org.codedefenders.events.EventType" %>
<%@ page import="org.codedefenders.events.EventStatus" %>
<%@ page import="java.sql.Timestamp" %>
<%
    // Get their user id from the session.
    int uid = ((Integer) session.getAttribute("uid")).intValue();
    int gameId = 0;
    try {
        try {
            gameId = Integer.parseInt(request.getParameter("id"));
            session.setAttribute("mpGameId", new Integer(gameId));
        } catch (NumberFormatException e) {
            gameId = ((Integer) session.getAttribute("mpGameId")).intValue();
        }
    } catch (Exception e2){
        response.sendRedirect("games/user");
    }
    MultiplayerGame mg = DatabaseAccess.getMultiplayerGame(gameId);
    if (mg == null){
        response.sendRedirect("games/user");
    }
    boolean renderMutants = true;

    HashMap<Integer, ArrayList<Test>> linesCovered = new HashMap<Integer, ArrayList<Test>>();

    String codeDivName = "cut-div";

    Role role = mg.getRole(uid);

    if ((mg.getState().equals(GameState.CREATED) || mg.getState().equals(GameState.FINISHED)) && (!role.equals(Role.CREATOR))) {
        response.sendRedirect("/games/user");
    }

    List<Test> tests = mg.getTests(true); // get executable defenders' tests

    // compute line coverage information
    for (Test t : tests) {
        for (Integer lc : t.getLineCoverage().getLinesCovered()) {
            if (!linesCovered.containsKey(lc)) {
                linesCovered.put(lc, new ArrayList<Test>());
            }
            linesCovered.get(lc).add(t);
        }
    }

%>
<%@ include file="/jsp/multiplayer/header_game.jsp" %>
<%
    messages = new ArrayList<String>();
    session.setAttribute("messages", messages);

    int playerId = DatabaseAccess.getPlayerIdForMultiplayerGame(uid, gameId);
    List<Mutant> mutantsAlive = mg.getAliveMutants();

    List<Mutant> mutantsPending = mg.getMutantsMarkedEquivalentPending();

    if (role.equals(Role.DEFENDER) && request.getParameter("equivLine") != null &&
            (mg.getState().equals(GameState.ACTIVE) || mg.getState().equals(GameState.GRACE_ONE))){
        try {
            int equivLine = Integer.parseInt(request.getParameter("equivLine"));

            int nClaimed = 0;
            for (Mutant m : mutantsAlive) {
                if (m.getLines().contains(equivLine)) {
                    m.setEquivalent(Mutant.Equivalence.PENDING_TEST);
                    m.update();

                    User mutantOwner = DatabaseAccess.getUserFromPlayer(m.getPlayerId());

                    Event notifEquivFlag = new Event(-1, mg.getId(),
                            mutantOwner.getId(),
                            "One or more of your mutants is flagged equivalent.",
                            EventType.DEFENDER_MUTANT_EQUIVALENT,
                            EventStatus.NEW,
                            new Timestamp(System.currentTimeMillis()));
                    notifEquivFlag.insert();

                    DatabaseAccess.insertEquivalence(m, playerId);
                    nClaimed++;
                }
            }

            Event notifMutant = new Event(-1, mg.getId(),
                    uid,
                    DatabaseAccess.getUser(uid)
                            .getUsername() + " flagged " + nClaimed +
                            " mutant" + (nClaimed == 1? "" : "s") +
                            " as equivalent.",
                    EventType.DEFENDER_MUTANT_CLAIMED_EQUIVALENT, EventStatus.GAME,
                    new Timestamp(System.currentTimeMillis()));

            notifMutant.insert();

            messages.add(String.format("Flagged %d mutant%s as equivalent", nClaimed, (nClaimed == 1 ? "" : 's')));

            response.sendRedirect("play");

        } catch (NumberFormatException e){}

    } else if (role.equals(Role.ATTACKER) && request.getParameter("acceptEquiv") != null){
        try {
            int mutId = Integer.parseInt(request.getParameter("acceptEquiv"));

            Mutant equiv = null;

            for (Mutant m : mutantsPending){
                if (m.getPlayerId() == playerId &&  m.getId() == mutId){
                    m.kill(Mutant.Equivalence.DECLARED_YES);
                    DatabaseAccess.increasePlayerPoints(1, DatabaseAccess.getEquivalentDefenderId(m));
                    messages.add(Constants.MUTANT_ACCEPTED_EQUIVALENT_MESSAGE);

                    User eventUser = DatabaseAccess.getUser(uid);

                    Event notifEquiv = new Event(-1, mg.getId(),
                            uid,
                            eventUser.getUsername() +
                                    " accepts that their mutant is equivalent.",
                            EventType.DEFENDER_MUTANT_EQUIVALENT, EventStatus.GAME,
                            new Timestamp(System.currentTimeMillis()));
                    notifEquiv.insert();

                    response.sendRedirect("play");
                }
            }
        } catch (NumberFormatException e){}
    }

    List<Mutant> mutantsEquiv =  mg.getMutantsMarkedEquivalent();
    Map<Integer, List<Mutant>> mutantLines = new HashMap<>();
    Map<Integer, List<Mutant>> mutantKilledLines = new HashMap<>();


    // Ensure that mutants marked equivalent are drawn to display
    mutantsAlive.addAll(mutantsEquiv);

    for (Mutant m : mutantsAlive) {
        for (int line : m.getLines()){
            if (!mutantLines.containsKey(line)){
                mutantLines.put(line, new ArrayList<Mutant>());
            }

            mutantLines.get(line).add(m);

        }
    }

    for (Mutant m : mutantsPending){
        mutantsAlive.add(m);
    }


    List<Mutant> mutantsKilled = mg.getKilledMutants();

    for (Mutant m : mutantsKilled) {
        for (int line : m.getLines()){
            if (!mutantKilledLines.containsKey(line)){
                mutantKilledLines.put(line, new ArrayList<Mutant>());
            }

            mutantKilledLines.get(line).add(m);

        }
    }
    //ArrayList<String> messages = new ArrayList<String>();
%>

    <%@ include file="/jsp/multiplayer/game_scoreboard.jsp" %>
<div class="crow fly no-gutter up">
    <% switch (role){
        case ATTACKER:
            %><%@ include file="/jsp/multiplayer/attacker_view.jsp" %><%
            break;
        case DEFENDER:
            %><%@ include file="/jsp/multiplayer/defender_view.jsp" %><%
            break;
        case CREATOR:
            %><%@ include file="/jsp/multiplayer/creator_view.jsp" %><%
            break;
        default:
            if (request.getParameter("defender") != null){
                mg.addPlayer(uid, Role.DEFENDER);
            } else if (request.getParameter("attacker") != null){
                mg.addPlayer(uid, Role.ATTACKER);
            } else {
                response.sendRedirect("multiplayer/games/user");
                break;
            }
            %>
            <p>Joining Game...</p>
<%
            response.setIntHeader("Refresh", 1);
            break;
    }
%>
    </div>
<script>
<%@ include file="/jsp/multiplayer/game_highlighting.jsp" %>
</script>
<%@ include file="/jsp/game_notifications.jsp"%>
<%@ include file="/jsp/multiplayer/footer_game.jsp" %>