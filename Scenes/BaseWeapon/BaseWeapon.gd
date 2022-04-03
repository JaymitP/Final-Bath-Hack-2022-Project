extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var bullet_speed := 10
export var shake_factor := 5.0;
export var aim_factor := 0.1;
export var damage := 5;
export var fire_rate := 0.1;

var last_shot_time := 0.0
var bullet = preload("res://Scenes//Bullet//Bullet.tscn")
var rng := RandomNumberGenerator.new()

func _process(delta):
	last_shot_time += delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
func try_fire():
	if last_shot_time > fire_rate:
		var bullet_instance = bullet.instance()

		if "red_bullets" in get_groups():
				bullet_instance.get_node("sprite").modulate = Color(.55, 0, 0)


		if "blue_bullets" in get_groups():
				bullet_instance.get_node("sprite").modulate = Color(0.6, 0.6, 1)


		if "alien_guns" in get_groups():
			bullet_instance.get_node("sprite").texture = load("res://Assets/laser_bullet.png")
		
		var loops = 1
		if "multishot" in get_groups():
			loops = 4
		
		for i in loops:
			bullet_instance.damage = damage
			bullet_instance.speed = bullet_speed
			
			var random_offset := Vector2(1, 0).rotated(global_rotation + PI / 2) * rng.randf_range(-1, 1) * shake_factor
			var random_angle := rng.randf_range(-1, 1) * aim_factor
			
			bullet_instance.global_position = $bullet_spawn.global_position + random_offset
			bullet_instance.global_rotation = global_rotation + random_angle
			
			$bullet_container.add_child(bullet_instance)
			bullet_instance = bullet.instance()
		
		last_shot_time = 0.0
		if (not $Audio.is_playing()):
			$Audio.play()
			
		return damage
	
	return false
