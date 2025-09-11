extends Node
class_name ObjectPool

var pool_scene: PackedScene
var available_objects: Array = []
var active_objects: Array = []
var max_pool_size: int = 100
var initial_pool_size: int = 10

func _init(scene: PackedScene, initial_size: int = 10, max_size: int = 100):
	pool_scene = scene
	initial_pool_size = initial_size
	max_pool_size = max_size

func _ready():
	for i in range(initial_pool_size):
		create_new_object()

func create_new_object():
	if not pool_scene:
		return null
	
	var obj = pool_scene.instantiate()
	obj.set_process(false)
	obj.set_physics_process(false)
	obj.visible = false
	available_objects.append(obj)
	add_child(obj)
	return obj

func get_object():
	var obj
	
	if available_objects.size() > 0:
		obj = available_objects.pop_back()
	else:
		# Create new object if pool is empty and under max size
		if get_child_count() < max_pool_size:
			obj = create_new_object()
		else:
			# Pool is full, reuse oldest active object
			if active_objects.size() > 0:
				obj = active_objects[0]
				return_object(obj)
	
	if obj:
		active_objects.append(obj)
		obj.set_process(true)
		obj.set_physics_process(true)
		obj.visible = true
	
	return obj

func return_object(obj):
	if obj in active_objects:
		active_objects.erase(obj)
	
	if obj not in available_objects:
		obj.set_process(false)
		obj.set_physics_process(false)
		obj.visible = false
		obj.global_position = Vector2.ZERO
		available_objects.append(obj)

func return_all_objects():
	for obj in active_objects.duplicate():
		return_object(obj)

func get_active_count() -> int:
	return active_objects.size()

func get_available_count() -> int:
	return available_objects.size()
