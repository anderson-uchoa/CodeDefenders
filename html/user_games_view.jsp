<html>

<head>
	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <!-- Bootstrap -->
    <link href="${pageContext.request.contextPath}/html/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/html/css/gamestyle.css" rel="stylesheet">
</head>

<body>

  <%@ page import="gammut.*,java.io.*" %>
	<nav class="navbar navbar-inverse navbar-fixed-top">
  		<div class="container-fluid">
    		<div class="navbar-header">
      			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-1">
      			</button>
    		</div>
      		<div class= "collapse navbar-collapse" id="navbar-collapse-1">
          		<ul class="nav navbar-nav">
            		<a class="navbar-brand" href="/gammut/intro">GamMut</a>
          		</ul>
      		</div>
   		</div>
	</nav>

  <h2> My Games </h2>
    <table class="table table-hover table-responsive table-paragraphs">

    <% 
    boolean isGames = false;
    int uid = (Integer)request.getSession().getAttribute("uid");
    for (Game g : GameSelectionManager.getGamesForUser(uid)) { 
      isGames = true;
    %>

      <tr>
        <td class="col-sm-2"><%= "Game ID:" + g.getId() %></td>
      </tr>

    <%
    } 
    if (!isGames) {%>
      <p> You are not currently in any games </p>
    <%}
    %>
    </table>

	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="js/bootstrap.min.js"></script>
</body>
</html>