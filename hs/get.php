<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
if (!file_exists("highscore.txt")){
  file_put_contents("highscore.txt", "[]");
}
$high = file_get_contents("highscore.txt");
$highjs = json_decode($high);
$limit = 10;
if (isset($_GET['limit']) && is_numeric($_GET['limit'])) {
  $limit = intval($_GET['limit']);
}
$highjs = array_slice($highjs, 0, $limit);
echo json_encode($highjs);
echo "\n";
