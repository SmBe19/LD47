extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	mirror = true
	health = 3
	._ready()

func attack():
	print("spoder attack!")
	.attack()
