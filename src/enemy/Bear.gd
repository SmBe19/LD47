extends Enemy
class_name Bear

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var idle_time : float = 0
var stand_time : float = 1.5
var attack_time2 : float = 0.5

var time : float = 0

func on_reset():
	rng = RandomNumberGenerator.new()
	time = 0
	idle_time = 0
	.on_reset()

func _ready():
	initial_health = health
	on_reset()

func move(delta):
	pass

func die():
	idle_time = INF
	print("bear ded")
	remove_child($CollisionShape2D)
	$AnimationPlayer.play("explode")

func finish_game():
	var game = get_tree().root.get_child(0)
	game.finish()

func _physics_process(delta):
	time += delta
	if time > idle_time + stand_time + attack_time2:
		time = 0
		idle_time = rng.randf_range(1, 5)
		print("idle_time = ", idle_time)
		$AnimationPlayer.play("idle")
	elif time > idle_time + stand_time:
		$AnimationPlayer.play("attack")
		for body in $DamageArea.get_overlapping_bodies():
			if body is Player:
				body.hurt(3)
	elif time > idle_time:
		$AnimationPlayer.play("stand")
	elif idle_time < INF:
		$AnimationPlayer.play("idle")
