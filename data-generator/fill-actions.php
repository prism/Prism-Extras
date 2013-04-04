<?php

error_reporting(E_ALL);
ini_set('display_errors', true);

// Query all known users, add to white list file
//$link = mysql_connect('127.0.0.1', 'darkhelmet_mc', 'UwACYTN9pDk7LTtMnpsz');
$link = mysql_connect('127.0.0.1', 'root', '');
$db_selected = mysql_select_db('minecraft', $link);



for( $i = 0; $i <= 10000; $i++ ){
    $sql = "INSERT INTO `minecraft`.`prism_actions` (
`action_type` ,
`player` ,
`world` ,
`x` ,
`y` ,
`z` ,
`block_id` ,
`block_subid` ,
`old_block_id` ,
`old_block_subid` ,
`data`
)
VALUES ('block-break', 'viveleroi', 'world', '1', '2', '3', '1', '0', '0', '0', NULL);";
    mysql_query($sql);
}