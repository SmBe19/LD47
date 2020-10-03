extends Node2D

var player_scene = preload("res://scn/Player.tscn")

export(Array, PackedScene) var random_scenery

var time = 0
var limit = 5

var ghosts = []

func _ready():
	# spawn stuff
	
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

func _process(delta):
	time += delta
	$UI/ProgressBar.value = 1 - time / limit
	$UI/Label.text = "%.1f s"%(limit-time)
	if time > limit:
		time = 0
		ghosts.append($Player.replay_log)
		
		for child in self.get_children():
			if child is Player:
				self.remove_child(child)
		restart()
