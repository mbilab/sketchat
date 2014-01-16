<?php

require_once("./db-config.php");

$room_key = $_GET['room-key'];
$user_name = $_GET['user-name'];
$session_id = $_GET['session_id'];

if($room_key != NULL && $user_name != NULL && $session_id != NULL) {
  $result = mysql_query("SELECT * FROM room WHERE access_key='$room_key'");
  $num = mysql_num_rows($result);
  if($num == 1) {
    $row = mysql_fetch_assoc($result);
    $room_id = $row['id'];
    $result = mysql_query("SELECT * FROM user WHERE room=$room_id AND name='$user_name' AND leave_time is NULL");
    $num = mysql_num_rows($result);
    if($num == 1) {
      $row = mysql_fetch_assoc($result);
      $user_id = $row['id'];
      mysql_query("UPDATE user SET session_id='$session_id' WHERE id=$user_id");
    }
  }
}

?>
