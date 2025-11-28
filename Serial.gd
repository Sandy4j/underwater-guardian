extends Node

var serial: GdSerial
var input_direction: Vector2 = Vector2.ZERO
var button_pressed: bool = false

func _ready():
	serial = GdSerial.new()
	var port_name = "COM3"  # Change this to your serial port
	var baud_rate = 9600
	
	# Configure serial port
	serial.set_port(port_name)
	serial.set_baud_rate(baud_rate)
	
	# Open the connection
	if serial.open():
		print("Serial port opened successfully.")
	else:
		print("Failed to open serial port")

func _process(_delta: float) -> void:
	if serial:
		read_serial_data()

func read_serial_data():
	var available = serial.bytes_available()
	if available > 0:
		var data = serial.read_string(available)
		if data:
			parse_data(data)

func parse_data(data: String):
	# Data format from Arduino: "X,Y,B\n" (e.g., "1,0,0" or "-1,1,1")
	var lines = data.split("\n")
	
	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line == "READY" or line.begins_with("ERROR"):
			continue
		
		var values = line.split(",")
		if values.size() >= 3:
			var x = int(values[0])
			var y = int(values[1])
			var btn = int(values[2])
			
			# Update input direction
			input_direction = Vector2(x, y)
			
			# Update button state
			if btn == 1:
				button_pressed = true
			else:
				button_pressed = false

func get_input_direction() -> Vector2:
	return input_direction

func is_button_pressed() -> bool:
	var pressed = button_pressed
	button_pressed = false  # Reset after reading
	return pressed
