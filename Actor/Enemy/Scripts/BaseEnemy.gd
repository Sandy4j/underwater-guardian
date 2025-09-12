extends CharacterBody2D
class_name BaseEnemy

signal enemy_died(enemy: BaseEnemy)
signal enemy_damaged(damage: int)

@export var max_health: float = 100.0
@export var move_speed: float = 50.0
@export var damage: int = 10

var current_health: float
var player: CharacterBody2D
var is_dead: bool = false
var is_knockedback: bool = false
var knockback_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var damage_area: Area2D = $DamageArea

func _ready():
	current_health = max_health
	player = get_tree().get_first_node_in_group("knight")
	damage_area.body_entered.connect(_on_damage_area_entered)
	
func _physics_process(delta):
	if is_dead or not player:
		return
	
	if is_knockedback:
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knockedback = false
	if not is_knockedback:
		move_towards_player(delta)
	else:
		move_and_slide()

func move_towards_player(delta: float):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

func take_damage(amount: int):
	if is_dead:
		return
	
	current_health -= amount
	enemy_damaged.emit(amount)
	
	# Visual feedback
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		die()

func apply_knockback(direction: Vector2, force: float):
	is_knockedback = true
	knockback_timer = 0.2

	velocity = direction * force
	print("pushed ", direction * force)
	
func die():
	if is_dead:
		return
	
	is_dead = true
	enemy_died.emit(self)
	
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _on_damage_area_entered(body):
	if body.is_in_group("knight"):
		body.take_damage(damage)

func get_distance_to_player() -> float:
	if player:
		return global_position.distance_to(player.global_position)
	return 999999.0
	
func reset_state():
	is_dead = false
	current_health = max_health
	modulate = Color.WHITE
	scale = Vector2.ONE
	velocity = Vector2.ZERO
