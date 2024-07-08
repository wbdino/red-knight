class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

@export var speed: float = 3
@export var sword_damage = 2
@export var health: int = 100
@export var max_health: int = 100 
@export var death_prefab: PackedScene
 
var input_vector: Vector2 = Vector2(0,0) 
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0


signal meet_collected(value: int)

func _ready():
	GameManager.player = self
	meet_collected.connect(func(value: int): GameManager.meet_counter += 1)

func _process(delta):
	GameManager.player_position = position
	
	#Ler input
	read_input()
	
	#Processa rotação e amimação da sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	#Processa ataque
	update_attack_cooldown(delta)
	#Ataque
	if Input.is_action_just_pressed("attack"):
		attack()

	#Processar dano
	update_hitbox_detection(delta)
	
	#Atualizar health bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
	
func update_attack_cooldown(delta):
	#Atualiza o temporizador do ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func _physics_process(delta):
	#Modificar a velocidade
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func rotate_sprite():
	#Girar spr
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func play_run_idle_animation():
		#Tocar animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func read_input():
	#Obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	 
		#Apaga deadzone do vector
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	#Atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func attack():
	if is_attacking:
		return
		
	#Tocar animação
	animation_player.play("attack_side_1")
	
	#Configura temporizador
	attack_cooldown = 0.6
	
	#Marca ataque
	is_attacking = true
	

func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if  sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
				
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product >= 0.6:
				enemy.damage(sword_damage)
			
			enemy.damage(sword_damage)

func damage(amount: int):
	if health <= 0: return
	
	health -= amount
	print("ai isso doeu")
	
	modulate = Color.RED
	var tween = create_tween() 
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if health <= 0:
		die()

func update_hitbox_detection(delta):
	
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	hitbox_cooldown = 0.5
	
	#Detectar inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)

func die():
	GameManager.end_game()
	
	if death_prefab:
		var death_obj = death_prefab.instantiate()
		death_obj.position = position
		get_parent().add_child(death_obj)
		
	queue_free()

func heal(amount: int):
	health += amount
	if health > max_health:
		health = max_health
		print("Carninha gostosa")
	return health
