extends Node2D

@onready var Projectile = preload("res://Buff/Buhell_Projectile.tscn")
@onready var Area = $Area2D
@onready var pos1 = $pos1
@onready var pos2 = $pos2
@onready var pos3 = $pos3
var damage:int
var near_body:Array[CharacterBody2D]

func initialize(buff: Buff_Data) -> void:
	damage = buff.damage

func _on_timer_timeout() -> void:
	near_body = near_body.filter(func(body): 
		return is_instance_valid(body) and body.is_in_group('Enemy')
	)
	
	if near_body.is_empty():
		print("buhell kosong")
		return
	
	near_body.sort_custom(func(a, b): 
		return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)
	)
	
	var n = near_body.size()
	var targets: Array[CharacterBody2D] = []
	
	if n >= 3:
		print("buhell 3")
		targets = [near_body[0], near_body[1], near_body[2]]
	elif n == 2:
		print("buhell 2")
		targets = [near_body[0], near_body[1], near_body[0]]
	else:
		print("buhell 1")
		targets = [near_body[0], near_body[0], near_body[0]]
	
	var markers = [pos1, pos2, pos3]
	for i in range(3):
		shoot(targets[i], markers[i])

func shoot(target:CharacterBody2D, start:Marker2D):
	var bul = Projectile.instantiate()
	bul.init(target, target.global_position, damage)
	self.add_child(bul)
	bul.global_position = start.global_position
	bul.global_rotation = start.global_rotation

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('Enemy'):
		near_body.append(body)
		print("musuh masuk buhell, sekarang isinya " + str(near_body.size()))

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('Enemy'):
		print("musuh keluar buhell")
		near_body.erase(body)
