class_name Sounds
const sounds = {
	"attack": [
		preload("res://snd/attack1.wav"),
		preload("res://snd/attack2.wav"),
		preload("res://snd/attack3.wav"),
	],
	"cratedestroy": [
		preload("res://snd/cratedestroy.wav"),
	],
	"crystalactivate": [
		preload("res://snd/crystalactivate.wav"),
	],
	"enemydeath": [
		preload("res://snd/enemydeath.wav"),
	],
	"portalactivate": [
		preload("res://snd/portalactivate.wav"),
	],
	"timeloop": [
		preload("res://snd/timeloop.wav"),
	],
	"treefall": [
		preload("res://snd/treefall.wav"),
	],
	"walk": [
		preload("res://snd/walk1.wav"),
		preload("res://snd/walk2.wav"),
		preload("res://snd/walk3.wav"),
		preload("res://snd/walk4.wav"),
	]
}

static func Get(name):
	if name in sounds:
		return sounds[name][randi()%len(sounds[name])]
	else:
		print("no sound named ", name)
