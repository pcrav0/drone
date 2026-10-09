extends Node3D

@onready var db := SQLite.new()

func _ready() -> void:
	set_process_input(true)
	db.path = "res://db.db"
	db.open_db()

	db.create_table(
		"save",
		{
			"date": {"data_type": "int"},
			"pos-x": {"data_type": "real"},
			"pos-y": {"data_type": "real"},
			"pos-z": {"data_type": "real"},
		}
	)

func _process(delta: float):
	if Input.is_action_pressed("rotacao_y_esquerda"):
		$Camera.rotate_y(delta * 5 * 0.3)
	if Input.is_action_pressed("rotacao_y_direita"):
		$Camera.rotate_y(delta * -5 * 0.3)

func _notification(evento):
	if evento == NOTIFICATION_WM_CLOSE_REQUEST:
		db.insert_row("save", {
			 "date": int(Time.get_unix_time_from_system()),
			 "pos-x": $Player.position.x,
			 "pos-y": $Player.position.y,
			 "pos-z": $Player.position.z,
		})
		db.close_db()
