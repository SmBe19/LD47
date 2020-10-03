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

var state = {}
var is_replay = false
var time = 0
var replay_log = PlayerReplay.new()

var last_direction = Direction.RIGHT

var speed = 150
var health = 3

func _ready():
	if is_replay:
		self.modulate.a = 0.3
		self.position = replay_log.start_pos
	else:
		replay_log.start_pos = self.position

func is_pressed(key):
	return key in state and state[key]

func process_input_event(ev_str):
	if !is_replay:
		replay_log.inputs.push_back([time,ev_str])
	if ev_str[0] == '+':
		state[ev_str.substr(1)] = true
	if ev_str[0] == '-':
		state[ev_str.substr(1)] = false
		
func hurt(hp):
	health -= hp
	if is_replay:
		self.modulate.g = 0.5
		self.modulate.b = 0.5
		yield(get_tree().create_timer(0.1), "timeout")
		self.modulate.g = 1.0
		self.modulate.b = 1.0
	else:
		get_tree().root.get_child(0).player_hurt()


func handle_input_events():
	if is_replay:
		while !replay_log.inputs.empty() && replay_log.inputs[0][0] < time:
			process_input_event(replay_log.inputs[0][1])
			replay_log.inputs.pop_front()
			
		if Input.is_action_just_pressed("ui_accept"):
			self.hurt(1)
	else:
		var keys = {"move_up":"up", "move_down":"down", "move_left":"left", "move_right":"right"}
		for k in keys:
			if Input.is_action_just_pressed(k):
				process_input_event("+"+keys[k])
			if Input.is_action_just_released(k):
				process_input_event("-"+keys[k])

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
			
