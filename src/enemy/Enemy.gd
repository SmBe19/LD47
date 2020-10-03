extends KinematicBody2D
class_name Enemy


var target  = null
var aggression_distance = 512
var speed = 100

var attack_speed = 1
var attack_time = INF

var health = 1

func _ready():
	pass # Replace with function body.

func hurt(damage):
	health -= damage
	self.modulate.g = 0.5
	self.modulate.b = 0.5
	yield(get_tree().create_timer(0.1), "timeout")
	self.modulate.g = 1.0
	self.modulate.b = 1.0
	
	if health <= 0:
		if get_parent() != null:
			get_parent().remove_child(self)

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

func _physics_process(delta):
	find_target()
	attack_time += delta
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
		$Sprite.flip_h = motion.x < 0
