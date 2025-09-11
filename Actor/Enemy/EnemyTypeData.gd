extends Resource
class_name EnemyTypeData

@export_group("Basic Settings")
@export var type_name: String = ""
@export var scene: PackedScene
@export var spawn_weight: float = 1.0

@export_group("Wave Configuration")
@export var unlock_wave: int = 1
@export var max_wave: int = 0 # 0 = no limit
@export var wave_weight_curve: Array[float] = [] # Weight multiplier per wave

@export_group("Pool Settings")
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
	unlock_wave = 1
	max_wave = 0
	initial_pool_size = 10
	max_pool_size = 50
	override_stats = false
