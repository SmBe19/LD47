extends KinematicBody2D
class_name Enemy


var target : Player = null
var aggression_distance = 512
var attack_distance = 100
var speed = 100

func _ready():
	pass # Replace with function body.


func find_target():
	if !is_instance_valid(target):
		target = null
	if target != null:
		if target.get_tree() == null:
			target = null
	if target == null:
		for player in get_tree().root.get_child(0).get_players():
			if player.position.distance_to(position) < aggression_distance:
				target = player
				break

func attack():
	pass

func _process(delta):
	find_target()
	if target != null:
		if position.distance_to(target.position) > attack_distance:
			move_and_slide((target.position-position).normalized() * speed)
		else:
			attack()
