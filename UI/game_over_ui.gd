class_name GameOverUI
extends CanvasLayer

@onready var tempo_label: Label = %TempoLabel
@onready var inimigo_label: Label = %InimigoLabel

@export var restart_delay: float = 5.0

var restart_cooldown: float

func _ready():
	tempo_label.text = GameManager.time_elapsed_string
	inimigo_label.text = str(GameManager. monster_deafeated_counter)
	restart_cooldown = restart_delay
	
	
func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()
	
	
func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
	pass
