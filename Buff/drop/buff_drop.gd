extends Node2D
class_name Buff_Drop

@export var Buff:Buff_Data
@onready var Text:Sprite2D = $Sprite2D
@onready var Area = $Area2D
@onready var col:CollisionShape2D = $Area2D/CollisionShape2D
@onready var Collect = $Label
@onready var highlight_tween: Tween

func init(buff:Buff_Data):
	Buff = buff

func _ready() -> void:
	Collect.hide()
	Text.texture = Buff.sprite
	col.shape.radius = Buff.sprite.get_height() * Text.scale.x
	setup_highlight_effect()

func setup_highlight_effect():
	# Create a simple glow effect using modulate
	highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_method(update_highlight, 0.7, 1.3, 1.0)
	highlight_tween.tween_method(update_highlight, 1.3, 0.7, 1.0)

func update_highlight(value: float):
	Text.modulate = Color(value, value, value, 1.0)

func show_label():
	Collect.show()
	# Intensify highlight when label is shown
	if highlight_tween:
		highlight_tween.kill()
	highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_method(update_highlight, 1.0, 1.5, 0.5)
	highlight_tween.tween_method(update_highlight, 1.5, 1.0, 0.5)

func hide_label():
	Collect.hide()
	# Return to normal highlight
	if highlight_tween:
		highlight_tween.kill()
	setup_highlight_effect()
