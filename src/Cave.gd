extends StaticBody2D
class_name Cave

export(NodePath) var teleport_target


func _on_body_entered(body):
	if body is Player:
		if !body.is_replay:
			var ap = $"/root/Game/UI/AnimationPlayer"
			if ap.is_playing():
				ap.seek(ap.current_animation_length, true)
			ap.play("CaveEnter")
		yield(get_tree().create_timer(1), "timeout")
		body.position = get_node(teleport_target).global_position
