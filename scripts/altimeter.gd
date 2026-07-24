extends CanvasLayer


@onready var label := $Control/Label as Label
@onready var player_marker := %Player/Marker2D as Marker2D


func _ready() -> void:
	update_text()


func _physics_process(_delta: float) -> void:
	update_text()


func update_text() -> void:
	var real_altitude := Global.altitude + (-player_marker.global_position.y + 250) / Global.PIXEL_PER_METER
	var shown_altitude := maxf(real_altitude - 50, 0.0)
	label.text = altitude_to_text(shown_altitude)


func altitude_to_text(altitude: float) -> String:
	var text := str(int(round(altitude)))
	if text.length() > 3:
		text = text.substr(0, text.length() - 3) + ',' + text.substr(text.length() - 3, 3)
	return text + 'm'
