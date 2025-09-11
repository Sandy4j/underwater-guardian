extends Node2D

@onready var hurt = $Area2D
var damage 

func initialize(buff: Buff_Data) -> void:
	damage = buff.damage
	print("burn buff aktif")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("damage" + str(damage))

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
