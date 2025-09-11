extends Node2D
class_name Buff_Drop

@export var Buff:Buff_Data
@onready var Text = $Sprite2D
@onready var Area = $Area2D

func _ready() -> void:
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('Player'):
		queue_free()


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
