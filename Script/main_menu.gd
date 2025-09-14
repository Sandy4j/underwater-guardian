extends Control

@onready var BG = $BGMenu
@onready var Buttons = $VBoxContainer
@onready var credit = $CreditPanel
@onready var back = $CreditPanel/BackBtn

var speed = 0.5

func _ready() -> void:
	credit.visible = false
	Global.play_bgm(0)

func _on_play_btn_pressed() -> void:
	Global.play_sfx(0)
	get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")
	


func _on_credit_btn_pressed() -> void:
	BG.visible = false
	Buttons.visible = false
	credit.visible = true
	Global.play_sfx(0)
	
func _on_exit_pressed() -> void:
	Global.play_sfx(0)
	get_tree().quit()

func _on_back_btn_pressed() -> void:
	Global.play_sfx(0)
	print("back to menu")
	credit.visible = false
	Buttons.visible = true
	BG.visible = true
