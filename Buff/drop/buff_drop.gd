extends Node2D
class_name Buff_Drop

@export var Buff:Buff_Data
@onready var Text:Sprite2D = $Sprite2D
@onready var Area = $Area2D
@onready var col:CollisionShape2D = $Area2D/CollisionShape2D
@onready var Collect = $Label

func init(buff:Buff_Data):
	Buff = buff

func _ready() -> void:
	Collect.hide()
	Text.texture = Buff.sprite
	col.shape.radius = Buff.sprite.get_height()

func show_label():
	Collect.show()

func hide_label():
	Collect.hide()
