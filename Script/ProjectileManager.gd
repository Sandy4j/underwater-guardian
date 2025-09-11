extends Node

var projectile_pool: ObjectPool

func set_projectile_pool(pool: ObjectPool):
	projectile_pool = pool

func spawn_homing_projectile(start_pos: Vector2, target: Node2D, damage: int):
	if not projectile_pool:
		return null
	
	var projectile = projectile_pool.get_object()
	if projectile:
		projectile.global_position = start_pos
		projectile.setup(target, damage)
		projectile.projectile_finished.connect(_on_projectile_finished)
	
	return projectile

func _on_projectile_finished(projectile):
	if projectile_pool:
		projectile_pool.return_object(projectile)
