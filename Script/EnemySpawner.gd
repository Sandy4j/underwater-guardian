extends Node2D
class_name EnemySpawner

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal enemy_spawned(enemy: BaseEnemy)

# Enemy Type Configuration
@export_group("Enemy Configuration")
@export var enemy_types: Array[EnemyTypeData] = []
@export var enable_enemy_type_weights: bool = true

@export_group("Spawn Settings")
@export var spawn_radius: float = 300.0
@export var spawn_distance_from_player: float = 250.0
@export var max_enemies_on_screen: int = 50
@export var spawn_outside_screen: bool = true

@export_group("Wave Configuration")
@export var base_spawn_interval: float = 2.0
@export var enemies_per_wave: int = 10
@export var wave_difficulty_multiplier: float = 1.2
@export var auto_start: bool = true

var current_wave: int = 1
var enemies_spawned_this_wave: int = 0
var active_enemies: Array = []
var is_spawning: bool = false

var player: Node2D
var spawn_timer: Timer
var camera: Camera2D
var use_boundaries: bool = true
var boundary_left: float = 0.0
var boundary_top: float = 0.0
var boundary_right: float = 4320.0
var boundary_bottom: float = 2430.0
var boundary_margin: float = 50.0

# Object pools - one for each enemy type
var enemy_pools: Dictionary = {}
var projectile_pool: ObjectPool

# Spawn areas (edges of screen/boundary)
enum SpawnEdge { TOP, RIGHT, BOTTOM, LEFT }

func _ready():
	add_to_group("spawner")
	setup_pools()
	setup_spawner()
	find_player()
	find_camera()
	validate_enemy_types()

	if auto_start:
		call_deferred("start_spawning")

func validate_enemy_types():
	if enemy_types.is_empty():
		print("EnemySpawner: WARNING - No enemy types configured!")
		return

	print("EnemySpawner: Configured enemy types:")
	for i in range(enemy_types.size()):
		var enemy_type = enemy_types[i]
		if enemy_type and enemy_type.scene:
			print("  - ", enemy_type.type_name, " (Weight: ", enemy_type.spawn_weight, ")")
		else:
			print("  - Index ", i, ": Invalid enemy type data")

func find_camera():
	camera = get_viewport().get_camera_2d()
	if camera:
		print("EnemySpawner: Camera found: ", camera.name)
	else:
		print("EnemySpawner: No camera found, using boundary spawning")

func setup_pools():
	print("EnemySpawner: Setting up object pools...")

	# Create pools for each enemy type
	for i in range(enemy_types.size()):
		var enemy_type = enemy_types[i]
		if not enemy_type or not enemy_type.scene:
			continue

		var pool = ObjectPool.new(enemy_type.scene, enemy_type.initial_pool_size, enemy_type.max_pool_size)
		pool.name = enemy_type.type_name + "Pool"
		add_child(pool)
		enemy_pools[enemy_type.type_name] = pool
		print("EnemySpawner: Created pool for ", enemy_type.type_name)

	# Setup projectile pool
	setup_projectile_pool()

func setup_projectile_pool():
	var projectile_scene_path = "res://enemies/scenes/HomingProjectile.tscn"
	if ResourceLoader.exists(projectile_scene_path):
		var projectile_scene = load(projectile_scene_path)
		projectile_pool = ObjectPool.new(projectile_scene, 20, 100)
		projectile_pool.name = "ProjectilePool"
		add_child(projectile_pool)

		ProjectileManager.set_projectile_pool(projectile_pool)
		print("EnemySpawner: Projectile pool created and registered")
	else:
		print("EnemySpawner: WARNING - Projectile scene not found at: ", projectile_scene_path)

func setup_spawner():
	spawn_timer = Timer.new()
	spawn_timer.name = "SpawnTimer"
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	print("EnemySpawner: Spawn timer created")

func find_player():
	player = get_tree().get_first_node_in_group("knight")
	if player:
		print("EnemySpawner: Player found: ", player.name)
	else:
		print("EnemySpawner: WARNING - No player found! Make sure player is in 'player' group")

func start_spawning():
	if not player:
		find_player()
		if not player:
			print("EnemySpawner: Cannot start spawning - no player found!")
			return

	is_spawning = true
	start_wave()

func stop_spawning():
	is_spawning = false
	spawn_timer.stop()

func start_wave():
	if not is_spawning:
		return

	enemies_spawned_this_wave = 0
	wave_started.emit(current_wave)
	spawn_timer.start()
	print("EnemySpawner: Wave ", current_wave, " started")

