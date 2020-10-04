extends StaticBody2D
class_name Bom

var initial_position : Vector2

func _ready():
	initial_position = position

func on_reset():
	position = initial_position
	

func hurt(damage):
	var wood = preload("res://scn/Item.tscn").instance()
	wood.type = Item.ItemType.Wood
	wood.position = self.position
	
	get_parent().add_child(wood)
	position = Vector2(NAN, NAN)
