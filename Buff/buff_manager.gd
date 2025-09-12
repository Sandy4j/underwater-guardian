extends Node2D
class_name Buff_Manager

@onready var Sword_buff = preload("res://Buff/sword_buff.tscn")
@onready var Burn_buff  = preload("res://Buff/burn_buff.tscn")
@onready var Sword_Bar =  $CanvasLayer/ProgressBar1
@onready var Burn_Bar =  $CanvasLayer/ProgressBar2
var active_buff:Array[Buff_Data]
var Player:CharacterBody2D

var sword_buff_active:bool = false
var sword_buff_duration:float
var sword_buff_max_duration:float
var burn_buff_active:bool = false
var burn_buff_duration:float
var burn_buff_max_duration:float

func _ready() -> void:
	Player = get_parent()
	GlobalSignal.connect("activate_buff", Callable(self,"apply_buff"))

func _physics_process(delta: float) -> void:
	if sword_buff_active:
		handle_Sword_buff(delta)
	if burn_buff_active:
		handle_Burn_buff(delta)

func handle_Sword_buff(delta:float) -> void:
	sword_buff_duration += delta
	Sword_Bar.value = sword_buff_duration
	if sword_buff_duration >= sword_buff_max_duration:
		sword_buff_active = false
		expired_buff(GlobalSignal.tipe.Murim)
		sword_buff_duration = 0

func handle_Burn_buff(delta:float) -> void:
	burn_buff_duration += delta
	Burn_Bar.value = sword_buff_duration
	if burn_buff_duration >= burn_buff_max_duration:
		burn_buff_active = false
		expired_buff(GlobalSignal.tipe.Radiance)
		burn_buff_duration = 0

func apply_buff(Buff:Buff_Data):
	if not active_buff.is_empty():
		for BUFF in active_buff:
			print(BUFF.name)
			if Buff.name == BUFF.name:
				print("buff yang sama ketemu")
				Prolonged_buff(BUFF, Buff)
				return
	
	match Buff.tipe:
		GlobalSignal.tipe.Radiance:
			var buff = Burn_buff.instantiate()
			add_child(buff)
			buff.initialize(Buff) 
			Buff.node = buff
			active_buff.append(Buff)
			burn_buff_max_duration = Buff.duration
			Burn_Bar.max_value = burn_buff_max_duration
			burn_buff_active = true
		GlobalSignal.tipe.Murim:
			var buff = Sword_buff.instantiate()
			add_child(buff)
			buff.initialize(Buff)
			Buff.node = buff
			active_buff.append(Buff)
			sword_buff_max_duration = Buff.duration
			Sword_Bar.max_value = sword_buff_max_duration
			sword_buff_active = true

func Prolonged_buff(act_buff:Buff_Data, buff:Buff_Data):
	match act_buff.tipe:
		GlobalSignal.tipe.Radiance:
			print("buff bakar numpuk")
			burn_buff_max_duration += buff.duration
			Burn_Bar.max_value = burn_buff_max_duration
		GlobalSignal.tipe.Murim:
			print("buff pedang numpuk")
			sword_buff_max_duration += buff.duration
			Sword_Bar.max_value = sword_buff_max_duration

func expired_buff(buff_tipe:GlobalSignal.tipe):
	for buffs in active_buff:
		if buffs.tipe == buff_tipe:
			buffs.node.queue_free()
			active_buff.erase(buffs)
