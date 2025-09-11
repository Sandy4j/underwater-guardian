extends Node2D

@onready var sprite = $Sword/Area2D/CollisionShape2D
@onready var hurt_bux = $Sword/Area2D
@onready var anim = $AnimationPlayer
var damage:int

func initialize(buff: Buff_Data) -> void:
	damage = buff.damage
	anim.play("Muter")
	print("Sword buff aktif")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("damage" + str(damage))

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
