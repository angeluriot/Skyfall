extends CanvasLayer
class_name Message


class MessageData:
	var text: String
	var fade_in: float
	var duration: float
	var fade_out: float

	func _init(_text: String, _fade_in: float, _duration: float, _fade_out: float) -> void:
		text = _text
		fade_in = _fade_in
		duration = _duration
		fade_out = _fade_out


@onready var label := $Control/Label as Label


func _ready() -> void:
	match Global.current_level:
		1:
			show_messages([
				MessageData.new('The plane door just opened!\nYou’re now in free fall!', 1.0, 2.0, 0.5),
				MessageData.new('Quick, move above the ball\nwith WASD / arrow keys!', 0.5, 2.5, 0.5)
			], 0.0)
		2:
			show_messages([
				MessageData.new('It happened again!', 1.0, 1.0, 1.0),
			], 0.0)
		3:
			show_messages([
				MessageData.new('The box is going\nto hurt you!', 0.5, 2.0, 0.5),
				MessageData.new('Move it by grabbing it\nwith the SPACE bar!', 0.5, 2.0, 0.5)
			], 0.0)
		4:
			show_messages([
				MessageData.new('You\'re not alone,\nhelp him!', 0.5, 2.0, 0.5)
			], 0.0)


func show_messages(messages: Array[MessageData], gap: float) -> void:
	label.modulate.a = 0.0
	var tween := create_tween()
	for i in range(messages.size()):
		var data := messages[i]
		if i > 0:
			tween.tween_interval(gap)
		tween.tween_callback(func() -> void: label.text = data.text)
		tween.tween_property(label, "modulate:a", 1.0, data.fade_in).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_interval(data.duration)
		tween.tween_property(label, "modulate:a", 0.0, data.fade_out).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(queue_free)
