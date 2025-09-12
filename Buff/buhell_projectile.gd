extends Area2D

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
	
	if global_position.distance_to(target_coor) < 5.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == target:
		print("buhell memberi damage " + str(damage))
		#if body.has_method("take_damage"):
			#body.take_damage(damage)
		queue_free()
