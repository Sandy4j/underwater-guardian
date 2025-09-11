extends Node2D
class_name Buff_Manager

@onready var Sword_buff = preload("res://Buff/sword_buff.tscn")
@onready var Burn_buff  = preload("res://Buff/burn_buff.tscn")
var Player:CharacterBody2D

func _ready() -> void:
	Player = get_parent()
	GlobalSignal.connect("activate_buff", Callable(self,"apply_buff"))

func apply_buff(Buff:Buff_Data):
	match Buff.tipe:
		GlobalSignal.tipe.Radiance:
			var buff = Burn_buff.instantiate()
			add_child(buff)
			buff.initialize(Buff) 
		GlobalSignal.tipe.Murim:
			var buff = Sword_buff.instantiate()
			add_child(buff)
			buff.initialize(Buff)
