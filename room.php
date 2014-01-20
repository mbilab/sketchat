<?php

require_once("./room-admin/db-config.php");

$url = $_SERVER['REQUEST_URI'];
$array = explode("?", $url, 2);
$room_key = $array[1];

if($room_key != NULL) {
  $_SESSION['room-key'] = $room_key;
  $result = mysql_query("SELECT * FROM room WHERE access_key='$room_key' AND over_time is NULL");
  $num = mysql_num_rows($result);
  if($num == 1) {
    $user_name = $_SESSION['user-name'];
    if($user_name != NULL) {
      $row = mysql_fetch_assoc($result);
      $room_id = $row['id'];
      $result = mysql_query("SELECT * FROM user WHERE name='$user_name' AND room=$room_id");
      $num = mysql_num_rows($result);
      if($num != 1) {
	$_SESSION['user-name'] = NULL;
	header("location: ./ready-user.php?$room_key");
      }
    }
    else
      header("location: ./ready-user.php?$room_key");
  }
  else
    header("location: ./");
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
    <link href="./css/room.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="./gridster/jquery.gridster.css">
    <link rel="stylesheet" type="text/css" href="./gridster/demo.css">
    <link rel="stylesheet" type="text/css" href="./gridster/size.css">

    <style> video { width: 100%; height: 100%; } </style>

  </head>

  <body>

    <div id="header">
      <nav id="navbar" class="navbar navbar-default" role="navigation">
	<!-- Brand and toggle get grouped for better mobile display -->
	<div class="navbar-header">
	  <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
	    <span class="sr-only">Toggle navigation</span>
	    <span class="icon-bar"></span>
	    <span class="icon-bar"></span>
	    <span class="icon-bar"></span>
	  </button>
	  <a class="navbar-brand" href="./" style="font-size: 30px; padding-left: 0px; letter-spacing:1px;"><img src="./img/index/sketchat-logo.png" height="35"/> Sketchat</a>
	</div>
	<!-- Collect the nav links, forms, and other content for toggling -->
	<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
	  <ul class="nav navbar-nav navbar-right">
	    <li class="dropdown">
	      <button class="dropdown-toggle btn btn-default" data-toggle="dropdown" style="margin-top: 8px; margin-right: 10px;">Width: <b>Normal</b> <b class="caret"></b></button>
	      <ul class="dropdown-menu">
		<li><a id='thin' href="#"><svg height='20' width='20'><circle cx="10" cy="15" r="1" stroke='#999' stroke-width="1" fill="black" /></svg> Thin </a></li>
		<li><a id='normal' href="#"><svg height='20' width='20'><circle cx="10" cy="15" r="3" stroke='#999' stroke-width="1" fill="black" /></svg> Normal</a></li>
		<li><a id='fat' href="#"><svg height='20' width='20'><circle cx="10" cy="14" r="5" stroke='#999' stroke-width="1" fill="black" /></svg> Fat</a></li>
	      </ul>
	    </li>
	    <li class="dropdown">
	      <button class="dropdown-toggle btn btn-default" data-toggle="dropdown" style="margin-top: 8px; margin-right: 10px;">Color <svg height='14' width='14'><circle cx="5" cy="9" r="5" stroke='#999' stroke-width="1" fill="black" /></svg> <b class="caret"></b></button>
	      <ul class="dropdown-menu">
		<li><a id='red' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="red" /></svg> Red </a></li>
		<li><a id='green' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="green" /></svg> Green</a></li>
		<li><a id='yellow' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="yellow" /></svg> Yellow</a></li>
		<li><a id='black' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="black" /></svg> Black</a></li>
	        <li><a id='DarkBlue' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="DarkBlue" /></svg> DarkBlue</a></li>
		<li><a id='DarkOrange' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="DarkOrange" /></svg> DarkOrange</a></li> 
 		<li><a id='Violet' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="Violet" /></svg> Violet</a></li> 
		<li><a id='DarkMagenta' href="#"><svg height='20' width='20'><circle cx="10" cy="13" r="7" stroke='#999' stroke-width="1" fill="DarkMagenta" /></svg> DarkMagenta</a></li> 
	      </ul>
	    </li>
	    <li id="clean-button" type="button" class="btn btn-success" style="margin-top: 8px;">Clean drawing board</li>
	  </ul>
	</div><!-- /.navbar-collapse -->
      </nav>
    </div>


    <div class="gridster ready" id="video-conference">
      <ul id="remotes">
	<!--li data-row="1" data-col="1" data-sizex="3" data-sizey="4" class="gs-w"><video id="localVideo"></video></li-->
      </ul>
    </div>

    <section id="sketch-board">
      <div id='draw' style='position: relative; top: 56px;'>
        <canvas id='paper' height= "2000" width= "3000"></canvas>
      </div>
    </section>

    <script src="./js/jquery.min.js"></script>
    <script src="./js/bootstrap.min.js"></script>
    <!--script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script-->
    <script src="./simplewebrtc/socket.io.js"></script>
    <script src="./simplewebrtc/simplewebrtc.bundle.js"></script>
    <script src="./simplewebrtc/main.js"></script>
    <script src="./gridster/jquery.gridster.js"></script>
    <!--script src='./node-drawing-game/assets/js/script.js'></script-->
    <script src="./paper/js/paper.js"></script>
    <script type='text/paperscript' src='./paper/js/drawLine.js' canvas='paper'></script>
    <script src="./paper/js/socket.io.js"></script>

<script>

var isMobile = {
  Android: function() { return navigator.userAgent.match(/Android/i); },
    BlackBerry: function() { return navigator.userAgent.match(/BlackBerry/i); },
    iOS: function() { return navigator.userAgent.match(/iPhone|iPad|iPod/i); },
    Opera: function() { return navigator.userAgent.match(/Opera Mini/i); },
    Windows: function() { return navigator.userAgent.match(/IEMobile/i); },
    any: function() { return (isMobile.Android() || isMobile.BlackBerry() || isMobile.iOS() || isMobile.Opera() || isMobile.Windows()); }
};

if(isMobile.iOS()) { $("#video-conference").remove(); }

var gridster;
var width = window.innerWidth;
var height = window.innerHeight;

setInterval(function() { 
  width = window.innerWidth;
  height = window.innerHeight; 
  //Set block size
  $("#sketch-board").css("height", (height) + "px");
  $("#sketch-board").css("width", (width) + "px");
  $(".gridster ul").css("width", (width) + "px");

}, 2000);

//$("#sketch-board").css("top", "56px");

window.onbeforeunload = function() {
  var ary = location.search.substr(1).split("?", 2);
  var room_key = ary[0];
  var user_name = ary[1];
  $.ajax({
    url: './room-admin/user-leave.php?room-key=' + room_key + '&user-name=' + user_name,
      type: 'GET',
      async: false,
      timeout: 4000,
      dataType: 'text'
  });
};
window.onunload = function() {
  var ary = location.search.substr(1).split("?", 2);
  var room_key = ary[0];
  var user_name = ary[1];
  $.ajax({
    url: './room-admin/user-leave.php',
      type: 'GET',
      async: false,
      timeout: 4000,
      dataType: 'text'
  });
};

$(function(){

  gridster = $(".gridster ul").gridster({
    widget_base_dimensions: [100, 55],
      widget_margins: [5, 5],
      helper: 'clone',
      resize: {
	enabled: true
      }
  }).data('gridster');

  $('.js-resize-random').on('click', function() {
    gridster.resize_widget(gridster.$widgets.eq(getRandomInt(0, 9)),
      getRandomInt(1, 4), getRandomInt(1, 4))
  });

});

</script>
  </body>
</html>

