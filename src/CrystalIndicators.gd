extends Node2D


var indicators = []
var margin = 32

func _ready():
	pass # Replace with function body.

func _process(delta):
	update()

func _draw():
	var camera = $"../../Player/Camera2D"
	for x in indicators:
		var pos = x[0]
		var texture = x[1]
		var relpos = pos - camera.get_camera_screen_center()
		var onscreen = true
		if abs(relpos.x) > position.x - margin:
			relpos *= (position.x-margin)/abs(relpos.x)
			onscreen = false
		if abs(relpos.y) > position.y - margin:
			relpos *= (position.y-margin)/abs(relpos.y)
			onscreen = false
		if !onscreen:
			draw_texture(texture, relpos - texture.get_size() / 2)
		
