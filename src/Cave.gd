extends StaticBody2D

export(NodePath) var teleport_target


func _on_body_entered(body):
	if body is Player:
		if !body.is_replay:
			$"/root/Game/UI/AnimationPlayer".play("CaveEnter")
			print("playing animation")
		yield(get_tree().create_timer(1), "timeout")
		body.position = get_node(teleport_target).position
