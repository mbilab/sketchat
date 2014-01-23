<?php

require_once("./room-admin/db-config.php");


$name = $_POST['name'];
$email = $_POST['email'];
$subject = $_POST['subject'];
$message = $_POST['message'];

if($name != NULL && $email != NULL && $subject != NULL && $message != NULL) {
  $time = date("H-m-d H:i:s");
  mysql_query("INSERT INTO contact SET id=0, time='$time', name='$name', email='$email', subject='$subject', message='$message'");
  header("location: ./thanks.html");
}
else
  header("location: ./contact.html");


?>
