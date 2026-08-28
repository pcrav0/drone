extends Node3D


func _ready() -> void:
	var db := SQLite.new()
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

	db.insert_row("save", {
		 "date": int(Time.get_unix_time_from_system()),
		 "pos-x": $Player.position.x,
		 "pos-y": $Player.position.y,
		 "pos-z": $Player.position.z,
	})
	
	db.close_db()

func _process(_delta: float) -> void:
	pass
