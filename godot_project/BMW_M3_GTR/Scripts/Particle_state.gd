extends Node

@export var check_button: CheckButton
@export var spin_box: SpinBox
@export var emitters: Array[GPUParticles3D]  # Array that only accepts GPUParticles3D nodes

func _ready() -> void:
	# Connect CheckButton signal
	check_button.connect("toggled", Callable(self, "_on_check_button_toggled"))
	
	# Connect SpinBox signal
	spin_box.min_value = 0
	spin_box.max_value = 100000
	spin_box.step = 100  # Adjust step size as needed
	spin_box.value = emitters[0].amount if emitters.size() > 0 else 0
	spin_box.connect("value_changed", Callable(self, "_on_spin_box_value_changed"))

func _on_check_button_toggled(button_pressed: bool) -> void:
	print("CheckButton toggled:", button_pressed)  # Debugging
	for emitter in emitters:
		emitter.emitting = button_pressed  # Enable/disable emitters

func _on_spin_box_value_changed(value: float) -> void:
	print("Particle amount changed:", int(value))  # Debugging
	for emitter in emitters:
		emitter.amount = int(value)  # Sync all emitters to the same particle amount
