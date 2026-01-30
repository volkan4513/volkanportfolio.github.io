extends Button

@export var move_duration: float = 0.6
@export var target_container: SubViewportContainer

var original_position: Vector2
var is_visible_in_canvas := false
var tween  # Tween created with create_tween()

func _ready() -> void:
	if not target_container:
		return

	# Save original position (in-canvas position)
	original_position = target_container.position

	# Teleport off-screen to the right at start
	var screen_width := get_viewport_rect().size.x
	var offset := target_container.size.x
	target_container.position.x = screen_width + offset

	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if tween and tween.is_running():
		return  # Prevent overlapping tweens

	tween = create_tween()

	if is_visible_in_canvas:
		# Slide out to the right
		var screen_width := get_viewport_rect().size.x
		var offset := target_container.size.x
		var out_position := Vector2(screen_width + offset, original_position.y)

		tween.tween_property(
			target_container,
			"position",
			out_position,
			move_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

		is_visible_in_canvas = false
	else:
		# Slide into canvas
		tween.tween_property(
			target_container,
			"position",
			original_position,
			move_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		is_visible_in_canvas = true
