extends Resource
class_name EnemyTypeData

@export_group("Basic Settings")
@export var type_name: String = ""
@export var scene: PackedScene
@export var spawn_weight: float = 1.0
@export var unlock_time_minutes: float = 0.0  # When this enemy type becomes available
@export var max_time_minutes: float = 0.0     # When this enemy type stops spawning (0 = no limit)
@export var time_weight_curve: Array[float] = [] # Weight multiplier per minute interval
@export var initial_pool_size: int = 10
@export var max_pool_size: int = 50

@export_group("Stat Overrides")
@export var override_stats: bool = false
@export var base_health: float = 0
@export var base_damage: int = 0
@export var base_speed: float = 0

func _init():
	type_name = "NewEnemyType"
	spawn_weight = 1.0
	unlock_time_minutes = 0.0
	max_time_minutes = 0.0
	time_weight_curve = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
	initial_pool_size = 10
	max_pool_size = 50
	override_stats = false