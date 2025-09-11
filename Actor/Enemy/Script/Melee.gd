extends BaseEnemy
class_name MeleeEnemy

@export var attack_range: float = 30.0
@export var attack_cooldown: float = 1.0

var can_attack: bool = true

func _ready():
	super._ready()
	max_health = 80.0
	move_speed = 70.0
	damage = 15
	current_health = max_health

func move_towards_player(delta: float):
	if not player or is_dead:
		return
	
	var distance_to_player = get_distance_to_player()
	var direction = (player.global_position - global_position).normalized()
	
	if distance_to_player <= attack_range and can_attack:
		perform_attack()
		return

	velocity = direction * move_speed
	move_and_slide()

func perform_attack():
	if not can_attack:
		return
	
	can_attack = false

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Deal damage to player if still in range
	if get_distance_to_player() <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(damage)
	
	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
