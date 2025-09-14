extends Node

signal game_over
signal enemy_defeated

enum tipe{
	Null,
	Radiance,
	Murim,
	KingVon,
	Doa
}
var is_game_over: bool = false
var start_time: float
var enemies_defeated: int = 0
var play_time: float = 0.0

func _ready():
	start_time = Time.get_unix_time_from_system()

func _process(delta):
	if not is_game_over:
		play_time += delta

func start_new_game():
	is_game_over = false
	enemies_defeated = 0
	play_time = 0.0
	start_time = Time.get_unix_time_from_system()

	# Find and connect to knight
	var knight = get_tree().get_first_node_in_group("knight")
	if knight and not knight.knight_died.is_connected(_on_knight_died):
		knight.knight_died.connect(_on_knight_died)

	# Find and connect to spawner
	var spawner = get_tree().get_first_node_in_group("spawner")
	if spawner and not spawner.enemy_spawned.is_connected(_on_enemy_spawned):
		spawner.enemy_spawned.connect(_on_enemy_spawned)

func _on_knight_died():
	if is_game_over:
		return

	is_game_over = true
	get_tree().paused = true
	game_over.emit()

func _on_enemy_spawned(enemy):
	if not enemy.enemy_died.is_connected(_on_enemy_died):
		enemy.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy):
	enemies_defeated += 1
	enemy_defeated.emit()

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game():
	get_tree().quit()

func get_formatted_time() -> String:
	var minutes = int(play_time) / 60
	var seconds = int(play_time) % 60
	return "%02d:%02d" % [minutes, seconds]
