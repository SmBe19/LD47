extends Node2D

var player_scene = preload("res://scn/Player.tscn")


var time = 0
var limit = 15

var score = 0

var ghosts = []

var player_extra_hp = 0
var player_extra_dmg = 0
var transition_playing = false
var is_muted = false

func _ready():
	$UI/AnimationPlayer.play("Transition")
	$UI/AnimationPlayer.seek(1.0)
	#$"/root/Game/Player".learn_hp(1)
	#$"/root/Game/Player".learn_hp(1)
	#$"/root/Game/Player".learn_dmg(1)
	#$"/root/Game".limit = 60
	restart()

#func _enter_tree():
#	load_level("res://scn/lvl/Level3.tscn")

func restart():
	score += limit
	
	transition_playing = false
	time = 0
	for ghost in $Ghosts.get_children():
		$Ghosts.remove_child(ghost)
	remove_child($Player)
	var player = player_scene.instance()
	player.set_name("Player")
	player.position = $Level/SpawnPoint.position
	player.position += Vector2(rand_range(-100, 100),rand_range(-100, 100))
	player.health += player_extra_hp
	player.damage += player_extra_dmg
	add_child(player)
	var camera = Camera2D.new()
	camera.name = "Camera2D";
	camera.drag_margin_left = 0.4
	camera.drag_margin_right = 0.4
	camera.drag_margin_top = 0.3
	camera.drag_margin_bottom = 0.5
	camera.drag_margin_h_enabled = true
	camera.drag_margin_v_enabled = true
	player.add_child(camera)
	camera.current = true
	
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
	for x in $Ghosts.get_children():
		res.push_back(x)
	res.push_back($Player)
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
		if not transition_playing:
			$TransitionPlayer.play()
			if $UI/AnimationPlayer.is_playing():
				$UI/AnimationPlayer.seek($UI/AnimationPlayer.current_animation_length, true)
			$UI/AnimationPlayer.play("Transition")
			transition_playing = true
	$UI/HealthDisplay.region_rect.size.x = 64 * max(0, $Player.health)
	if time > limit:
		ghosts.append($Player.replay_log)

		for child in self.get_children():
			if child is Player:
				self.remove_child(child)
		restart()

	var indicators = []
	var stack = get_children()
	while !stack.empty():
		var node = stack.pop_back()
		stack += node.get_children()
		if node is Enemy:
			if node.has_crystal:
				indicators.push_back([node.global_position, preload("res://img/ui/crystalindicator.png")])
		if node is Item:
			match node.type:
				Item.ItemType.Crystal:
					indicators.push_back([node.global_position, preload("res://img/ui/crystalindicator.png")])
				Item.ItemType.HpBook, Item.ItemType.DmgBook:
					indicators.push_back([node.global_position, preload("res://img/ui/bookindicator.png")])
		if node is Portal or node is Cave:
			indicators.push_back([node.global_position, preload("res://img/ui/portalindicator.png")])

	$UI/CrystalIndicators.indicators = indicators


func load_level(level: String):
	score += time
	if level == null || $UI/AnimationPlayer.is_playing():
		# TODO: final level
		return
	$UI/AnimationPlayer.play("Transition")
	yield(get_tree().create_timer(1), "timeout")
	remove_child($Level)
	var instance = load(level).instance()
	if level.ends_with("Level3.tscn"):
		play_music("res://msc/CursedMeadow.ogg", false)
	instance.set_name("Level")
	add_child(instance)
	ghosts = []
	score -= limit
	restart()


func finish():
	score += time
	Globals.score = score
	get_tree().change_scene("res://scn/Hiscores.tscn")
	


func play_music(track_name, keep_position = false):
	var playback_pos = 0
	if keep_position:
		playback_pos = $MusicPlayer.get_playback_position()
	$MusicPlayer.stream = load(track_name)
	$MusicPlayer.play(playback_pos)
	if is_muted:
		$MusicPlayer.stream_paused = true

func play_at(sound, position: Vector2):
	var soundplayer = null
	if is_nan(position.x):
		soundplayer = AudioStreamPlayer.new()
	else:
		soundplayer = AudioStreamPlayer2D.new()
		soundplayer.position = position
	soundplayer.bus = "Effects"
	if sound is String:
		soundplayer.stream = Sounds.Get(sound)
	elif sound is AudioStream:
		soundplayer.stream = sound
	add_child(soundplayer)
	soundplayer.play()
	soundplayer.connect("finished", self, "remove_child", [soundplayer])

func _on_mute_toggled(button_pressed):
	if button_pressed:
		$MusicPlayer.stream_paused = true
		is_muted = true
	else:
		$MusicPlayer.stream_paused = false
		is_muted = false

func _on_MusicPlayer_finished():
	$MusicPlayer.disconnect("finished", self, "_on_MusicPlayer_finished")
	play_music("res://msc/EnchantedMeadow.ogg", false)
