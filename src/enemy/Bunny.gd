extends RigidBody2D
class_name Bunny


var initial_position : Vector2

func _ready():
	initial_position = position
	$AnimationPlayer.play("jump")
	pass

var reset_queued = false
var death_queued = false

var jumping = false
var jump_starting_pos : Vector2 
var jump_target_offset : Vector2 = Vector2.ZERO

var on_fire = false

func on_reset():
	reset_queued = true
	death_queued = false
	on_fire = false
	jumping = false
	jump_target_offset = Vector2.ZERO
	print("queued reset!")

func hurt(hp):
	self.modulate.g = 0.5
	self.modulate.b = 0.5
	yield(get_tree().create_timer(0.1), "timeout")
	self.modulate.g = 1.0
	self.modulate.b = 1.0
	
	if on_fire:
		var players = $"/root/Game".get_players()
		var closest = players[0]
		for player in players:
			if player.position.distance_to(position) < closest.position.distance_to(position):
				closest = player
		closest.health += $"/root/Game".player_extra_hp + 3
	else:
		var meat = preload("res://scn/Item.tscn").instance()
		meat.type = Item.ItemType.Meat
		meat.position = position
		get_parent().add_child(meat)
	
	death_queued = true
	jumping = false
	jump_target_offset = Vector2.ZERO

func _integrate_forces(state):
	if reset_queued:
		state.transform.origin = initial_position
		jump_starting_pos = initial_position
		reset_queued = false
	if death_queued:
		state.transform.origin = Vector2(NAN, NAN)
		death_queued = false
	if jumping:
		# tween position
		state.transform.origin = jump_starting_pos + min(1.0, $AnimationPlayer.current_animation_position) * jump_target_offset

func land():
	jumping = false
	$AnimationPlayer.playback_speed = rand_range(0.2, 1)


func jump():
	jumping = true
	jump_starting_pos = position
	jump_target_offset =  Vector2(rand_range(-100,100), rand_range(-100, 100))
	$AnimationPlayer.playback_speed = 1

