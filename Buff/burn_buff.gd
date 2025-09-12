extends Node2D

@onready var hurt = $Area2D
var body_near:Array[CharacterBody2D]
var damage 

func initialize(buff: Buff_Data) -> void:
	damage = buff.damage
	print("burn buff aktif")

func _on_area_2d_body_entered(body: Node2D) -> void:
	body_near.append(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	body_near.erase(body)


func _on_timer_timeout() -> void:
	if not body_near.is_empty():
		for body in body_near:
			print("burn memberikan damage " + str(damage) + " ke " + body.name)
	else:
		print("burn tidak memberikan damage")
