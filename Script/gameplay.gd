extends Node2D

@onready var spawner: EnemySpawner = $EnemySpawner
@onready var wave_label: Label = $UI/WaveLabel
@onready var debug_label: Label = $UI/Debug

func _ready():
	spawner.wave_started.connect(_on_wave_started)
	spawner.wave_completed.connect(_on_wave_completed)
	spawner.enemy_spawned.connect(_on_enemy_spawned)
	# If you turned off auto_start in the spawner:
	# spawner.start_spawning()

func _on_wave_started(wave_number: int):
	wave_label.text = "Wave: %d" % wave_number

func _on_wave_completed(wave_number: int):
	print("Wave %d complete" % wave_number)

func _on_enemy_spawned(enemy):
	# Hook for trackers, UI counters, etc.
	pass

func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		debug_label.text = spawner.get_pool_status()
