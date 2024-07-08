extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meet_label: Label = %MeetLabel

func _process(delta):
	timer_label.text = GameManager.time_elapsed_string
	meet_label.text = str(GameManager.meet_counter)

