extends CharacterBody2D

@export var speed: float = 100.0
@export var direction_change_time: float = 2.0
@export var pause_chance: float = 0.2

const BOUNDARY_LEFT: float = 0.0
const BOUNDARY_TOP: float = 0.0
const BOUNDARY_RIGHT: float = 2200.0
const BOUNDARY_BOTTOM: float = 1200.0

var current_direction: Vector2 = Vector2.ZERO
var direction_timer: float = 0.0
var is_paused: bool = false
var rng: RandomNumberGenerator

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	_choose_new_direction()

func _physics_process(delta):
	direction_timer -= delta
	
	if direction_timer <= 0:
		_choose_new_direction()
		direction_timer = direction_change_time + rng.randf_range(-0.5, 0.5)
	
	if not is_paused:
		velocity = current_direction * speed
		move_and_slide()
		
		_check_boundaries()

func _choose_new_direction():
	if rng.randf() < pause_chance:
		is_paused = true
		current_direction = Vector2.ZERO
		return
	
	is_paused = false
	
	var angle = rng.randf() * TAU  # TAU is 2*PI in Godot 4
	current_direction = Vector2(cos(angle), sin(angle)).normalized()

func _check_boundaries():
	var pos = global_position
	var direction_changed = false
	
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
	"""Call this function when the AI hits an obstacle to change direction"""
	_choose_new_direction()
	direction_timer = direction_change_time

func _draw():
	if Engine.is_editor_hint():
		return
	
	if not is_paused and current_direction != Vector2.ZERO:
		draw_line(Vector2.ZERO, current_direction * 50, Color.RED, 2.0)

		var arrow_size = 10
		var arrow_angle = 0.5
		var end_pos = current_direction * 50
		var left_wing = end_pos + Vector2(cos(current_direction.angle() + PI - arrow_angle), sin(current_direction.angle() + PI - arrow_angle)) * arrow_size
		var right_wing = end_pos + Vector2(cos(current_direction.angle() + PI + arrow_angle), sin(current_direction.angle() + PI + arrow_angle)) * arrow_size
		draw_line(end_pos, left_wing, Color.RED, 2.0)
		draw_line(end_pos, right_wing, Color.RED, 2.0)
