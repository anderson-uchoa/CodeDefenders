<!DOCTYPE html>
<html>

<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

	<!-- App context -->
	<base href="${pageContext.request.contextPath}/">

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<!-- Slick -->
	<link rel="stylesheet" type="text/css" href="//cdn.jsdelivr.net/jquery.slick/1.5.9/slick.css"/>
	<script type="text/javascript" src="//cdn.jsdelivr.net/jquery.slick/1.5.9/slick.min.js"></script>


	<!-- Bootstrap -->
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/gamestyle.css" rel="stylesheet">

	<script src="codemirror/lib/codemirror.js"></script>
	<script src="codemirror/mode/javascript/javascript.js"></script>
	<script src="codemirror/mode/diff/diff.js"></script>
	<link href="codemirror/lib/codemirror.css" rel="stylesheet">


	<script>
		$(document).ready(function() {
			$('.single-item').slick({
				arrows: true,
				infinite: true,
				speed: 300,
				draggable:false
			});
			$('#messages-div').delay(10000).fadeOut();
		});
	</script>
</head>

<body>
<%@ page import="java.util.*" %>
<%@ page import="org.codedefenders.Test" %>
<%@ page import="org.codedefenders.Mutant" %>
<%@ page import="org.codedefenders.Game" %>
<%@ page import="org.codedefenders.Constants" %>
<%@ page import="static org.codedefenders.Game.State.ACTIVE" %>
<% Game game = (Game) session.getAttribute("game"); %>

<nav class="navbar navbar-inverse navbar-fixed-top">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-1">
			</button>
		</div>
		<div class= "collapse navbar-collapse" id="navbar-collapse-1">
			<ul class="nav navbar-nav navbar-left">
				<a class="navbar-brand" href="games">Code Defenders</a>
				<li class="navbar-text">Game ID: <%= game.getId() %></li>
				<li class="navbar-text">ATK: <%= game.getAttackerScore() %> | DEF: <%= game.getDefenderScore() %></li>
				<li class="navbar-text">Round <%= game.getCurrentRound() %> of <%= game.getFinalRound() %></li>
				<% if (game.getAliveMutants().size() == 1) {%>
				<li class="navbar-text">1 Mutant Alive</li>
				<% } else {%>
				<li class="navbar-text"><%= game.getAliveMutants().size() %> Mutants Alive</li>
				<% }%>
				<li class="navbar-text">
					<% if (game.getState().equals(ACTIVE) && game.getActiveRole().equals(Game.Role.DEFENDER)) {%>
						<span class="label label-primary turn-badge">Your turn</span>
					<% } else { %>
						<span class="label label-default turn-badge">Waiting</span>
					<% } %>
				</li>
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<li>
					<p class="navbar-text">
						<span class="glyphicon glyphicon-user" aria-hidden="true"></span>
						<%=request.getSession().getAttribute("username")%>
					</p>
				</li>
				<li><input type="submit" form="logout" class="btn btn-inverse navbar-btn" value="Log Out"/></li>
			</ul>
		</div>
	</div>
</nav>

<form id="logout" action="login" method="post">
	<input type="hidden" name="formType" value="logOut">
</form>

<%
	ArrayList<String> messages = (ArrayList<String>) request.getSession().getAttribute("messages");
	request.getSession().removeAttribute("messages");
	if (messages != null && ! messages.isEmpty()) {
%>
<div class="alert alert-info" id="messages-div">
	<% for (String m : messages) { %>
	<pre><strong><%=m%></strong></pre>
	<% } %>
</div>
<%	} %>

<%
	if (game.getState().equals(Game.State.FINISHED)) {
		String message = Constants.DRAW_MESSAGE;
		if (game.getAttackerScore() > game.getDefenderScore())
			message = Constants.LOSER_MESSAGE;
		else if (game.getDefenderScore() > game.getAttackerScore())
			message = Constants.WINNER_MESSAGE;
%>
<div id="finishedModal" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title">Game Over</h4>
			</div>
			<div class="modal-body">
				<p><%=message%></p>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
			</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div><!-- /.modal -->
<%  } %>

