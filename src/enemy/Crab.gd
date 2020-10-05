extends Enemy


func _ready():
	._ready()

func attack():
	print("crab attack!")
	.attack()
	var diff = target.position - position
	if diff.y < -abs(diff.x):
		$Sprite.animation = "attack_up"
	elif diff.x > 0:
		$Sprite.animation = "attack_right"
	else:
		$Sprite.animation = "attack_left"


func _on_animation_finished():
	$Sprite.animation = "walk"
