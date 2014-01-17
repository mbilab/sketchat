<?php

require_once("./room-admin/db-config.php");

$url = $_SERVER['REQUEST_URI'];
$array = explode("?", $url, 3);
$key = $array[1];
$name = $array[2];

if($key != NULL) {
  $result = mysql_query("SELECT * FROM room WHERE access_key='$key' AND over_time is NULL");
  $room_num = mysql_num_rows($result);
  if($room_num == 1) {
    if($name != NULL) {
      $result = mysql_query("SELECT * FROM user WHERE name='$name' AND leave_time is NULL");
      $user_num = mysql_num_rows($result);
      if($user_num == 1) {
	$row = mysql_fetch_assoc($result);
	if(!$row['online']) {
	  mysql_query("UPDATE user SET online=1 WHERE id={$row['id']}");
	}
	else 
	  header("location: ./ready-user.php?$key");
      }
      else
	header("location: ./");
    }
    else
      header("location: ./ready-user.php?$key");
  }
  else if($room_num == 0)
    header("location: ./");
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
	  <a class="navbar-brand" href="./" target="_blank" style="font-size: 30px; padding-left: 0px; letter-spacing:1px;">Sketchat</a>
	</div>
	<!-- Collect the nav links, forms, and other content for toggling -->
	<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
	  <ul class="nav navbar-nav navbar-right">
	    <button id="clean-button" type="button" class="btn btn-success" style="margin-top: 8px;">Clean drawing board</button>
	    <!--li><a href="./about.html" data-loc="about" class="menu-list">About</a></li>
	  <li><a href="./feature.html" data-loc="feature" class="menu-list">Feature</a></li-->
	  </ul>
	</div><!-- /.navbar-collapse -->
      </nav>
    </div>


    <div class="gridster ready" id="video-conference">
      <ul id="remotes">
	<li data-row="1" data-col="1" data-sizex="3" data-sizey="4" class="gs-w"><video id="localVideo"></video></li>
      </ul>
    </div>


    <div id='cursors'></div>
    <!--hgroup id="instructions">		
      <h1>Draw anywhere!</h1>
      <h2>You will see everyone else who's doing the same.</h2>
      <h3>Tip: if the stage gets dirty, simply reload the page</h3>
    </hgroup-->
    <section id="sketch-board">
      <div id='draw' style='position: relative; top: 56px;'>
	<canvas id='paper' height= "1000" width= "1900">
	</canvas>
      </div>
    </section>

    <script src="./js/jquery.min.js"></script>
    <script src="./js/bootstrap.min.js"></script>
    <!--script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script-->
    <script src="./simplewebrtc/socket.io.js"></script>
    <script src="./simplewebrtc/simplewebrtc.bundle.js"></script>
    <script src="./simplewebrtc/main.js"></script>
    <script src="./gridster/jquery.gridster.js"></script>
    <script src='./node-drawing-game/assets/js/script.js'></script>

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

//Set block size
$("#sketch-board").css("height", (height) + "px");
$("#sketch-board").css("width", (width) + "px");
$(".gridster ul").css("width", (width) + "px");
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
    url: './room-admin/user-leave.php?room-key=' + room_key + '&user-name=' + user_name,
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

