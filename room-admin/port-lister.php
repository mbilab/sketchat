<?php

require_once("./db_config.php");


for($i = 1000; $i <= 1100; $i++) {
  $result = mysql_query("INSERT INTO port_table SET port_num=$i");
  if($result)
    echo "ok";
  else
    echo "not ok";
}

?>
