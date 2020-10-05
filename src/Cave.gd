extends StaticBody2D

export(NodePath) var teleport_target


func _on_body_entered(body):
	if body is Player:
		body.position = get_node(teleport_target).position
