extends CharacterBody2D

@export var speed: float = 300.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		grab_buff()

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
	
func grab_buff():
	pass	
