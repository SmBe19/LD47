<?php
header("Access-Control-Allow-Origin: *");
function sanitize($name){
  return preg_replace('/[^A-Za-z0-9\-_ ]/', '', $name);
}
function cmp($a, $b){
  return $a->score - $b->score;
}
if (isset($_GET['username']) && isset($_GET['score']) && is_numeric($_GET['score']) && isset($_GET['magic'])) {
  if (!file_exists("secret.txt")) {
    die("No secret");
  }
  $secret = trim(file_get_contents("secret.txt"));
  $username = sanitize($_GET['username']);
  $score = intval($_GET['score']);
  $magic = $_GET['magic'];
  $scorestr = strval($score)."|".$username;
  if ($magic == md5($secret."|".strval(strlen($scorestr))."|".$scorestr)){
    if (!file_exists("highscore.txt")){
      file_put_contents("highscore.txt", "[]");
    }
    $highfile = file_get_contents("highscore.txt");
    $high = json_decode($highfile);
    $high[] = (object) array(name => $username, score => $score);
    usort($high, "cmp");
    $high = array_slice($high, 0, 100);
    file_put_contents("highscore.txt", json_encode($high));
    echo "Thx";
  }
}
