<?php

require_once("./db-config.php");

$PORT_HEAD = 5000;
$PORT_TAIL = 5020;

clean_table("room");
clean_table("user");
clean_table("port_table");


for($i = $PORT_HEAD; $i <= $PORT_TAIL; $i++) {
  $result = mysql_query("INSERT INTO port_table SET port_num=$i");
  if($result)
    echo "port $i initial successfully, assigning NULL.<br />";
  else
    echo "port $i initial failed<br />";
}

function clean_table($table) {
  $result = mysql_query("TRUNCATE table $table");
  if($result)
    echo "<br />table: $table, clean successfully.<br />";
  else
    echo "<br />table: $table, clean failed.<br />";
}

?>
