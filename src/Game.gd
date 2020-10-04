extends Node2D

var player_scene = preload("res://scn/Player.tscn")


var time = 0
var limit = 20

var score = 0

var ghosts = []

func _ready():
	$UI/AnimationPlayer.play("Transition")
	$UI/AnimationPlayer.seek(1.0)
	pass

func restart():
	score += limit
	
	time = 0
	for ghost in $Ghosts.get_children():
		$Ghosts.remove_child(ghost)
	remove_child($Player)
	var player = player_scene.instance()
	player.set_name("Player")
	player.position = $Level/SpawnPoint.position
	player.position += Vector2(rand_range(-100, 100),rand_range(-100, 100))
	add_child(player)
	
	for x in ghosts:
		var ghost = player_scene.instance()
		ghost.replay_log = x.duplicate()
		ghost.is_replay = true
		$Ghosts.add_child(ghost)
	
	var stack = get_children()
	while !stack.empty():
		var node = stack.pop_back()
		stack += node.get_children()
		if node.has_method("on_reset"):
			node.on_reset()

func get_players():
	var res = []
	res.push_back($Player)
	for x in $Ghosts.get_children():
		res.push_back(x)
	return res

func player_hurt():
	self.modulate.g = 0.5
	self.modulate.b = 0.5
	VisualServer.set_default_clear_color(Color(1,0.5,0.5))
	yield(get_tree().create_timer(0.1), "timeout")
	self.modulate.g = 1.0
	self.modulate.b = 1.0
	VisualServer.set_default_clear_color(Color(1,1,1))

func _process(delta):
	time += delta
	$UI/ProgressBar.value = 1 - time / limit
	$UI/Label.text = "%.1f s" % (limit-time)
	if time > limit - 1:
		$UI/AnimationPlayer.play("Transition")
	$UI/HealthDisplay.region_rect.size.x = 64 * max(0, $Player.health)
	if time > limit:
		ghosts.append($Player.replay_log)

		for child in self.get_children():
			if child is Player:
				self.remove_child(child)
		restart()


func load_level(level):
	score += time
	if level == null || $UI/AnimationPlayer.is_playing():
		# TODO: final level
		return
	$UI/AnimationPlayer.play("Transition")
	yield(get_tree().create_timer(1), "timeout")
	remove_child($Level)
	var instance = load(level).instance()
	instance.set_name("Level")
	add_child(instance)
	ghosts = []
	score -= limit
	restart()


func finish():
	score += time
	print("score = ", score)
	pass
