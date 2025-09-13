extends Control

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var enemies_label: Label = $VBoxContainer/EnemiesLabel
@onready var restart_button: Button = $HBoxContainer/RestartButton
@onready var quit_button: Button = $HBoxContainer/QuitButton

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	z_index = 100

func update_stats(time_played: String, enemies_defeated: int):
	time_label.text = "Time Survived: " + time_played
	enemies_label.text = "Enemies Defeated: " + str(enemies_defeated)
	print("GameOverUI: Updated stats - Time: ", time_played, ", Enemies: ", enemies_defeated)

func _on_restart_button_pressed() -> void:
	GameManager.restart_game()

func _on_quit_button_pressed() -> void:
	GameManager.quit_game()
