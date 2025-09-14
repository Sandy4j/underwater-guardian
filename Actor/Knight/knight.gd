extends CharacterBody2D

@export var base_speed: float = 100.0
@export var speed_variance: float = 30.0  # Speed can vary by this amount
@export var min_direction_time: float = 1.0
@export var max_direction_time: float = 4.0
@export var pause_chance: float = 0.2
@export var pause_duration_min: float = 0.5
@export var pause_duration_max: float = 2.0
@export var sudden_stop_chance: float = 0.1
@export var direction_drift_chance: float = 0.3  # Chance to gradually change direction
@export var max_health: float = 100.0
@export var knockback_force: float = 300.0
@export var knockback_detection_radius: float = 300.0
@export var enemy_threshold: int = 3
@export var knockback_cooldown: float = 5.0

# Movement randomness variables
var current_speed: float
var current_health: float
var is_dead: bool = false
var knockback_timer: float = 0.0
var pause_timer: float = 0.0
var drift_timer: float = 0.0
var zigzag_timer: float = 0.0
var circle_timer: float = 0.0

# Movement pattern variables
enum MovementPattern { RANDOM, ZIGZAG, CIRCLE, WANDER }
var current_pattern: MovementPattern = MovementPattern.RANDOM
var pattern_timer: float = 0.0
var pattern_duration: float = 5.0

signal knight_died
signal knight_damaged(damage: int)
signal healed(amount: int)

const BOUNDARY_LEFT: float = 0.0
const BOUNDARY_TOP: float = 0.0
const BOUNDARY_RIGHT: float = 4320.0
const BOUNDARY_BOTTOM: float = 2430.0

var current_direction: Vector2 = Vector2.ZERO
var target_direction: Vector2 = Vector2.ZERO  # For smooth direction changes
var direction_timer: float = 0.0
var is_paused: bool = false
var rng: RandomNumberGenerator

func _ready():
	$Sprite2d.play("default")
	rng = RandomNumberGenerator.new()
	rng.randomize()
	current_health = max_health
	current_speed = base_speed
	add_to_group("knight")
	_choose_new_direction()
	_choose_random_pattern()
	GlobalSignal.connect("healing", Callable(self,"heal"))

func _physics_process(delta):
	direction_timer -= delta
	knockback_timer -= delta
	pause_timer -= delta
	drift_timer -= delta
	pattern_timer -= delta
	zigzag_timer -= delta
	circle_timer -= delta

	# Change movement pattern occasionally
	if pattern_timer <= 0:
		_choose_random_pattern()
		pattern_timer = rng.randf_range(3.0, 8.0)

	# Handle pauses
	if is_paused and pause_timer <= 0:
		is_paused = false
		_choose_new_direction()

	# Random sudden stops
	if not is_paused and rng.randf() < sudden_stop_chance * delta:
		_sudden_stop()

	# Direction changes
	if direction_timer <= 0:
		_choose_new_direction()
		var time_variance = rng.randf_range(-1.0, 1.0)
		direction_timer = rng.randf_range(min_direction_time, max_direction_time) + time_variance

	# Direction drifting (gradual direction changes)
	if not is_paused and drift_timer <= 0 and rng.randf() < direction_drift_chance:
		_apply_direction_drift()
		drift_timer = rng.randf_range(0.5, 1.5)

	# Check for knockback opportunity
	if knockback_timer <= 0:
		_check_for_knockback()

	# Apply movement pattern
	_apply_movement_pattern(delta)

	if not is_paused:
		# Smooth direction interpolation
		current_direction = current_direction.move_toward(target_direction, delta * 2.0)
		
		velocity = current_direction * current_speed
		move_and_slide()
		_check_boundaries()

		# Sprite flipping
		if current_direction.x > 0:
			$Sprite2d.flip_h = true
		elif current_direction.x < 0:
			$Sprite2d.flip_h = false

func _choose_random_pattern():
	var patterns = [MovementPattern.RANDOM, MovementPattern.ZIGZAG, MovementPattern.CIRCLE, MovementPattern.WANDER]
	current_pattern = patterns[rng.randi() % patterns.size()]
	print("Knight switching to pattern: ", MovementPattern.keys()[current_pattern])