<div class="row-fluid">
	<div class="col-md-6" id="info">
		<h2>Class Under Test</h2>
		<pre><textarea id="sut" name="cut" cols="80" rows="30"><%=game.getCUT().getAsString()%></textarea></pre>
	</div> <!-- col-md6 left -->
	<div class="col-md-6" id="right-top">
		<h2> Write your JUnit test here
			<% if (game.getState().equals(ACTIVE) && game.getActiveRole().equals(Game.Role.DEFENDER)) {%>
			<button type="submit" class="btn btn-primary btn-right" form="def">Defend!</button>
			<%}%>
		</h2>
		<form id="def" action="play" method="post">
			<%
				String testCode;
				String previousTestCode = (String) request.getSession().getAttribute("previousTest");
				request.getSession().removeAttribute("previousTest");
				if (previousTestCode != null) {
					testCode = previousTestCode;
				} else
					testCode = game.getCUT().getTestTemplate();
			%>
			<pre><textarea id="code" name="test" cols="80" rows="30"><%= testCode %></textarea></pre>
			<input type="hidden" name="formType" value="createTest">
		</form>
	</div> <!-- col-md6 right top -->
</div> <!-- row-fluid 1 -->

<div class="row-fluid">
	<div class="col-md-6" id="submitted-div">
		<h2> Submitted JUnit Tests </h2>
		<div class="slider single-item">
			<%
				boolean isTests = false;
				int count = 1;
				for (Test t : game.getTests()) {
					isTests = true;
					String tc = "";
					for (String l : t.getHTMLReadout()) { tc += l + "\n"; }
			%>
			<div><h4>Test <%=count%></h4><pre><textarea id=<%="tc"+count%> name="utest" class="utest" cols="20" rows="10"><%=tc%></textarea></pre></div>
			<%
					count++;
				}
				if (!isTests) {%>
			<div><h2></h2><p> There are currently no tests </p></div>
			<%}
			%>
		</div> <!-- slider single-item -->
	</div> <!-- col-md-6 left bottom -->
	<div class="col-md-6" id="mutants-div">
		<h2>Mutants</h2>
		<!-- Nav tabs -->
		<ul class="nav nav-tabs" role="tablist">
			<li class="active">
				<a href="#mutalivetab" role="tab" data-toggle="tab">Alive</a>
			</li>
			<li>
				<a href="#mutkilledtab" role="tab" data-toggle="tab">Killed</a>
			</li>
		</ul>
		<div class="tab-content">
			<div class="tab-pane fade active in" id="mutalivetab">
				<h3>Alive</h3>
				<table class="table table-hover table-responsive table-paragraphs">
					<%
					ArrayList<Mutant> mutantsAlive = game.getAliveMutants();
					if (! mutantsAlive.isEmpty()) {
						for (Mutant m : mutantsAlive) {
					%>
					<tr>
						<td>
							<h4>Mutant <%= m.getId() %></h4>
						</td>
						<td>
							<% if (game.getLevel().equals(Game.Level.EASY)) { %>
							<a href="#" class="btn btn-default btn-diff" id="btnMut<%=m.getId()%>" data-toggle="modal" data-target="#modalMut<%=m.getId()%>">View Diff</a>
							<% } %>
							<div id="modalMut<%=m.getId()%>" class="modal fade" role="dialog">
								<div class="modal-dialog">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal">&times;</button>
											<h4 class="modal-title">Mutant <%=m.getId()%> - Diff</h4>
										</div>
										<div class="modal-body">
											<pre><textarea id="diff<%=m.getId()%>" class="mutdiff"><%=m.getPatchString()%></textarea></pre>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
						</td>
						<td >
							<% if (game.getState().equals(ACTIVE) && game.getActiveRole().equals(Game.Role.DEFENDER)) {%>
							<form id="equiv" action="play" method="post">
								<input type="hidden" name="formType" value="claimEquivalent">
								<input type="hidden" name="mutantId" value="<%=m.getId()%>">
								<button type="submit" class="btn btn-default btn-right">Claim Equivalent</button>
							</form>
							<%}%>
						</td>
					</tr>
					<tr>
						<td colspan="3">
							<% for (String change :	m.getHTMLReadout()) { %>
							<p><%=change%><p>
								<% } %>
						</td>
					</tr>
					<%
						}
					} else {%>
					<tr class="blank_row">
						<td class="row-borderless" colspan="2">No mutants alive.</td>
					</tr>
					<%}
					%>
				</table>
			</div>
			<div class="tab-pane fade" id="mutkilledtab">
				<h3>Killed</h3>
				<table class="table table-hover table-responsive table-paragraphs">
					<%
					ArrayList<Mutant> mutantsKilled = game.getKilledMutants();
					if (! mutantsKilled.isEmpty()) {
						for (Mutant m : mutantsKilled) {
					%>
					<tr>
						<td><h4>Mutant <%= m.getId() %></h4></td>
						<td>
							<a href="#" class="btn btn-default btn-diff" id="btnMut<%=m.getId()%>" data-toggle="modal" data-target="#modalMut<%=m.getId()%>">View Diff</a>
							<div id="modalMut<%=m.getId()%>" class="modal fade" role="dialog">
								<div class="modal-dialog">
									<!-- Modal content-->
									<div class="modal-content">
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal">&times;</button>
											<h4 class="modal-title">Mutant <%=m.getId()%> - Diff</h4>
										</div>
										<div class="modal-body">
											<pre><textarea id="diff<%=m.getId()%>" class="mutdiff"><%=m.getPatchString()%></textarea></pre>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
										</div>
									</div>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<% for (String change : m.getHTMLReadout()) { %>
							<p><%=change%><p>
								<% } %>
						</td>
					</tr>
					<%
						}
					} else {%>
					<tr class="blank_row">
						<td class="row-borderless" colspan="2">No mutants killed.</td>
					</tr>
					<%}
					%>
				</table>
			</div>
		</div> <!-- tab-content -->
	</div> <!-- col-md-6 right bottom -->
