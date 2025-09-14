extends Node2D

@onready var scene = preload("res://Buff/drop/buff_drop.tscn")
@export var Buffs:Array[Buff_Data]
@onready var spawn_area: Area2D = $Area2D
@onready var timer = $Timer

func _on_timer_timeout():
	spawn_random_in_area()

func spawn_random_in_area():
	var collision = spawn_area.get_node("CollisionShape2D") as CollisionShape2D
	if not collision or not collision.shape:
		push_error("Area2D doesn't have a valid CollisionShape2D")
		return
	var collision_shape = collision.shape
	var extents = collision_shape.size / 2
	var random_x = randf_range(-extents.x, extents.x)
	var random_y = randf_range(-extents.y, extents.y)
	var spawn_position = self.get_parent().global_position + Vector2(random_x,random_y)
	
	spawn(spawn_position)

func spawn(coordinate:Vector2):
	print("spawn buff di " + str(coordinate))
	var buff = scene.instantiate()
	var data = Buffs.pick_random()
	buff.init(data)
	get_tree().current_scene.add_child(buff)
	buff.global_position = coordinate
