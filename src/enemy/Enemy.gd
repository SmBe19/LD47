extends KinematicBody2D
class_name Enemy

var initial_position : Vector2
var initial_health =  1

var mirror = false

var target  = null
export(float) var aggression_distance = 512
export(float) var speed = 100

export(float) var attack_speed = 1
export(float) var attack_time = INF
export(float) var damage = 1

export(float) var health = 1

func _ready():
	initial_position = position
	initial_health = health

func on_reset():
	position = initial_position
	health = initial_health
	attack_time = INF


func die():
	self.position = Vector2(NAN,NAN)

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
