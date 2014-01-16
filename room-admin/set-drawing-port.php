<?php

require_once("./db-config.php");

$room_key = $_GET['room-key'];

if($room_key != NULL) {
  $result = mysql_query("SELECT * FROM room WHERE access_key='$room_key'");
  $row = mysql_fetch_assoc($result);
  echo $row['port'];
}

?>