</div>

<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="js/bootstrap.min.js"></script>
<script>
	var editorTest = CodeMirror.fromTextArea(document.getElementById("code"), {
		lineNumbers: true,
		matchBrackets: true
	});
	editorTest.on('beforeChange',function(cm,change) {
		var text = cm.getValue();
		var lines = text.split(/\r|\r\n|\n/);
		var readOnlyLines = [0,1,2,3,4,5,6,7];
		var readOnlyLinesEnd = [lines.length-1,lines.length-2];
		if ( ~readOnlyLines.indexOf(change.from.line) || ~readOnlyLinesEnd.indexOf(change.to.line)) {
			change.cancel();
		}
	});
	editorTest.setSize("100%", 500);
	var editorSUT = CodeMirror.fromTextArea(document.getElementById("sut"), {
		lineNumbers: true,
		matchBrackets: true,
		readOnly: true
	});
	editorSUT.setSize("100%", 500);
	/* Submitted tests */
	var x = document.getElementsByClassName("utest");
	var i;
	for (i = 0; i < x.length; i++) {
		CodeMirror.fromTextArea(x[i], {
			lineNumbers: true,
			matchBrackets: true,
			readOnly: true
		});
	}
	/* Mutants diffs */
	$('.modal').on('shown.bs.modal', function() {
		var codeMirrorContainer = $(this).find(".CodeMirror")[0];
		if (codeMirrorContainer && codeMirrorContainer.CodeMirror) {
			codeMirrorContainer.CodeMirror.refresh();
		} else {
			var editorDiff = CodeMirror.fromTextArea($(this).find('textarea')[0], {
				readOnly: true,
				lineNumbers: false,
				mode: "diff",
				onCursorActivity: null
			});
			editorDiff.setSize("100%", 500);
		}
	});
	$('#finishedModal').modal('show');
</script>
</body>
</html>