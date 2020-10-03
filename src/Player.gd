extends KinematicBody2D
class_name Player


var speed = 100
var state = {}
var is_replay = false
var time = 0
var replay_log = []

func _ready():
	if is_replay:
		self.modulate.a = 0.5
	pass

func is_pressed(key):
	return key in state and state[key]

func process_input_event(ev_str):
	if !is_replay:
		replay_log.push_back([time,ev_str])
	if ev_str[0] == '+':
		state[ev_str.substr(1)] = true
	if ev_str[0] == '-':
		state[ev_str.substr(1)] = false


func handle_input_events():
	if is_replay:
		while !replay_log.empty() && replay_log[0][0] < time:
			process_input_event(replay_log[0][1])
			replay_log.pop_front()
	else:
		var keys = {"ui_up":"up", "ui_down":"down", "ui_left":"left", "ui_right":"right"}
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
	print(name)
	print(vel)
	self.move_and_slide(vel);