func _apply_movement_pattern(delta):
	match current_pattern:
		MovementPattern.ZIGZAG:
			_apply_zigzag_pattern(delta)
		MovementPattern.CIRCLE:
			_apply_circle_pattern(delta)
		MovementPattern.WANDER:
			_apply_wander_pattern(delta)
		# RANDOM uses the default behavior

func _apply_zigzag_pattern(delta):
	zigzag_timer += delta
	if zigzag_timer > 1.0:  # Change direction every second
		var perpendicular = Vector2(-current_direction.y, current_direction.x)
		if rng.randf() > 0.5:
			perpendicular = -perpendicular
		target_direction = (current_direction + perpendicular * 0.5).normalized()
		zigzag_timer = 0.0

func _apply_circle_pattern(delta):
	circle_timer += delta
	var rotation_speed = 2.0 * (rng.randf_range(0.5, 1.5))
	var angle = circle_timer * rotation_speed
	target_direction = Vector2(cos(angle), sin(angle)).normalized()

func _apply_wander_pattern(delta):
	# Add small random adjustments to direction
	var noise = Vector2(
		rng.randf_range(-0.5, 0.5),
		rng.randf_range(-0.5, 0.5)
	) * delta
	target_direction = (target_direction + noise).normalized()

func _sudden_stop():
	is_paused = true
	current_direction = Vector2.ZERO
	target_direction = Vector2.ZERO
	pause_timer = rng.randf_range(pause_duration_min, pause_duration_max)
	print("Knight suddenly stopped for ", pause_timer, " seconds")

func _apply_direction_drift():
	# Add small random change to current direction
	var drift_angle = rng.randf_range(-PI/4, PI/4)  # Up to 45 degrees
	var current_angle = current_direction.angle()
	var new_angle = current_angle + drift_angle
	target_direction = Vector2(cos(new_angle), sin(new_angle)).normalized()

func _randomize_speed():
	current_speed = base_speed + rng.randf_range(-speed_variance, speed_variance)
	current_speed = max(current_speed, base_speed * 0.3)  # Don't go too slow

func _check_for_knockback():
	var space_state = get_world_2d().direct_space_state
	var enemies_nearby = []

	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = knockback_detection_radius
	query.shape = shape
	query.transform = global_transform
	query.collision_mask = 2

	var results = space_state.intersect_shape(query)

	for result in results:
		if result.collider.is_in_group("enemy") and result.collider != self:
			enemies_nearby.append(result.collider)

	if enemies_nearby.size() >= enemy_threshold:
		_perform_knockback(enemies_nearby)
		knockback_timer = knockback_cooldown

func _perform_knockback(enemies: Array):
	print("Knight performing knockback on ", enemies.size(), " enemies!")

	for enemy in enemies:
		if enemy.has_method("apply_knockback"):
			var knockback_direction = (enemy.global_position - global_position).normalized()
			enemy.apply_knockback(knockback_direction, knockback_force)
			
	_create_knockback_ring()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.CYAN, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)

func _create_knockback_ring():
	var ring = Line2D.new()
	get_parent().add_child(ring)

	var points = []
	var segments = 32
	var radius = 50.0

	for i in range(segments + 1):
		var angle = (i * TAU) / segments
		var point = Vector2(cos(angle), sin(angle)) * radius
		points.append(point)

	ring.points = PackedVector2Array(points)
	ring.width = 8.0
	ring.default_color = Color(0.0, 1.0, 1.0, 0.8)
	ring.position = global_position

	var tween = create_tween()
	tween.parallel().tween_property(ring, "scale", Vector2(5.0, 5.0), 0.5)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.5)
	tween.tween_callback(ring.queue_free)
	
