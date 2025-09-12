extends CharacterBody2D

@export var speed: float = 300.0

var collect_buffs:Array[Buff_Drop]
var cur_buff:Buff_Data 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		if cur_buff:
			grab_buff(cur_buff)

func _physics_process(delta: float) -> void:
	# Get input direction
	var input_direction = Vector2()
	
	# Check for input in all four directions
	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	if Input.is_action_pressed("down"):
		input_direction.y += 1
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
	
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()

	velocity = input_direction * speed
	move_and_slide()
	

func Collecting_Buff():
	var buffs = collect_buffs.get(0)
	buffs.hide_label()
	cur_buff = buffs.Buff

func grab_buff(buff:Buff_Data):
	GlobalSignal.emit_signal("activate_buff",cur_buff)

func _on_colect_area_entered(area: Area2D) -> void:
	if area.get_parent() is Buff_Drop:
		var buff = area.get_parent()
		collect_buffs.append(buff)

func _on_colect_area_exited(area: Area2D) -> void:
	if area.get_parent() is Buff_Drop:
		var buff = area.get_parent()
		collect_buffs.erase(buff)
		buff.hide_label()
