extends Node2D

@onready var hurt = $Area2D
@onready var sfx = $AudioStreamPlayer2D
@onready var anim = $AnimationPlayer
var body_near:Array[CharacterBody2D]
var damage 

func initialize(buff: Buff_Data) -> void:
	damage = buff.damage
	print("burn buff aktif")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy'):
		body_near.append(body)
		print("body terdeteksi")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('enemy'):
		body_near.erase(body)


func _on_timer_timeout() -> void:
	if not body_near.is_empty():
		for body in body_near:
			if body.has_method("take_damage"):
				body.take_damage(damage)
	else:
		print("burn tidak memberikan damage")
