extends CharacterBody2D

@export var sfxs:Array[AudioStreamWAV]
@onready var sfx:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var state:AnimatedSprite2D = $Sprite2D
@export var speed: float = 300.0
@onready var txt:Label = $Label
@onready var sprite_buff = $buff

var collect_buffs:Array[Buff_Drop]
var near_knight:bool
var cur_buff:Buff_Data
var use_serial_input: bool = true  # Toggle to enable/disable serial control

func _ready() -> void:
	txt.visible = false
	state.play("default")
	cur_buff = null
	sprite_buff.visible = false
	

func _input(event: InputEvent) -> void:
	# Check for grab action from keyboard
	if event.is_action_pressed("grab"):
		handle_grab_action()
	
	# Check for serial button press
	if use_serial_input and has_node("/root/Serial"):
		var serial_node = get_node("/root/Serial")
		if serial_node.is_button_pressed():
			handle_grab_action()

func handle_grab_action():
	if cur_buff and near_knight:
		print("memberikan buff")
		give_buff(cur_buff)
	elif !cur_buff and not collect_buffs.is_empty():
		print("mengambil buff")
		grab_buff()


func _physics_process(delta: float) -> void:
	# Get input direction
	var input_direction = Vector2()

	# Get keyboard input
	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	if Input.is_action_pressed("down"):
		input_direction.y += 1
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
	
	# Get accelerometer input (if enabled and available)
	if use_serial_input and has_node("/root/Serial"):
		var serial_node = get_node("/root/Serial")
		var serial_direction = serial_node.get_input_direction()
		
		# Add or override with serial input
		if serial_direction.length() > 0:
			input_direction = serial_direction

	if input_direction.length() > 0:
		input_direction = input_direction.normalized()

		# Flip sprite based on horizontal movement
		if input_direction.x > 0:
			state.flip_h = true  # Moving right, flip sprite
		elif input_direction.x < 0:
			state.flip_h = false  # Moving left, keep default

	velocity = input_direction * speed
	move_and_slide()
	

func Collecting_Buff():
	if not collect_buffs.is_empty():
		var buffs:Buff_Drop = collect_buffs.get(0)
		if cur_buff:
			buffs.hide_label()
			return
		buffs.hide_label()
		buffs.show_label()

func grab_buff():
	sfx.stream = sfxs.get(0)
	sfx.play()
	var buff_node = collect_buffs.get(0)
	print("mengambil buff " + buff_node.Buff.name)
	collect_buffs.erase(buff_node)
	cur_buff = buff_node.Buff
	sprite_buff.texture = cur_buff.sprite
	sprite_buff.visible = true
	buff_node.queue_free()
	state.play("holding")

func give_buff(buff:Buff_Data):
	Global.emit_signal("activate_buff",cur_buff)
	cur_buff = null
	txt.visible = false
	state.play("default")
	sprite_buff.visible = false
	sfx.stream = sfxs.get(1)
	sfx.play()

func _on_colect_area_entered(area: Area2D) -> void:
	if area.get_parent() is Buff_Drop:
		var buff = area.get_parent()
		collect_buffs.append(buff)
		Collecting_Buff()

func _on_colect_area_exited(area: Area2D) -> void:
	if area.get_parent() is Buff_Drop:
		var buff = area.get_parent()
		collect_buffs.erase(buff)
		buff.hide_label()
		Collecting_Buff()

func _on_colect_body_entered(body: Node2D) -> void:
	if body.is_in_group('knight'):
		near_knight = true
		if near_knight and cur_buff :
			txt.visible = true

func _on_colect_body_exited(body: Node2D) -> void:
	if body.is_in_group('knight'):
		near_knight = false
		txt.visible = false
