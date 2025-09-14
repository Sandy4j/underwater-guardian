extends Node

signal game_paused
signal game_resumed

var is_paused: bool = false
@onready var pause_ui: Control = $Pause
@onready var resume_button: Button =$VBoxContainer/ResumeBtn
@onready var quit_button: Button =$VBoxContainer/ExitBtn

func _ready():
	# Set process mode to always so this script continues running when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_ui.hide()

func _input(event):
	if event.is_action_pressed("pause") and not GameManager.is_game_over:
		toggle_pause()

func toggle_pause():
	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game():
	if GameManager.is_game_over:
		return  # Don't allow pausing when game is over
	
	is_paused = true
	get_tree().paused = true
	
	if pause_ui:
		pause_ui.show()
	
	game_paused.emit()
	print("Game paused")

func resume_game():
	is_paused = false
	get_tree().paused = false
	
	if pause_ui:
		pause_ui.hide()
	
	game_resumed.emit()
	print("Game resumed")

func _on_resume_btn_pressed() -> void:
	resume_game()

func _on_exit_btn_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
