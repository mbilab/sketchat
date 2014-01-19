<?php

require_once("./db-config.php");

session_start();
$room_key = $_SESSION['room-key'];
$user_name = $_SESSION['user-name'];

if($room_key != NULL && $user_name != NULL) {
  $result = mysql_query("SELECT * FROM room WHERE access_key='$room_key'");
  $num = mysql_num_rows($result);
  if($num == 1) {
    $row = mysql_fetch_assoc($result);
    $room_id = $row['id'];
    $room_port = $row['port'];
    $result = mysql_query("SELECT * FROM user WHERE room=$room_id AND name='$user_name'");
    $num = mysql_num_rows($result);
    if($num == 1) {
      $row = mysql_fetch_assoc($result);
      $user_id = $row['id'];
      mysql_query("UPDATE user SET online=1 WHERE id=$user_id");
    }
    else
      header("location: ../");
  }
  else
    header("location: ../");
}
else
  header("location: ../");

?>