func _on_spawn_timer_timeout():
	if not is_spawning:
		return

	if enemies_spawned_this_wave >= enemies_per_wave:
		spawn_timer.stop()
		check_wave_completion()
		return

	if active_enemies.size() >= max_enemies_on_screen:
		return

	spawn_random_enemy()
	enemies_spawned_this_wave += 1

	var new_interval = base_spawn_interval / (1 + (current_wave - 1) * 0.1)
	spawn_timer.wait_time = max(new_interval, 0.3)

func spawn_random_enemy():
	if not player:
		return

	var spawn_pos = get_boundary_spawn_position()
	if spawn_pos == Vector2.ZERO:
		return

	var enemy_type_data = choose_enemy_type()
	if not enemy_type_data:
		return

	var enemy = get_enemy_from_pool(enemy_type_data.type_name)
	if enemy:
		setup_enemy(enemy, spawn_pos, enemy_type_data)
		enemy_spawned.emit(enemy)

func choose_enemy_type() -> EnemyTypeData:
	if enemy_types.is_empty():
		return null

	# Filter available enemy types based on wave requirements
	var available_types: Array[EnemyTypeData] = []

	for enemy_type in enemy_types:
		if not enemy_type or not enemy_type.scene:
			continue

		# Check if enemy type is available for this wave
		if current_wave >= enemy_type.unlock_wave:
			# Check wave range if specified
			if enemy_type.max_wave <= 0 or current_wave <= enemy_type.max_wave:
				available_types.append(enemy_type)

	if available_types.is_empty():
		print("EnemySpawner: No available enemy types for wave ", current_wave)
		return null

	# Choose based on weights
	if enable_enemy_type_weights:
		return choose_weighted_enemy_type(available_types)
	else:
		return available_types[randi() % available_types.size()]

func choose_weighted_enemy_type(available_types: Array[EnemyTypeData]) -> EnemyTypeData:
	# Calculate total weight
	var total_weight = 0.0
	for enemy_type in available_types:
		var wave_adjusted_weight = enemy_type.spawn_weight

		# Apply wave-based weight modifiers
		if enemy_type.wave_weight_curve.size() > 0:
			var curve_index = min(current_wave - 1, enemy_type.wave_weight_curve.size() - 1)
			wave_adjusted_weight *= enemy_type.wave_weight_curve[curve_index]

		total_weight += wave_adjusted_weight

	# Choose random point in weight range
	var random_weight = randf() * total_weight
	var current_weight = 0.0

	for enemy_type in available_types:
		var wave_adjusted_weight = enemy_type.spawn_weight
		if enemy_type.wave_weight_curve.size() > 0:
			var curve_index = min(current_wave - 1, enemy_type.wave_weight_curve.size() - 1)
			wave_adjusted_weight *= enemy_type.wave_weight_curve[curve_index]

		current_weight += wave_adjusted_weight
		if random_weight <= current_weight:
			return enemy_type

	# Fallback to last enemy type
	return available_types[-1]

func get_enemy_from_pool(enemy_type_name: String):
	if enemy_type_name in enemy_pools:
		return enemy_pools[enemy_type_name].get_object()

	print("EnemySpawner: No pool found for enemy type: ", enemy_type_name)
	return null

func setup_enemy(enemy, spawn_pos: Vector2, enemy_type_data: EnemyTypeData):
	enemy.global_position = spawn_pos

	# Apply base stats from enemy type data
	if enemy_type_data.override_stats:
		if enemy_type_data.base_health > 0:
			enemy.max_health = enemy_type_data.base_health
		if enemy_type_data.base_damage > 0:
			enemy.damage = enemy_type_data.base_damage
		if enemy_type_data.base_speed > 0:
			enemy.move_speed = enemy_type_data.base_speed

	# Scale stats based on wave
	var wave_multiplier = pow(wave_difficulty_multiplier, current_wave - 1)
	enemy.max_health *= wave_multiplier
	enemy.current_health = enemy.max_health
	enemy.damage = int(enemy.damage * wave_multiplier)
	enemy.move_speed *= min(wave_multiplier, 2.0)

	# Connect death signal if not already connected
	if not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)

	active_enemies.append(enemy)
	if enemy.has_method("update_health_bar"):
		enemy.update_health_bar()

func get_boundary_spawn_position() -> Vector2:
	if not player:
		return Vector2.ZERO

	var attempts = 0
	var max_attempts = 10

	while attempts < max_attempts:
		var spawn_pos: Vector2

		if use_boundaries:
			spawn_pos = get_boundary_edge_position()
		else:
			spawn_pos = get_circular_spawn_position()

		if is_valid_spawn_position(spawn_pos):
			return spawn_pos

		attempts += 1

	print("EnemySpawner: Could not find valid spawn position after ", max_attempts, " attempts")
	return Vector2.ZERO

