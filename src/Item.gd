extends RigidBody2D
class_name Item

enum ItemType {Crystal, Wood}

var type = ItemType.Crystal

func _ready():
	match type:
		ItemType.Crystal:
			$Sprite.texture = preload("res://img/item/crystal.png")
		ItemType.Wood:
			$Sprite.texture = preload("res://img/item/wood.png")

