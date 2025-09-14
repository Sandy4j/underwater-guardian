extends CharacterBody2D

@export var speed: float = 100.0
@export var direction_change_time: float = 2.0
@export var pause_chance: float = 0.2
@export var max_health: float = 100.0
@export var knockback_force: float = 300.0
@export var knockback_detection_radius: float = 300.0
@export var enemy_threshold: int = 3
@export var knockback_cooldown: float = 5.0

var current_health: float
var is_dead: bool = false
var knockback_timer: float = 0.0

signal knight_died
signal knight_damaged(damage: int)

const BOUNDARY_LEFT: float = 0.0
const BOUNDARY_TOP: float = 0.0
const BOUNDARY_RIGHT: float = 2200.0
const BOUNDARY_BOTTOM: float = 1200.0

var current_direction: Vector2 = Vector2.ZERO
var direction_timer: float = 0.0
var is_paused: bool = false
var rng: RandomNumberGenerator

func _ready():
	$Sprite2d.play("default")
	rng = RandomNumberGenerator.new()
	rng.randomize()
	current_health = max_health
	add_to_group("knight")
	_choose_new_direction()

func _physics_process(delta):
	direction_timer -= delta
	knockback_timer -= delta

	if direction_timer <= 0:
		_choose_new_direction()
		direction_timer = direction_change_time + rng.randf_range(-0.5, 0.5)

	# Check for knockback opportunity
	if knockback_timer <= 0:
		_check_for_knockback()

	if not is_paused:
		velocity = current_direction * speed
		move_and_slide()
		_check_boundaries()

		if current_direction.x > 0:
			$Sprite2d.flip_h = true
		elif current_direction.x < 0:
			$Sprite2d.flip_h = false

func _check_for_knockback():
	var space_state = get_world_2d().direct_space_state
	var enemies_nearby = []

	# Get all bodies in detection radius
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = knockback_detection_radius
	query.shape = shape
	query.transform = global_transform
	query.collision_mask = 2  # Adjust collision mask as needed

	var results = space_state.intersect_shape(query)

	# Count enemies (assuming they're in "enemies" group)
	for result in results:
		if result.collider.is_in_group("enemy") and result.collider != self:
			enemies_nearby.append(result.collider)

	# Trigger knockback if threshold is met
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

	# Create circle points
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

	# Animate
	var tween = create_tween()
	tween.parallel().tween_property(ring, "scale", Vector2(5.0, 5.0), 0.5)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.5)
	tween.tween_callback(ring.queue_free)
	
func _choose_new_direction() -> void:
	if rng.randf() < pause_chance:
		is_paused = true
		current_direction = Vector2.ZERO
		return

	is_paused = false

	var pos = global_position
	var angle: float

	if pos.x <= BOUNDARY_LEFT + 100:
		angle = rng.randf_range(-PI / 4, PI / 4)
	elif pos.x >= BOUNDARY_RIGHT - 100:
		angle = rng.randf_range(3 * PI / 4, 5 * PI / 4)
	elif pos.y <= BOUNDARY_TOP + 100:
		angle = rng.randf_range(PI / 4, 3 * PI / 4)
	elif pos.y >= BOUNDARY_BOTTOM - 100:
		angle = rng.randf_range(-3 * PI / 4, -PI / 4)
	else:
		angle = rng.randf() * TAU

	current_direction = Vector2(cos(angle), sin(angle)).normalized()

func _check_boundaries():
	var pos = global_position
	var direction_changed: bool = false

	if pos.x <= BOUNDARY_LEFT and current_direction.x < 0:
		current_direction.x = abs(current_direction.x)
		direction_changed = true

	if pos.x >= BOUNDARY_RIGHT and current_direction.x > 0:
		current_direction.x = -abs(current_direction.x)
		direction_changed = true

	if pos.y <= BOUNDARY_TOP and current_direction.y < 0:
		current_direction.y = abs(current_direction.y)
		direction_changed = true

	if pos.y >= BOUNDARY_BOTTOM and current_direction.y > 0:
		current_direction.y = -abs(current_direction.y)
		direction_changed = true

	if direction_changed:
		current_direction = current_direction.normalized()
		direction_timer = direction_change_time * 0.5

func _on_obstacle_hit():
	_choose_new_direction()
	direction_timer = direction_change_time

func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount
	knight_damaged.emit(amount)

	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

	print("Knight took ", amount, " damage. Health: ", current_health, "/", max_health)

	if current_health <= 0:
		die()

func die():
	if is_dead:
		return
	
	await get_tree().create_timer(0.5).timeout 
	is_dead = true
	knight_died.emit()

	current_direction = Vector2.ZERO
	velocity = Vector2.ZERO

	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)

func heal(amount: int):
	if is_dead:
		return

	current_health = min(current_health + amount, max_health)
	print("Knight healed for ", amount, ". Health: ", current_health, "/", max_health)

func _draw():
	if Engine.is_editor_hint():
		return

	if not is_paused and current_direction != Vector2.ZERO:
		draw_line(Vector2.ZERO, current_direction * 50, Color.RED, 2.0)

		var arrow_size: int = 10
		var arrow_angle: float = 0.5
		var end_pos = current_direction * 50
		var left_wing = end_pos + Vector2(cos(current_direction.angle() + PI - arrow_angle), sin(current_direction.angle() + PI - arrow_angle)) * arrow_size
		var right_wing = end_pos + Vector2(cos(current_direction.angle() + PI + arrow_angle), sin(current_direction.angle() + PI + arrow_angle)) * arrow_size
		draw_line(end_pos, left_wing, Color.RED, 2.0)
		draw_line(end_pos, right_wing, Color.RED, 2.0)

	# Draw knockback detection radius (optional debug visualization)
	if knockback_timer <= 0:
		draw_circle(Vector2.ZERO, knockback_detection_radius, Color(0, 1, 1, 0.1))
