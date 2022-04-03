extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var gun_path
onready var gun = get_node(gun_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	gun.try_fire()
