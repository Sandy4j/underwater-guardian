extends Control

@onready var background_texture: TextureRect = $Background
@onready var time_label: Label = $StatContainer/TimeLabel
@onready var enemies_label: Label = $StatContainer/EnemiesLabel
@onready var restart_button: Button = $BtnContainer/RestartButton
@onready var quit_button: Button = $BtnContainer/QuitButton

var tween: Tween

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	z_index = 100
	setup_ui_styling()
	animate_entrance()
	Global.play_sfx(1)

func setup_ui_styling():
	# Setup the background texture to fill the screen
	background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_texture.anchor_left = 0
	background_texture.anchor_right = 1
	background_texture.anchor_top = 0
	background_texture.anchor_bottom = 1
	
	# Setup stats labels styling
	setup_label_style(time_label, 28)
	setup_label_style(enemies_label, 28)
	
	# Setup button styling to complement the ocean theme
	setup_button_style(restart_button, Color(0.2, 0.6, 0.4, 0.9), Color(0.25, 0.7, 0.45, 1.0))  # Ocean green
	setup_button_style(quit_button, Color(0.6, 0.3, 0.2, 0.9), Color(0.7, 0.35, 0.25, 1.0))    # Coral red

func setup_label_style(label: Label, font_size: int):
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))  # Bright white-blue
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.1, 0.2, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)

func setup_button_style(button: Button, normal_color: Color, hover_color: Color):
	# Normal state
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = normal_color
	normal_style.border_color = normal_color.lightened(0.3)
	normal_style.border_width_left = 3
	normal_style.border_width_right = 3
	normal_style.border_width_top = 3
	normal_style.border_width_bottom = 3
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_left = 10
	normal_style.corner_radius_bottom_right = 10
	normal_style.shadow_color = Color(0.0, 0.0, 0.0, 0.4)
	normal_style.shadow_size = 5
	normal_style.shadow_offset = Vector2(0, 3)
	button.add_theme_stylebox_override("normal", normal_style)
	
	# Hover state
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = hover_color
	hover_style.border_color = hover_color.lightened(0.3)
	hover_style.border_width_left = 3
	hover_style.border_width_right = 3
	hover_style.border_width_top = 3
	hover_style.border_width_bottom = 3
	hover_style.corner_radius_top_left = 10
	hover_style.corner_radius_top_right = 10
	hover_style.corner_radius_bottom_left = 10
	hover_style.corner_radius_bottom_right = 10
	hover_style.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	hover_style.shadow_size = 7
	hover_style.shadow_offset = Vector2(0, 4)
	button.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed state
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = normal_color.darkened(0.3)
	pressed_style.border_color = normal_color
	pressed_style.border_width_left = 3
	pressed_style.border_width_right = 3
	pressed_style.border_width_top = 3
	pressed_style.border_width_bottom = 3
	pressed_style.corner_radius_top_left = 10
	pressed_style.corner_radius_top_right = 10
	pressed_style.corner_radius_bottom_left = 10
	pressed_style.corner_radius_bottom_right = 10
	pressed_style.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
	pressed_style.shadow_size = 3
	pressed_style.shadow_offset = Vector2(0, 1)
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Text styling
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 1)

func animate_entrance():
	# Start with everything transparent and stats panel scaled down
	background_texture.modulate.a = 0.0
	
	# Animate the entrance
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	# First fade in the background image
	tween.tween_property(background_texture, "modulate:a", 1.0, 0.5)
	
	# Then animate the stats panel
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_callback(start_floating_animation)

func start_floating_animation():
	var float_tween = create_tween()
	float_tween.set_loops()
	float_tween.set_ease(Tween.EASE_IN_OUT)
	float_tween.set_trans(Tween.TRANS_SINE)

func update_stats(time_played: String, enemies_defeated: int):
	time_label.text = "Time Survived: " + time_played
	enemies_label.text = "Enemies Defeated: " + str(enemies_defeated)
	print("GameOverUI: Updated stats - Time: ", time_played, ", Enemies: ", enemies_defeated)
	
	# Add a subtle pulse animation to the stats
	animate_stats_update()

func animate_stats_update():
	var pulse_tween = create_tween()
	pulse_tween.set_ease(Tween.EASE_OUT)
	pulse_tween.set_trans(Tween.TRANS_ELASTIC)
	
	# Pulse the labels
	pulse_tween.parallel().tween_property(time_label, "scale", Vector2(1.15, 1.15), 0.3)
	pulse_tween.parallel().tween_property(enemies_label, "scale", Vector2(1.15, 1.15), 0.3)
	
	pulse_tween.parallel().tween_property(time_label, "scale", Vector2(1.0, 1.0), 0.4)
	pulse_tween.parallel().tween_property(enemies_label, "scale", Vector2(1.0, 1.0), 0.4)

func _on_restart_button_pressed() -> void:
	Global.play_sfx(1)
	animate_button_press(restart_button)
	animate_exit("restart")

func _on_quit_button_pressed() -> void:
	Global.play_sfx(1)
	animate_button_press(quit_button)
	animate_exit("quit")

func animate_button_press(button: Button):
	var press_tween = create_tween()
	press_tween.set_ease(Tween.EASE_OUT)
	press_tween.set_trans(Tween.TRANS_ELASTIC)
	
	press_tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	press_tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.15)
	press_tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

func animate_exit(action: String):
	var exit_tween = create_tween()
	exit_tween.set_ease(Tween.EASE_IN)
	exit_tween.set_trans(Tween.TRANS_QUART)
	exit_tween.tween_property(background_texture, "modulate:a", 0.0, 0.3)
	
	await exit_tween.finished
	
	if action == "restart":
		GameManager.restart_game()
	elif action == "quit":
		GameManager.quit_game()
