extends CanvasLayer

@onready var time_label = $OverlayContainer/Control/TimeLabel
@onready var date_label = $OverlayContainer/Control/DateLabel
@onready var rec_dot = $OverlayContainer/Control/RecDot

var rec_tween

func _ready():
	update_date()
	start_rec_blink()


func _process(_delta):
	# Uhrzeit aktualisieren
	var current_time = Time.get_time_dict_from_system()
	var hours = str(current_time["hour"]).pad_zeros(2)
	var minutes = str(current_time["minute"]).pad_zeros(2)
	var seconds = str(current_time["second"]).pad_zeros(2)
	time_label.text = "%s:%s:%s" % [hours, minutes, seconds]

func update_date():
	# Datum einmal beim Start setzen
	var date = Time.get_date_dict_from_system()
	var day = str(date["day"]).pad_zeros(2)
	var month = str(date["month"]).pad_zeros(2)
	var year = str(date["year"])
	date_label.text = "%s.%s.%s" % [day, month, year]

func start_rec_blink():
	rec_tween = create_tween()
	rec_tween.set_loops()  # Endlos
	rec_tween.tween_property(rec_dot, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	rec_tween.tween_property(rec_dot, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
