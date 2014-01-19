<?php

require_once("./db-config.php");
session_start();

$room_key = $_GET['room-key'];
$user_name = $_GET['user-name'];

if($room_key != NULL && $user_name != NULL) {

  $result = mysql_query("SELECT * FROM room WHERE access_key='$room_key'");
  $row = mysql_fetch_assoc($result);
  $room_id = $row['id'];

  $result = mysql_query("SELECT * FROM user WHERE name='$user_name' AND room=$room_id");
  $num = mysql_num_rows($result);
  if($num == 0) {
    $time = date("H-m-d H:i:s");
    $user_id = get_table_row_num('user') + 1;    
    $ip = get_client_ip();
    $device = $_SERVER['HTTP_USER_AGENT'];
    mysql_query("INSERT INTO user SET id=$user_id, name='$user_name', ip='$ip', device='$device', room=$room_id");
    $_SESSION['room-key'] = $room_key;
    $_SESSION['user-name'] = $user_name;
    header("location: ../room.php?$room_key");
  }
  else if($num ==1) {
    echo "<script>alert('This room name is using now, Please rename an another name.'); location.href='../'</script>";
  }
  else {
    //Unexpected Error
    header("location: ../");
  }
}
else
  header("location: ../");


function get_table_row_num($table_name) {
  $result = mysql_query("SELECT * FROM $table_name");
  return mysql_num_rows($result);
}

function get_client_ip() {
  $ipaddress = '';
  if ($_SERVER['HTTP_CLIENT_IP'])
    $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
  else if($_SERVER['HTTP_X_FORWARDED_FOR'])
    $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
  else if($_SERVER['HTTP_X_FORWARDED'])
    $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
  else if($_SERVER['HTTP_FORWARDED_FOR'])
    $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
  else if($_SERVER['HTTP_FORWARDED'])
    $ipaddress = $_SERVER['HTTP_FORWARDED'];
  else if($_SERVER['REMOTE_ADDR'])
    $ipaddress = $_SERVER['REMOTE_ADDR'];
  else
    $ipaddress = 'UNKNOWN';

  return $ipaddress; 
}

