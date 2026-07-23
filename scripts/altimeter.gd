extends CanvasLayer


@onready var label := $Control/Label as Label


func _ready() -> void:
	label.text = altitude_to_text(Global.altitude)


func _physics_process(_delta: float) -> void:
	label.text = altitude_to_text(Global.altitude)


func altitude_to_text(altitude: float) -> String:
	var text := str(int(round(altitude)))
	if text.length() > 3:
		text = text.substr(0, text.length() - 3) + ',' + text.substr(text.length() - 3, 3)
	return text + 'm'
