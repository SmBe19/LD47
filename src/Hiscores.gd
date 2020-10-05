extends Control


var submitted = false
var score_int = 0

func set_score(score):
	score_int = round(score*10)
	$ScoreLabel.text = "You defeated the bear in %.1f seconds!" % (score_int/10)

func submit(username):
	print("submit!")
	if submitted:
		return
	if len(username) == 0:
		$UsernameLabel.text = "Please enter a username."
		return
	submit_highscore(username, score_int)
	submitted = true
	
	$Username.visible = false
	$Username.editable = false
	
	$UsernameLabel.text = "Submitting..."


func _get_submit_response(result, response_code, headers, body):
	if response_code == 200:
		$UsernameLabel.text = "Thank you for playing!"
	else:
		$UsernameLabel.text = "Error occurred while submitting"
		
	update_hiscores()


func _ready():
	set_score(Globals.score)
	update_hiscores()
	$Username.grab_focus()
	$Username.caret_position = len($Username.text)
	pass

func update_hiscores():
	$HTTPRequestGetHS.request("https://ludumdare.games.smeanox.com/LD47/hs/get.php")

func _get_highscore_response(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	for i in range($Hiscores.get_child_count()):
		if i < len(json.result):
			var username = json.result[i]["name"]
			var score = json.result[i]["score"] * 0.1
			$Hiscores.get_child(i).get_node("Name").text = username
			$Hiscores.get_child(i).get_node("Score").text = "%.1fs"%(score)
		else:
			$Hiscores.get_child(i).get_node("Name").text = ""
			$Hiscores.get_child(i).get_node("Score").text = ""
		

func submit_highscore(username: String, score: int):
	var scorestr = str(score) + "|" + username
	var pre_magic = Secret.secret + "|" + str(len(scorestr)) + "|" + scorestr
	var magic = pre_magic.md5_text()
	$HTTPRequestSubmitHS.request("https://ludumdare.games.smeanox.com/LD47/hs/submit.php?username=" + username.percent_encode() + "&score=" + str(score) + "&magic=" + magic)
