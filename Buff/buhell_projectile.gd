extends Area2D

@onready var sfx = $AudioStreamPlayer2D
var damage:int
var target_coor:Vector2
var target:CharacterBody2D
var speed: float = 200.0

func init(t:CharacterBody2D, tc:Vector2, v:int):
	target = t
	target_coor = tc
	damage = v

func _physics_process(delta: float) -> void:
	var direction = (target_coor - global_position).normalized()
	global_position += direction * speed * delta
	rotation = direction.angle() + PI/2
	#if target:
		#print("target ada namanya " + target.name)
	if global_position.distance_to(target_coor) < 5.0:
		print("peluru hancur tanpa memberi damage")
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	print("ini body " + body.name + " ini target " + target.name)
	if body == target:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("peluru memberi damage")
		queue_free()
	
