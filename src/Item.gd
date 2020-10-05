extends RigidBody2D
class_name Item

enum ItemType {Crystal, Wood, Meat, Crate, HpBook, DmgBook}

var initial_position : Vector2


var reset_queued = false
var death_queued = false


export var type = ItemType.Crystal
var on_fire = false

func _ready():
	on_fire = false
	initial_position = position
	match type:
		ItemType.Crystal:
			$Sprite.animation = "crystal"
		ItemType.Wood:
			$Sprite.animation = "wood"
		ItemType.Meat:
			$Sprite.animation = "steak"
		ItemType.Crate:
			$Sprite.animation = "crate"
		ItemType.HpBook,ItemType.DmgBook:
			$Sprite.animation = "book"
	$Sprite.playing = false
	
	
	reset_queued = true

func on_reset():
	on_fire = false
	match type:
		ItemType.Crystal:
			# crystals are persistent
			pass
		ItemType.Wood, ItemType.Meat:
			# these come from trees/bunnys which will respawn
			get_parent().remove_child(self)
		ItemType.Crate, ItemType.DmgBook, ItemType.HpBook:
			reset_queued = true

func hurt(dmg):
	if on_fire:
		match type:
			ItemType.Meat:
				var players = $"/root/Game".get_players()
				var closest = players[0]
				for player in players:
					if player.position.distance_to(position) < closest.position.distance_to(position):
						closest = player
				closest.health += $"/root/Game".player_extra_hp + 3
				get_parent().remove_child(self)
	match type:
		ItemType.Wood:
			var fire = preload("res://scn/env/Fire.tscn").instance()
			fire.position = self.position
			get_parent().add_child(fire)
			get_parent().remove_child(self)
		ItemType.Crate:
			print("destroy crate!")
			var wood = load("res://scn/Item.tscn").instance()
			wood.type = ItemType.Wood
			wood.position = position
			get_parent().add_child(wood)
			death_queued = true
		ItemType.HpBook, ItemType.DmgBook:
			var bookanim = $"/root/Game/UI/BookAnim"
			bookanim.play("open")
			bookanim.connect("animation_finished", self, "_on_animation_finished", [bookanim])


func _integrate_forces(state):
	if reset_queued:
		state.transform = Transform2D(0, initial_position)
		state.linear_velocity = Vector2(0,0)
		state.angular_velocity = 0
		reset_queued = false
	if death_queued:
		state.transform.origin = Vector2(NAN, NAN)
		death_queued = false



func _on_animation_finished(bookanim):
	match type:
		ItemType.DmgBook:
			$"/root/Game/Player".learn_dmg(1)
		ItemType.HpBook:
			$"/root/Game/Player".learn_hp(1)
		_:
			return
	bookanim.frame = 0
	bookanim.playing = false
	if get_parent():
		get_parent().remove_child(self)
	
