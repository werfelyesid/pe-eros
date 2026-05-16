extends CharacterBody2D

@export var speed := 350.0
@export var jump_velocity := -600.0
@export var gravity := 900.0
@export var attack_cooldown := 0.5
@export var attack_damage := 10
@export var vida := 100

var can_attack := true

signal vida_cambiada(vida_actual)

func _physics_process(delta):
	velocity.x = 0.0

	if Input.is_action_pressed("simon_left"):
		velocity.x -= speed
	if Input.is_action_pressed("simon_right"):
		velocity.x += speed

	if is_on_floor():
		if Input.is_action_just_pressed("simon_jump"):
			velocity.y = jump_velocity
	else:
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("simon_hit") and can_attack:
		_attack()

	move_and_slide()

func _attack():
	can_attack = false

	$AttackArea.monitoring = true
	await get_tree().physics_frame
	_try_apply_hit()
	await get_tree().create_timer(0.08).timeout
	$AttackArea.monitoring = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _try_apply_hit():
	var bodies: Array = $AttackArea.get_overlapping_bodies()
	for body: Node in bodies:
		if body != self and body.has_method("recibir_dano"):
			body.call("recibir_dano", attack_damage)
			return

func recibir_dano(dano):
	vida -= dano
	if vida < 0:
		vida = 0
	emit_signal("vida_cambiada", vida)
	if vida <= 0:
		queue_free()
