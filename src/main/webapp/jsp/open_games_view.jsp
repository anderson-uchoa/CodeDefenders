<% String pageTitle="Open Games"; %>
<%@ include file="/jsp/header.jsp" %>
<div class="full-width">
	<h2>Duels</h2>
<table class="table table-hover table-responsive table-paragraphs">
	<tr>
		<th class="col-sm-2">Game No.</th>
		<th class="col-sm-2">Attacker</th>
		<th class="col-sm-2">Defender</th>
		<th class="col-sm-2">Game State</th>
		<th class="col-sm-2">Class Under Test</th>
		<th class="col-sm-2">Level</th>
		<th class="col-sm-2"></th>
	</tr>


	<%
		boolean isGames = false;
		String atkName;
		String defName;
		int uid = (Integer)request.getSession().getAttribute("uid");
		int atkId;
		int defId;
		for (Game g : DatabaseAccess.getOpenGames()) {
			isGames = true;
			atkName = null;
			defName = null;

			atkId = g.getAttackerId();
			defId = g.getDefenderId();

			if ((atkId == uid)||(defId == uid)) {continue;}

			if (atkId != 0) {atkName = DatabaseAccess.getUserForKey("User_ID", atkId).username;}
			if (defId != 0) {defName = DatabaseAccess.getUserForKey("User_ID", defId).username;}

			if ((atkName != null)&&(defName != null)) {continue;}

			if (atkName == null) {atkName = "Empty";}
			if (defName == null) {defName = "Empty";}
	%>

	<tr>
		<td class="col-sm-2"><%= g.getId() %></td>
		<td class="col-sm-2"><%= atkName %></td>
		<td class="col-sm-2"><%= defName %></td>
		<td class="col-sm-2"><%= g.getState() %></td>
		<td class="col-sm-2"><%= g.getCUT().getAlias() %></td>
		<td class="col-sm-2"><%= g.getLevel().name() %></td>
		<td class="col-sm-2">
			<form id="view" action="games" method="post">
				<input type="hidden" name="formType" value="joinGame">
				<input type="hidden" name="game" value=<%=g.getId()%>>
				<input type="submit" class="btn btn-primary" value="Join Game">
			</form>
		</td>
	</tr>

	<%
		}
		if (!isGames) {%>
	<tr><td colspan="8"> There are currently no open games </td></tr>
	<%}
	%>
</table>
	<a href="/games/create">Create Duel</a>
	<hr />
	<h2>Battlegrounds</h2>
	<table class="table table-hover table-responsive table-paragraphs"><tr><th>Game ID</th><th>Owner</th><th>
		Price
	</th><th>Level</th><th>Actions</th></tr>
	<%
		ArrayList<MultiplayerGame> mgames = DatabaseAccess.getMultiplayerGamesExcludingUser(uid);
		if (mgames.isEmpty()) {
	%>
	<tr><td colspan="5"> There are currently no open games. </td></tr>
	<%
	} else {
	%>
		<%
			for (MultiplayerGame g : mgames) {
		%>
		<tr>
			<td class="col-sm-2"><%= g.getId() %></td>
			<td class="col-sm-2"><%= DatabaseAccess.getUserForKey("User_ID", g.getCreatorId()).username %></td>
			<td class="col-sm-2"><%= g.getPrice() %></td>
			<td class="col-sm-2"><%= g.getLevel().name() %></td>
			<td class="col-sm-2">
				<a href="multiplayer/games?attacker=1&id=<%= g.getId() %>">Attack</a>
				<a href="multiplayer/games?defender=1&id=<%= g.getId() %>">Defend</a>
			</td>
		</tr>
		<%
				} // for (MultiplayerGame g : games) %>
	 <% } // if (games.isEmpty())
		%>
	</table>

	<a href="/multiplayer/games/create">Create Battleground</a>

</div>
<%@ include file="/jsp/footer.jsp" %>
