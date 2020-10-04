extends StaticBody2D


export(bool) var active = false setget set_active
export(int) var crystal_count = 0 setget set_crystal_count
export(int) var crystal_needed = 2
export(String, FILE) var target_level


func set_crystal_count(_count):
	crystal_count = _count
	if crystal_count >= crystal_needed:
		set_active(true)
	$Label.text = "%d/%d" % [crystal_count, crystal_needed]

func set_active(_active):
	active = _active
	$portal.visible = !active
	$portal_active.visible = active

# Called when the node enters the scene tree for the first time.
func _ready():
	set_crystal_count(crystal_count)
	pass # Replace with function body.



func _on_body_entered(body):
	if body is Player:
		if active and !body.is_replay:
			get_tree().root.get_child(0).load_level(target_level)
	if body is Item:
		set_crystal_count(crystal_count + 1)
		body.get_parent().remove_child(body)
