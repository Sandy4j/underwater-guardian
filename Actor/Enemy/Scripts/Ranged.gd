extends BaseEnemy
class_name RangedEnemy

@export var attack_range: float = 150.0
@export var min_range: float = 80.0
@export var attack_cooldown: float = 2.0
@export var projectile_scene: PackedScene

var can_attack: bool = true

func _ready():
	super._ready()
	max_health = 60.0
	move_speed = 40.0
	damage = 20
	current_health = max_health

func move_towards_player(delta: float):
	if not player or is_dead:
		return
	
	var distance_to_player = get_distance_to_player()
	var direction = (player.global_position - global_position).normalized()
	if distance_to_player <= attack_range and distance_to_player >= min_range and can_attack:
		perform_ranged_attack()
	
	# Movement logic
	if distance_to_player > attack_range:
		# Move closer
		velocity = direction * move_speed
	elif distance_to_player < min_range:
		velocity = -direction * move_speed
	else:
		var perpendicular = Vector2(-direction.y, direction.x)
		velocity = perpendicular * move_speed * 0.5
	
	move_and_slide()

func perform_ranged_attack():
	if not can_attack or not projectile_scene:
		return
	
	can_attack = false
	
	sprite.modulate = Color.CYAN
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	spawn_homing_projectile()
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func spawn_homing_projectile():
	if not player:
		return

	# Use ProjectileManager singleton
	if ProjectileManager:
		ProjectileManager.spawn_homing_projectile(global_position, player, damage)
	else:
		# Fallback method
		var projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position
		projectile.setup(player, damage)
