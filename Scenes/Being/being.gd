extends KinematicBody2D

signal game_over
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var max_health = 100;
export var drag = 0.1;
export var speed = 5;

var velocity := Vector2.ZERO
var health

# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health


func apply_force(force):
	
	velocity += force * speed;
	velocity -= drag * velocity;
	
	move_and_slide(velocity);


func damage(damage):
	health -= damage
	if health <= 0:
		_die()

func _die():
	if 'enemy' in get_groups():
		emit_signal("killed_enemy")
		
	if 'player' in get_groups():
		emit_signal("game_over")
		return
	queue_free()
