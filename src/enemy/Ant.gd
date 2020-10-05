extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready():
	mirror = true
	._ready()

func attack():
	print("ant attack!")
	.attack()
