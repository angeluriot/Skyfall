extends CanvasLayer


@export var initial_altitude: int = 0
@export var speed: float = 1.0

@onready var label := $Control/Label as Label
@onready var altitude = float(initial_altitude)


func _ready() -> void:
	label.text = altitude_to_text(initial_altitude)


func _process(delta: float) -> void:
	altitude -= speed * delta
	label.text = altitude_to_text(round(altitude))


func altitude_to_text(alt: int) -> String:
	var text := str(alt)
	if text.length() > 3:
		text = text.substr(0, text.length() - 3) + ',' + text.substr(text.length() - 3, 3)
	return text + 'm'
