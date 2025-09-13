extends Node2D

@onready var spawner: EnemySpawner = $EnemySpawner
@onready var stats_label: Label = $UI/Control/Panel/StatsLabel
@onready var healthbar: ProgressBar = $UI/Control/HealthBar
@onready var game_over_ui: Control = $UI/Gameover

var knight: CharacterBody2D

func _ready():
	spawner.add_to_group("spawner")
	knight = get_tree().get_first_node_in_group("knight")

	# Hide game over UI initially
	if game_over_ui:
		game_over_ui.hide()

	# Start new game and connect signals
	GameManager.start_new_game()

	# Connect GameManager signals
	if not GameManager.game_over.is_connected(_on_game_over):
		GameManager.game_over.connect(_on_game_over)
	if not GameManager.enemy_defeated.is_connected(_on_enemy_defeated):
		GameManager.enemy_defeated.connect(_on_enemy_defeated)

	print("GameManager signals connected")

	if knight:
		knight.knight_damaged.connect(_on_knight_damaged)
		print("Knight found and connected")
	else:
		print("Warning: Knight not found!")

	if healthbar:
		style_healthbar()

func _process(_delta):
	# Update stats display using singleton
	if stats_label and not GameManager.is_game_over:
		stats_label.text = "Time: %s | Enemies: %d" % [GameManager.get_formatted_time(), GameManager.enemies_defeated]

	# Update health display
	if knight and healthbar:
		if not knight.is_dead:
			healthbar.value = knight.current_health
			healthbar.max_value = knight.max_health
		else:
			healthbar.value = 0

func style_healthbar():
	# Create custom StyleBox for background
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color.DARK_RED
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color.BLACK
	bg_style.corner_radius_top_left = 5
	bg_style.corner_radius_top_right = 5
	bg_style.corner_radius_bottom_left = 5
	bg_style.corner_radius_bottom_right = 5

	# Create custom StyleBox for fill
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color.GREEN
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3

	# Apply styles to health bar
	healthbar.add_theme_stylebox_override("background", bg_style)
	healthbar.add_theme_stylebox_override("fill", fill_style)

	# Optional: Change color based on health percentage
	healthbar.value_changed.connect(_on_health_changed)

func _on_health_changed(value: float):
	var health_percentage = value / healthbar.max_value
	var fill_style = healthbar.get_theme_stylebox("fill")

	if health_percentage > 0.6:
		fill_style.bg_color = Color.GREEN
	elif health_percentage > 0.3:
		fill_style.bg_color = Color.YELLOW
	else:
		fill_style.bg_color = Color.RED

func _on_enemy_spawned(enemy):
	# GameManager handles enemy tracking now
	pass

func _on_game_over():
	print("Game over signal received!")
	spawner.stop_spawning()

	# Show and update game over UI
	if game_over_ui:
		game_over_ui.show()
		if game_over_ui.has_method("update_stats"):
			var time_string = GameManager.get_formatted_time()
			game_over_ui.update_stats(time_string, GameManager.enemies_defeated)	

func _on_enemy_defeated():
	# Optional: Add visual/audio feedback for enemy defeats
	pass

func _on_knight_damaged(damage: int):
	# Optional: Add visual feedback for knight taking damage
	pass
