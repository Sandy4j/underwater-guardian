extends Node2D
class_name Buff_Drop

@export var Buff:Buff_Data
@onready var Text:Sprite2D = $Sprite2D
@onready var Area = $Area2D
@onready var col:CollisionShape2D = $Area2D/CollisionShape2D
@onready var Collect = $Label

# VFX Components
@onready var highlight_tween: Tween
@onready var float_tween: Tween
@onready var rotation_tween: Tween
@onready var particles: CPUParticles2D
@onready var glow_ring: Sprite2D
@onready var pulse_tween: Tween

var original_position: Vector2
var is_hovering: bool = false

func init(buff:Buff_Data):
	Buff = buff

func _ready() -> void:
	Collect.hide()
	Text.texture = Buff.sprite
	col.shape.radius = Buff.sprite.get_height() * Text.scale.x
	original_position = global_position
	
	setup_vfx_components()
	start_idle_effects()

func setup_vfx_components():
	# Create glow ring effect
	glow_ring = Sprite2D.new()
	add_child(glow_ring)
	move_child(glow_ring, 0)  # Place behind main sprite
	
	# Create a simple circle texture for glow ring
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center = Vector2(32, 32)
	for x in range(64):
		for y in range(64):
			var dist = center.distance_to(Vector2(x, y))
			if dist < 30:
				var alpha = (30 - dist) / 30.0 * 0.3
				image.set_pixel(x, y, Color(1, 1, 0.5, alpha))
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	glow_ring.texture = texture
	glow_ring.modulate = Color(1, 1, 0.5, 0.5)
	
	# Create particle effect
	particles = CPUParticles2D.new()
	add_child(particles)
	setup_particles()

func setup_particles():
	# Sparkle/shimmer particles
	particles.emitting = true
	particles.amount = 20
	particles.lifetime = 2.0
	particles.texture = create_sparkle_texture()
	
	# Emission
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 30.0
	
	# Movement
	particles.direction = Vector2(0, -1)
	particles.spread = 45.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 30.0
	particles.gravity = Vector2(0, -20)
	
	# Appearance
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.8
	particles.color = Color(1, 1, 0.7, 0.8)
	
	# Animation - Fixed: Use color_ramp instead of alpha_curve
	particles.color_ramp = create_fade_gradient()

func create_sparkle_texture() -> ImageTexture:
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Create a simple star/sparkle shape
	image.set_pixel(4, 2, Color.WHITE)
	image.set_pixel(4, 6, Color.WHITE)
	image.set_pixel(2, 4, Color.WHITE)
	image.set_pixel(6, 4, Color.WHITE)
	image.set_pixel(4, 4, Color.WHITE)
	image.set_pixel(3, 3, Color(1, 1, 1, 0.7))
	image.set_pixel(5, 3, Color(1, 1, 1, 0.7))
	image.set_pixel(3, 5, Color(1, 1, 1, 0.7))
	image.set_pixel(5, 5, Color(1, 1, 1, 0.7))
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func create_fade_gradient() -> Gradient:
	# Fixed: Create a Gradient instead of Curve for color animation
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 0.7, 0.0))  # Start transparent
	gradient.add_point(0.2, Color(1, 1, 0.7, 0.8))  # Fade in
	gradient.add_point(0.8, Color(1, 1, 0.7, 0.8))  # Stay visible
	gradient.add_point(1.0, Color(1, 1, 0.7, 0.0))  # Fade out
	return gradient

func start_idle_effects():
	# Floating animation
	float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_method(update_float, 0.0, 1.0, 2.0)
	float_tween.tween_method(update_float, 1.0, 0.0, 2.0)
	
	# Gentle rotation
	rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property(Text, "rotation", Text.rotation + TAU, 8.0)
	
	# Highlight/glow pulse
	setup_highlight_effect()
	
	# Glow ring pulse
	pulse_glow_ring()

func update_float(progress: float):
	var float_offset = sin(progress * PI) * 5.0  # 5 pixels up and down
	global_position.y = original_position.y - float_offset

func setup_highlight_effect():
	highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_method(update_highlight, 0.8, 1.2, 1.5)
	highlight_tween.tween_method(update_highlight, 1.2, 0.8, 1.5)

func update_highlight(value: float):
	Text.modulate = Color(value, value, value * 0.9, 1.0)

func pulse_glow_ring():
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(glow_ring, "scale", Vector2(1.2, 1.2), 1.0)
	pulse_tween.tween_property(glow_ring, "scale", Vector2(0.8, 0.8), 1.0)

func show_label():
	Collect.show()
	is_hovering = true
	
	# Intensify all effects when hovering
	stop_idle_effects()
	
	# Faster, more intense highlight
	highlight_tween = create_tween()
	highlight_tween.set_loops()
	highlight_tween.tween_method(update_highlight, 1.0, 1.6, 0.3)
	highlight_tween.tween_method(update_highlight, 1.6, 1.0, 0.3)
	
	# Faster floating
	float_tween = create_tween()
	float_tween.set_loops()
	float_tween.tween_method(update_float, 0.0, 1.0, 0.8)
	float_tween.tween_method(update_float, 1.0, 0.0, 0.8)
	
	# Increase particle emission
	particles.amount = 40
	particles.initial_velocity_max = 50.0
	
	# Brighter glow ring
	glow_ring.modulate = Color(1, 1, 0.5, 0.8)
	pulse_tween.kill()
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(glow_ring, "scale", Vector2(1.5, 1.5), 0.4)
	pulse_tween.tween_property(glow_ring, "scale", Vector2(1.0, 1.0), 0.4)

func hide_label():
	Collect.hide()
	is_hovering = false
	
	# Return to normal effects
	stop_idle_effects()
	start_idle_effects()
	
	# Reset particle emission
	particles.amount = 20
	particles.initial_velocity_max = 30.0
	
	# Reset glow ring
	glow_ring.modulate = Color(1, 1, 0.5, 0.5)

func stop_idle_effects():
	if highlight_tween:
		highlight_tween.kill()
	if float_tween:
		float_tween.kill()
	if pulse_tween:
		pulse_tween.kill()

# Call this when the item is collected
func collect_effect():
	# Stop all ongoing effects
	stop_idle_effects()
	particles.emitting = false
	
	# Play collection animation
	var collect_tween = create_tween()
	collect_tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	collect_tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	collect_tween.parallel().tween_property(self, "global_position", global_position + Vector2(0, -30), 0.3)
	
	# Create collection burst effect
	var burst_particles = CPUParticles2D.new()
	get_parent().add_child(burst_particles)
	burst_particles.global_position = global_position
	burst_particles.emitting = true
	burst_particles.one_shot = true
	burst_particles.amount = 30
	burst_particles.lifetime = 1.0
	burst_particles.texture = create_sparkle_texture()
	burst_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	burst_particles.emission_sphere_radius = 10.0
	burst_particles.direction = Vector2(0, -1)
	burst_particles.spread = 360.0
	burst_particles.initial_velocity_min = 50.0
	burst_particles.initial_velocity_max = 100.0
	burst_particles.scale_amount_min = 0.5
	burst_particles.scale_amount_max = 1.2
	burst_particles.color = Color(1, 1, 0.8, 1)
	
	# Clean up after animation
	collect_tween.tween_callback(queue_free)
	
	# Clean up burst particles
	var cleanup_timer = Timer.new()
	get_parent().add_child(cleanup_timer)
	cleanup_timer.wait_time = 1.5
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(func(): 
		if is_instance_valid(burst_particles):
			burst_particles.queue_free()
		cleanup_timer.queue_free()
	)
	cleanup_timer.start()
