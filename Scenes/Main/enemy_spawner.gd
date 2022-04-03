extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var enemy_num = 5
export var wait_range = Vector2(1, 5)

export (NodePath) var player_path;
onready var player = get_node(player_path)

export (NodePath) var level_path;
onready var floor_map = get_node(level_path).get_node("floor_tile")
onready var wall_map = get_node(level_path).get_node("wall_tiles")


var wait_time = rand_range(wait_range.x, wait_range.y)
var enemies := [preload("../Enemies/Gobster.tscn"), preload("../Enemies/Grazer.tscn"), preload("../Enemies/Glocktle.tscn"), preload("../Enemies/FutureTank.tscn"), preload("../Enemies/ModernTank.tscn")]


# Called when the node enters the scene tree for the first time.
func _process(delta):
	wait_time -= delta
	if wait_time < 0:
		#spawn code
		
		var pos := Vector2.ZERO
		var tile_pos := Vector2.ZERO
		while true:
			var dir := Vector2(1, 0).rotated(rand_range(-PI, PI))
			dir = dir.normalized()
			pos = player.global_position + dir * get_viewport().size.x * 0.6
			#pos = player.global_position
			tile_pos = floor_map.world_to_map(pos)
			if (floor_map.get_cellv(tile_pos) != floor_map.INVALID_CELL and wall_map.get_cellv(tile_pos) == wall_map.INVALID_CELL):
				break
		
		var new_enemy = rand_from_list(enemies).instance()
		new_enemy.player = player
		new_enemy.global_position =  floor_map.map_to_world(tile_pos-Vector2(8,0))
		add_child(new_enemy)
		
		wait_time = rand_range(wait_range.x, wait_range.y)
		


func rand_from_list(list):
	return list[randi() % len(list)]


func _on_Player_game_over():
	for child in get_children():
		child.queue_free()
	queue_free()
