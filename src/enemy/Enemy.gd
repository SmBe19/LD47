extends KinematicBody2D
class_name Enemy

var initial_position : Vector2
var initial_health =  1

var mirror = false


var target  = null
export(float) var aggression_distance = 512
export(float) var aggression_distance_replay = 712
export(float) var speed = 100

export(float) var attack_speed = 1
export(float) var attack_time = INF
export(float) var damage = 1

export(float) var health = 1

export(bool) var has_crystal = false

func _ready():
	initial_position = position
	initial_health = health
	collision_mask = 1
	collision_layer = 1

func on_reset():
	position = initial_position
	health = initial_health
	attack_time = INF
	collision_layer = 1
	collision_mask = 1
	show()


func die():
	var old_position = position

	$"/root/Game".play_at("enemydeath", position)
	#self.position = Vector2(NAN,NAN)
	collision_layer = 0
	collision_mask = 0
	hide()
	
	
	if has_crystal:
		has_crystal = false
		var crystal = preload("res://scn/Item.tscn").instance()
		crystal.type = Item.ItemType.Crystal
		crystal.position = old_position
		get_parent().add_child(crystal)

func hurt(damage):
	health -= damage
	self.modulate.g = 0.5
	self.modulate.b = 0.5
	yield(get_tree().create_timer(0.1), "timeout")
	self.modulate.g = 1.0
	self.modulate.b = 1.0
	
	if health <= 0:
		die()

func find_target():
	if target != null && !is_instance_valid(target):
		target = null
	if target != null:
		if target.get_tree() == null:
			target = null
	if target == null:
		for player in $"/root/Game/".get_players():
			var distance = aggression_distance
			if player.is_replay:
				distance = aggression_distance_replay
			if player.position.distance_to(position) < distance:
				target = player
				break
	else:
		var distance = aggression_distance
		if target.is_replay:
			distance = aggression_distance_replay
		if target.position.distance_to(position) > aggression_distance:
			target = null

func move(delta):
	if target != null:
		var motion = (target.position-position).normalized() * speed * delta
		var collision = move_and_collide(motion)
		if collision:
			if collision.collider.has_method("player_marker"):
				target = collision.collider
				if attack_time > attack_speed:
					attack()
					attack_time = 0
			else:
				motion = collision.remainder.slide(collision.normal)
				move_and_collide(motion)
		$Sprite.flip_h = mirror != (motion.x < 0)

func attack():
	target.hurt(damage)
	pass

func _physics_process(delta):
	attack_time += delta
	if is_nan(self.position.x):
		return
	find_target()
	move(delta)
