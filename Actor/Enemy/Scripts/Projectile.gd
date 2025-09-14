extends Area2D
class_name HomingProjectile

signal projectile_finished(projectile: HomingProjectile)

@export var speed: float = 120.0
@export var homing_strength: float = 3.0
@export var lifetime: float = 5.0

var target: Node2D
var damage_amount: int
var velocity: Vector2
var life_timer: float

@onready var sprite = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	pass

func setup(target_node: Node2D, damage: int):
	target = target_node
	damage_amount = damage
	life_timer = lifetime
	
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
	
	# Reset visual state
	modulate = Color.WHITE
	scale = Vector2.ONE

func _physics_process(delta):
	life_timer -= delta
	
	if life_timer <= 0:
		finish_projectile()
		return
	
	if not target or not is_instance_valid(target):
		global_position += velocity * delta
		return
	
	var direction_to_target = (target.global_position - global_position).normalized()
	velocity = velocity.lerp(direction_to_target * speed, homing_strength * delta)
	
	global_position += velocity * delta
	rotation = velocity.angle()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
		finish_projectile()

func finish_projectile():
	projectile_finished.emit(self)

func reset_state():
	target = null
	damage_amount = 0
	velocity = Vector2.ZERO
	life_timer = lifetime
	rotation = 0
