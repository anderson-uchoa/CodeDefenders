<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

    <!-- Bootstrap -->
    <link href="${pageContext.request.contextPath}/html/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

	<%@ page import="gammut.*,java.io.*" %>
	<% GameState gs = (GameState) getServletContext().getAttribute("gammut.gamestate"); %>

	<div id="statbar">
		<p>Scores are currently Attacker: <%= gs.getScore(0) %>, Defender: <%= gs.getScore(1) %> </p>
	    <p>Round is: <%= gs.getRound() %> </p>
	    <p>There are <%= gs.getAliveMutants().size() %> mutants alive </p>
	</div>

	<%
	    InputStream resourceContent = getServletContext().getResourceAsStream("/WEB-INF/resources/Book.java");
	    String line;
	    String source = "";
	    BufferedReader is = new BufferedReader(new InputStreamReader(resourceContent));
	    while((line = is.readLine()) != null) {source+=line+"\n";}
	%>
	<textarea name="source" cols="100" rows="50" readonly><%=source%></textarea>

	<form action="/gammut/defender" method="post">

		<input type="hidden" name="user" value="1">
        <textarea name="test" cols="100" rows="30">
import org.junit.*;
import static org.junit.Assert.*;

public class TestBook {
@Test
public void test() {

}
}</textarea>

	    <br>
	    <input type="submit" value="Defend!">
    </form>

	<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="js/bootstrap.min.js"></script>
</body>
</html>