func _choose_new_direction() -> void:
	# Random pause
	if rng.randf() < pause_chance:
		is_paused = true
		current_direction = Vector2.ZERO
		target_direction = Vector2.ZERO
		pause_timer = rng.randf_range(pause_duration_min, pause_duration_max)
		return

	is_paused = false
	_randomize_speed()  # Change speed with each direction change

	var pos = global_position
	var angle: float
	var angle_variance = PI / 6  # Add more randomness to angles

	# Boundary-aware direction selection with more randomness
	if pos.x <= BOUNDARY_LEFT + 100:
		angle = rng.randf_range(-PI / 4 - angle_variance, PI / 4 + angle_variance)
	elif pos.x >= BOUNDARY_RIGHT - 100:
		angle = rng.randf_range(3 * PI / 4 - angle_variance, 5 * PI / 4 + angle_variance)
	elif pos.y <= BOUNDARY_TOP + 100:
		angle = rng.randf_range(PI / 4 - angle_variance, 3 * PI / 4 + angle_variance)
	elif pos.y >= BOUNDARY_BOTTOM - 100:
		angle = rng.randf_range(-3 * PI / 4 - angle_variance, -PI / 4 + angle_variance)
	else:
		# More varied random angles
		if rng.randf() < 0.3:  # 30% chance for completely random direction
			angle = rng.randf() * TAU
		else:  # 70% chance for direction influenced by current direction
			var current_angle = current_direction.angle()
			angle = current_angle + rng.randf_range(-PI/2, PI/2)

	target_direction = Vector2(cos(angle), sin(angle)).normalized()

func _check_boundaries():
	var pos = global_position
	var direction_changed: bool = false

	if pos.x <= BOUNDARY_LEFT and current_direction.x < 0:
		current_direction.x = abs(current_direction.x)
		target_direction.x = abs(target_direction.x)
		direction_changed = true

	if pos.x >= BOUNDARY_RIGHT and current_direction.x > 0:
		current_direction.x = -abs(current_direction.x)
		target_direction.x = -abs(target_direction.x)
		direction_changed = true

	if pos.y <= BOUNDARY_TOP and current_direction.y < 0:
		current_direction.y = abs(current_direction.y)
		target_direction.y = abs(target_direction.y)
		direction_changed = true

	if pos.y >= BOUNDARY_BOTTOM and current_direction.y > 0:
		current_direction.y = -abs(current_direction.y)
		target_direction.y = -abs(target_direction.y)
		direction_changed = true

	if direction_changed:
		current_direction = current_direction.normalized()
		target_direction = target_direction.normalized()
		direction_timer = rng.randf_range(min_direction_time, max_direction_time) * 0.5
		_randomize_speed()

func _on_obstacle_hit():
	_choose_new_direction()
	direction_timer = rng.randf_range(min_direction_time, max_direction_time)

func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount
	knight_damaged.emit(amount)

	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	print("Knight took ", amount, " damage. Health: ", current_health, "/", max_health)

	# Damage can cause erratic movement
	if rng.randf() < 0.4:  # 40% chance to change direction when damaged
		_choose_new_direction()

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return
	
	await get_tree().create_timer(0.5).timeout 
	is_dead = true
	knight_died.emit()

	current_direction = Vector2.ZERO
	target_direction = Vector2.ZERO
	velocity = Vector2.ZERO

	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)

func heal(amount: int):
	if is_dead:
		return

	current_health = min(current_health + amount, max_health)

#func _draw():
	#if Engine.is_editor_hint():
		#return
#
	#if not is_paused and current_direction != Vector2.ZERO:
		## Draw current direction
		#draw_line(Vector2.ZERO, current_direction * 50, Color.RED, 2.0)
		#
		## Draw target direction (if different)
		#if current_direction.distance_to(target_direction) > 0.1:
			#draw_line(Vector2.ZERO, target_direction * 40, Color.ORANGE, 1.0)
#
		#var arrow_size: int = 10
		#var arrow_angle: float = 0.5
		#var end_pos = current_direction * 50
		#var left_wing = end_pos + Vector2(cos(current_direction.angle() + PI - arrow_angle), sin(current_direction.angle() + PI - arrow_angle)) * arrow_size
		#var right_wing = end_pos + Vector2(cos(current_direction.angle() + PI + arrow_angle), sin(current_direction.angle() + PI + arrow_angle)) * arrow_size
		#draw_line(end_pos, left_wing, Color.RED, 2.0)
		#draw_line(end_pos, right_wing, Color.RED, 2.0)
#
	## Draw knockback detection radius
	#if knockback_timer <= 0:
		#draw_circle(Vector2.ZERO, knockback_detection_radius, Color(0, 1, 1, 0.1))
