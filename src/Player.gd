extends KinematicBody2D
class_name Player


class PlayerReplay:
	var inputs = []
	var start_pos = Vector2(0,0)
	
	func duplicate():
		var res = PlayerReplay.new()
		res.inputs = inputs.duplicate()
		res.start_pos = start_pos
		return res

enum Direction {LEFT, RIGHT, UP, DOWN}

var prev_state = {}
var state = {}
var is_replay = false
var time = 0
var replay_log = PlayerReplay.new()

var last_direction = Direction.RIGHT
var override_walk_animation : bool = false

var speed = 200
var health = 3
var attack_range = 100
var damage = 1

func player_marker():
	pass

func _ready():
	if is_replay:
		self.modulate.a = 0.3
		self.position = replay_log.start_pos
	else:
		replay_log.start_pos = self.position

func is_pressed(key):
	return key in state and state[key]

func just_pressed(key):
	return key in state and state[key] and not (key in prev_state and prev_state[key])

func process_input_event(ev_str: String):
	if !is_replay:
		replay_log.inputs.push_back([time,ev_str])
	if ev_str[0] == '+':
		state[ev_str.substr(1)] = true
	if ev_str[0] == '-':
		if ev_str[1] == "*":
			state = {}
		else:
			state[ev_str.substr(1)] = false
	if ev_str[0] == '@':
		match ev_str.substr(1).split("|", true, 1)[0]:
			"hp":
				health += 1
				if !is_replay:
					$"/root/Game".player_extra_hp += 1
			"dmg":
				damage += 1
				if !is_replay:
					$"/root/Game".player_extra_dmg += 1
			"teleport":
				var parts = ev_str.split("|")
				position = Vector2(float(parts[1]), float(parts[2]))
		
func hurt(hp):
	health -= hp
	$"/root/Game".play_at("attack", position)
	if is_replay:
		self.modulate.g = 0.5
		self.modulate.b = 0.5
		yield(get_tree().create_timer(0.1), "timeout")
		self.modulate.g = 1.0
		self.modulate.b = 1.0
	else:
		$"/root/Game".player_hurt()
	
	if health <= 0:
		if is_replay:
			if get_parent() != null:
				get_parent().remove_child(self)
		else:
			# end this iteration
			process_input_event("-*") # release all keys
			var game = $"/root/Game"
			if game.time < game.limit - 1:
				game.time = game.limit - 1


func handle_input_events():
	if is_replay:
		while !replay_log.inputs.empty() && replay_log.inputs[0][0] < time:
			process_input_event(replay_log.inputs[0][1])
			replay_log.inputs.pop_front()
	else:
		var keys = {"move_up":"up", "move_down":"down", "move_left":"left", "move_right":"right", "attack":"attack"}
		for k in keys:
			if Input.is_action_just_pressed(k):
				process_input_event("+"+keys[k])
			if Input.is_action_just_released(k):
				process_input_event("-"+keys[k])
	prev_state = state

func _process(delta):
	time += delta
	handle_input_events()
	
	var vel = Vector2(0,0);
	if is_pressed("up"):
		vel.y -= 1
	if is_pressed("down"):
		vel.y += 1
	if is_pressed("left"):
		vel.x -= 1
	if is_pressed("right"):
		vel.x += 1
	vel *= speed
	if vel.length() > speed:
		vel = vel.normalized() * speed
	
	if !override_walk_animation:
		self.move_and_slide(vel);
		if vel.length() < 0.5 * speed:
			$AnimatedSprite.animation = "idle"
		else:
			if abs(vel.x) > abs(vel.y) - 0.1 * speed:
				$AnimatedSprite.animation = "run_right"
				$AnimatedSprite.flip_h = vel.x < 0
				last_direction = Direction.LEFT if vel.x < 0 else Direction.RIGHT
			else:
				if vel.y > 0:
					last_direction = Direction.DOWN
					$AnimatedSprite.animation = "run_front"
				else:
					last_direction = Direction.UP
					$AnimatedSprite.animation = "run_front"
		match last_direction:
			Direction.UP:
				$RayCast2D.cast_to = Vector2(0, -attack_range)
			Direction.DOWN:
				$RayCast2D.cast_to = Vector2(0, +attack_range)
			Direction.LEFT:
				$RayCast2D.cast_to = Vector2(-attack_range, 0)
			Direction.RIGHT:
				$RayCast2D.cast_to = Vector2(+attack_range, 0)
		
	
	if is_pressed("attack"):
		match last_direction:
			Direction.UP:
				$AnimatedSprite.animation = "attack_up"
			Direction.DOWN:
				$AnimatedSprite.animation = "attack_down"
			Direction.LEFT, Direction.RIGHT:
				$AnimatedSprite.animation = "attack_right"
				$AnimatedSprite.flip_h = last_direction == Direction.LEFT;
		override_walk_animation = true


func _on_animation_finished():
	if $AnimatedSprite.animation.begins_with("attack_"):
		var collider = $RayCast2D.get_collider()
		if collider and collider.has_method("hurt") and !collider.has_method("player_marker"):
			collider.hurt(damage)
			$"/root/Game".play_at("attack", position)
		override_walk_animation = false


func _on_frame_changed():
	var step_frames = []
	match $AnimatedSprite.animation:
		"run_right":
			step_frames = [5,11]
		"run_front":
			step_frames = [0,3]
	if $AnimatedSprite.frame in step_frames:
		$"/root/Game".play_at("walk", position)


func learn_hp(x):
	process_input_event("@hp")

func learn_dmg(x):
	process_input_event("@dmg")

func teleport(destination):
	process_input_event("@teleport" + "|" + str(destination.x) + "|" + str(destination.y))
