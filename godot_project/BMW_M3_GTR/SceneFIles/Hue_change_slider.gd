extends Node3D

@export var hue_slider : Slider  # The slider to control the hue
@export var material : ShaderMaterial  # The material to control (can be set in the Inspector)

func rgb_to_hsv(color: Color) -> Vector3:
	var r = color.r
	var g = color.g
	var b = color.b
	var max_val = max(r, max(g, b))
	var min_val = min(r, min(g, b))
	var delta = max_val - min_val
	var h = 0.0
	var s = 0.0
	var v = max_val
	
	if delta != 0.0:
		s = delta / max_val
		
		if r == max_val:
			h = (g - b) / delta
		elif g == max_val:
			h = 2.0 + (b - r) / delta
		else:
			h = 4.0 + (r - g) / delta
		
		h *= 60.0
		if h < 0.0:
			h += 360.0  # Ensure hue is in the range 0-360
	return Vector3(h, s, v)

func hsv_to_rgb(h: float, s: float, v: float) -> Color:
	var c = v * s
	var x = c * (1.0 - abs(fmod(h / 60.0, 2.0) - 1.0))
	var m = v - c
	
	var r = 0.0
	var g = 0.0
	var b = 0.0
	
	if h >= 0.0 and h < 60.0:
		r = c
		g = x
	elif h >= 60.0 and h < 120.0:
		r = x
		g = c
	elif h >= 120.0 and h < 180.0:
		g = c
		b = x
	elif h >= 180.0 and h < 240.0:
		g = x
		b = c
	elif h >= 240.0 and h < 300.0:
		r = x
		b = c
	elif h >= 300.0 and h < 360.0:
		r = c
		b = x
	
	return Color(r + m, g + m, b + m)

func _ready():
	if material:
		hue_slider.min_value = 0.0
		hue_slider.max_value = 359.0
		var current_color = material.get_shader_parameter("source_color_1")
		var hsv_values = rgb_to_hsv(current_color)
		var current_hue = hsv_values.x  # Hue in range 0-360
		print("Current Hue: ", current_hue)
		hue_slider.value = current_hue
		hue_slider.value_changed.connect(self._on_slider_value_changed)
	else:
		print("Material is not assigned! Please assign a ShaderMaterial to 'material' in the Inspector.")

func set_hue(value: float) -> void:
	if material:
		var color = material.get_shader_parameter("source_color_1")
		var hsv_values = rgb_to_hsv(color)
		hsv_values.x = value  # Update the hue with the slider value (0-360)
		var new_color = hsv_to_rgb(hsv_values.x, hsv_values.y, hsv_values.z)
		print("Setting New Color: ", new_color)
		material.set_shader_parameter("source_color_1", new_color)

func _on_slider_value_changed(value: float) -> void:
	print("Slider Value Changed: ", value)
	value = clamp(value, 0.0, 359.0)
	set_hue(value)
