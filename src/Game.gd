extends Node2D

var player_scene = preload("res://scn/Player.tscn")


var time = 0
var limit = 20

var ghosts = []

func _ready():
	$UI/AnimationPlayer.play("Transition")
	$UI/AnimationPlayer.seek(1.0)
	pass

func restart():
	for ghost in $Ghosts.get_children():
		$Ghosts.remove_child(ghost)
	remove_child($Player)
	var player = player_scene.instance()
	player.set_name("Player")
	player.position += Vector2(rand_range(-100, 100),rand_range(-100, 100))
	add_child(player)
	
	for x in ghosts:
		var ghost = player_scene.instance()
		ghost.replay_log = x.duplicate()
		ghost.is_replay = true
		$Ghosts.add_child(ghost)
		
func get_players():
	var res = []
	res.push_back($Player)
	for x in $Ghosts.get_children():
		res.push_back(x)
	return res

func player_hurt():
	self.modulate.g = 0.5
	self.modulate.b = 0.5
	yield(get_tree().create_timer(0.1), "timeout")
	self.modulate.g = 1.0
	self.modulate.b = 1.0

func _process(delta):
	time += delta
	$UI/ProgressBar.value = 1 - time / limit
	$UI/Label.text = "%.1f s"%(limit-time)
	if time > limit - 1:
		$UI/AnimationPlayer.play("Transition")
	if time > limit:
		time = 0
		ghosts.append($Player.replay_log)
		
		for child in self.get_children():
			if child is Player:
				self.remove_child(child)
		restart()
