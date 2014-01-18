<?php

require_once("./room-admin/db-config.php");

$url = $_SERVER['REQUEST_URI'];
$array = explode("?", $url, 3);
$key = $array[1];
$name = $array[2];

if($name == NULL) {
  $result = mysql_query("SELECT * FROM room WHERE access_key='$key' AND over_time is NULL");
  $num = mysql_num_rows($result);
  if($num != 1)
    header("location: ./");
  else {
    $row = mysql_fetch_assoc($result);
    $result = mysql_query("SELECT * FROM user WHERE id={$row['creater']}");
    $row2 = mysql_fetch_assoc($result);
    $creater = $row2['name'];
  }
}
else
  header("location: ./");

?>

<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Sketchat</title>

    <!-- Bootstrap core CSS -->
    <link href="./css/bootstrap.css" rel="stylesheet">
    <link href="./css/style.css" rel="stylesheet">
    <link href="./css/ready-creater.css" rel="stylesheet">

  </head>

  <body>

    <div id="header">
      <nav id="navbar" class="navbar navbar-default" role="navigation">
	<div class="container">
	  <!-- Brand and toggle get grouped for better mobile display -->
	  <div class="navbar-header">
	    <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
	      <span class="sr-only">Toggle navigation</span>
	      <span class="icon-bar"></span>
	      <span class="icon-bar"></span>
	      <span class="icon-bar"></span>
	    </button>
	    <a class="navbar-brand" href="./" style="font-size: 30px; padding-left: 0px; letter-spacing:1px;">Sketchat</a>
	  </div>
	  <!-- Collect the nav links, forms, and other content for toggling -->
	  <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
	    <ul class="nav navbar-nav navbar-right">
	      <li><a href="./about.html" target="_blank" data-loc="about" class="menu-list">About</a></li>
	      <li><a href="./features.html" target="_blank" data-loc="features" class="menu-list">Features</a></li>
	    </ul>
	  </div><!-- /.navbar-collapse -->
	</div>
      </nav>
    </div>

    <section class="scroll-panel" id="welcome">
      <div class="container">

	<div class="jumbotron">
	  <div class="row">

	    <div class="jumbotron text-centered">
	      <div class="welcome-container">
		<h2 class="block-title">Welcome entering the sketchat room!</h2>
		<div class="url-container col-md-6 col-md-offset-3">
		  <p>Room name: <?php echo $row['name']?></p>
		  <p>Creater: <?php echo $creater?></p>
		  <div class="col-md-6 col-md-offset-3">
		    <form action="./room-admin/user-enter.php" method="get">
		      <input id="url-text" type="text" name="user-name" class="form-control sign-form text-centered" placeholder="Enter your name to join it."/>
		      <input type="hidden" name="room-key" value="<?php echo $key?>"/>
		      <button id="start-button" class="btn btn-lg btn-primary btn-embossed start-button">Enter the room</button>
		    </form>
		  </div>
		</div>
	      </div>
	    </div>

	  </div>
	</div>

      </div>
    </section>

    <footer>
      <nav role="navigation">
	<div class="container">
	  <p class="copyright">&copy; 2013 Sketchat &nbsp;All rights reserved.</p>
	  <ul class="site-footer-links">
	    <li class="footer-link"><a href="./about.html">About</a></li>
	    <li class="footer-link"><a href="./about.html">Privacy</a></li>
	    <li class="footer-link"><a href="./contact.html">Contact</a></li>
	  </ul>
	</div>
      </nav>
    </footer>

    <script src="./js/jquery.min.js"></script>
    <script src="./js/bootstrap.min.js"></script>
    <script>
      var width = window.innerWidth;
      var height = window.innerHeight;
      var url_parameter = location.search.substr(1);
      var access_key = url_parameter.split("?");

      $('#welcome').css('width', width + 'px');
      $('#welcome').css('height', (height) + 'px');

    </script>
  </body>
</html>