func get_boundary_edge_position() -> Vector2:
	var edge = randi() % 4 as SpawnEdge
	var spawn_pos: Vector2

	match edge:
		SpawnEdge.TOP:
			spawn_pos = Vector2(
				randf_range(boundary_left + boundary_margin, boundary_right - boundary_margin),
				boundary_top - boundary_margin
			)
		SpawnEdge.RIGHT:
			spawn_pos = Vector2(
				boundary_right + boundary_margin,
				randf_range(boundary_top + boundary_margin, boundary_bottom - boundary_margin)
			)
		SpawnEdge.BOTTOM:
			spawn_pos = Vector2(
				randf_range(boundary_left + boundary_margin, boundary_right - boundary_margin),
				boundary_bottom + boundary_margin
			)
		SpawnEdge.LEFT:
			spawn_pos = Vector2(
				boundary_left - boundary_margin,
				randf_range(boundary_top + boundary_margin, boundary_bottom - boundary_margin)
			)

	return spawn_pos

func get_circular_spawn_position() -> Vector2:
	var angle = randf() * TAU
	var distance = spawn_distance_from_player + randf_range(-50, 50)

	var spawn_pos = player.global_position + Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)

	return spawn_pos

func is_valid_spawn_position(pos: Vector2) -> bool:
	if use_boundaries:
		var extended_left = boundary_left - boundary_margin * 2
		var extended_top = boundary_top - boundary_margin * 2
		var extended_right = boundary_right + boundary_margin * 2
		var extended_bottom = boundary_bottom + boundary_margin * 2

		if pos.x < extended_left or pos.x > extended_right or pos.y < extended_top or pos.y > extended_bottom:
			return false

	if player and pos.distance_to(player.global_position) < spawn_distance_from_player * 0.5:
		return false

	if spawn_outside_screen and camera:
		var camera_rect = get_camera_rect()
		if camera_rect.has_point(pos):
			return false

	return true

func get_camera_rect() -> Rect2:
	if not camera:
		return Rect2()

	var camera_size = get_viewport().get_visible_rect().size
	if camera.enabled:
		camera_size /= camera.zoom

	var camera_pos = camera.global_position - camera_size / 2
	return Rect2(camera_pos, camera_size)

func _on_enemy_died(enemy):
	active_enemies.erase(enemy)
	return_enemy_to_pool(enemy)
	check_wave_completion()

func return_enemy_to_pool(enemy):
	if enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.disconnect(_on_enemy_died)

	# Find which pool this enemy belongs to
	for type_name in enemy_pools.keys():
		var pool = enemy_pools[type_name]
		if enemy in pool.active_objects:
			pool.return_object(enemy)
			break

	if enemy.has_method("reset_state"):
		enemy.reset_state()

func check_wave_completion():
	if enemies_spawned_this_wave >= enemies_per_wave and active_enemies.size() == 0:
		complete_wave()

func complete_wave():
	wave_completed.emit(current_wave)
	print("EnemySpawner: Wave ", current_wave, " completed!")
	current_wave += 1

	await get_tree().create_timer(3.0).timeout

	if is_spawning:
		start_wave()

func cleanup_all_enemies():
	for enemy in active_enemies.duplicate():
		return_enemy_to_pool(enemy)
	active_enemies.clear()

func get_pool_status() -> String:
	var status = "Pool Status:\n"
	for type_name in enemy_pools.keys():
		var pool = enemy_pools[type_name]
		status += "%s - Active: %d, Available: %d\n" % [type_name, pool.get_active_count(), pool.get_available_count()]
	if projectile_pool:
		status += "Projectiles - Active: %d, Available: %d" % [projectile_pool.get_active_count(), projectile_pool.get_available_count()]
	return status


func _draw():
	if Engine.is_editor_hint() or not use_boundaries:
		return

	var rect = Rect2(
		Vector2(boundary_left, boundary_top),
		Vector2(boundary_right - boundary_left, boundary_bottom - boundary_top)
	)
	draw_rect(rect, Color.RED, false, 2.0)

	var margin_rect = Rect2(
		Vector2(boundary_left - boundary_margin, boundary_top - boundary_margin),
		Vector2(boundary_right - boundary_left + boundary_margin * 2, boundary_bottom - boundary_top + boundary_margin * 2)
	)
	draw_rect(margin_rect, Color.YELLOW, false, 1.0)
