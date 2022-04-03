extends "../Being/being.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var cam_towards_mouse := 0.25;
onready var cam_pos = $cam_pos;

var dead := false
var dead_timer = 0;
var score = 0;

export(NodePath) var gun_path
onready var gun := get_node(gun_path)
var teleport_time = OS.get_unix_time()

var gun_item = preload("res://Scenes/GunItem/GunItem.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# handle movement here
func _physics_process(delta):
	if not dead:
		var force := Vector2.ZERO;

		# handle movement cases
		if Input.is_action_pressed("move_up"):
			force += Vector2(0, -1);	
		if Input.is_action_pressed("move_down"):
			force += Vector2(0, 1);
		if Input.is_action_pressed("move_left"):
			force += Vector2(-1, 0);
		if Input.is_action_pressed("move_right"):
			force += Vector2(1, 0);
		$AnimationPlayer.play("Walk_Down")
		force = force.normalized();
		apply_force(force)
		
		var damage = 0
		if Input.is_action_pressed("fire"):
			if gun:
				var damaged = gun.try_fire()
				if damaged:
					damage = damaged
					

		_move_camera(damage);

	else:
		dead_timer += delta
		if dead_timer > 5:
			get_tree().change_scene("res://Scenes/Menu/Title.tscn")

		$cam_pos/camera.zoom += Vector2.ONE * delta / 10

		cam_pos.get_node("camera").set_offset(Vector2( \
		rand_range(-1.0, 1.0) * 5, \
		rand_range(-1.0, 1.0) * 5 \
	))
	
	
func _move_camera(damage):
	
	var viewport := get_viewport()
	var mouse_point := viewport.get_mouse_position() - viewport.get_visible_rect().size / 2
	
	rotation = Vector2(1, 0).angle_to(mouse_point)
	
	var cam_dest := global_position + mouse_point * cam_towards_mouse;
	
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var result = space_state.intersect_ray(global_position, cam_dest)
	
	if result:
		cam_dest = result.position
	
	cam_pos.global_transform = Transform2D(0, cam_dest)
	cam_pos.get_node("camera").set_offset(Vector2( \
		rand_range(-1.0, 1.0) * damage, \
		rand_range(-1.0, 1.0) * damage \
	))
	


func _unhandled_input(event):
	if not dead:
		if event.is_action_pressed("ui_accept"):
			damage(10);
			print_debug("Hurt for 10!")
			
			
		if event.is_action_pressed("pickup"):
			for area in $hitbox.get_overlapping_areas():
				if "pickup" in area.get_groups():
					
					
					var packed_gun = PackedScene.new()
					packed_gun.pack(gun)
					var itemInst = gun_item.instance()
					itemInst.gun = packed_gun
					itemInst.global_position = global_position
					get_parent().add_child(itemInst)
					
					gun.queue_free()
					var gun_inst = area.pick_up()
					add_child(gun_inst)
					gun = gun_inst
					

		if event.is_action_pressed("teleport"):
			if ((OS.get_unix_time() - teleport_time) < 2):
				return 
			var floor_tiles = get_parent().get_node("Level").get_node("floor_tile")
			var wall_tiles = get_parent().get_node("Level").get_node("wall_tiles")
			var position = floor_tiles.world_to_map(get_global_mouse_position())
			
			if (floor_tiles.get_cellv(position) != -1 and wall_tiles.get_cellv(position) != 0):
				global_position = get_global_mouse_position() 
				teleport_time = OS.get_unix_time()


		if event.is_action_pressed("hook"):
			var mouse_pos = get_global_mouse_position()
			var space_state = get_world_2d().direct_space_state
			var result = space_state.intersect_ray(global_position, 100*(get_global_mouse_position()-global_position)) 
			var target = result.position
			# look_at(target)
			if (global_position.distance_to(target) < 250):
				velocity = position.direction_to(target) * 2000
				move_and_slide(velocity)
				

func _on_Player_game_over():
	dead = true

