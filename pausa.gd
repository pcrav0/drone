extends ColorRect

func _ready() -> void:
	visible = false
	get_tree().paused = false
	set_process_input(true)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pausar"):
		visible = !visible
		get_tree().paused = !get_tree().paused
