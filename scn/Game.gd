extends Node2D

var player_scene = 	preload("res://scn/Player.tscn")

var time = 0
var limit = 5

var ghosts = []

func _ready():
	pass

func restart():
	var player = player_scene.instance()
	player.set_name("Player")
	add_child(player)
	
	for x in ghosts:
		print(x)
		var ghost = player_scene.instance()
		ghost.replay_log = x.duplicate()
		ghost.is_replay = true
		add_child(ghost)

func _process(delta):
	time += delta
	if time > limit:
		time = 0
		ghosts.append($Player.replay_log)
		for child in self.get_children():
			if child is Player:
				self.remove_child(child)
		restart()
