extends Area2D


func _ready():
	pass # Replace with function body.

func on_reset():
	get_parent().remove_child(self)

func _on_body_entered(body):
	if "on_fire" in body:
		body.on_fire = true
	if body.has_method("hurt"):
		body.hurt(1)
