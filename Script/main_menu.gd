extends Control

@onready var BG = $BGMenu
@onready var Buttons = $VBoxContainer
@onready var credit = $CreditPanel
@onready var back = $CreditPanel/BackBtn
#@onready var yoga = $CreditPanel/Yoga
#@onready var salsa = $CreditPanel/Salsa/PathFollow2D
#@onready var elmo = $CreditPanel/Elmo
#@onready var bintang = $CreditPanel/Bintang
#@onready var dimas = $CreditPanel/Dimas

var speed = 0.5

func _ready() -> void:
	credit.visible = false  

func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/gameplay.tscn")


func _on_credit_btn_pressed() -> void:
	BG.visible = false
	Buttons.visible = false
	credit.visible = true
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_btn_pressed() -> void:
	credit.visible = false
	Buttons.visible = true
	BG.visible = true
