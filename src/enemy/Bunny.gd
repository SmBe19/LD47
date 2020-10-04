extends RigidBody2D
class_name Bunny


var initial_position : Vector2

func _ready():
	initial_position = position
	$AnimationPlayer.play("jump")
	pass

var reset_queued = false
var death_queued = false

var on_fire = false

func on_reset():
	reset_queued = true
	on_fire = false
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
		closest.health += 1
	else:
		var meat = preload("res://scn/Item.tscn").instance()
		meat.type = Item.ItemType.Meat
		meat.position = position
		get_parent().add_child(meat)
	
	death_queued = true

func _integrate_forces(state):
	if reset_queued:
		print("executed reset!")
		print(initial_position)
		state.transform.origin = initial_position
		reset_queued = false
	if death_queued:
		state.transform.origin = Vector2(NAN, NAN)
		death_queued = false

func _on_land():
	pass
