extends CharacterBody2D

@export var speed := 350.0
@export var jump_velocity := -700.0
@export var gravity := 800.0
@export var attack_cooldown := 1.60
@export var attack_damage := 1
@export var vida := 100
@export var vida_maxima := 100
@export var head_turn_degrees := 18.0
@export var head_turn_speed := 14.0

var can_attack := true
var facing_dir := 1.0
@onready var sonido_golpe: AudioStreamPlayer = $SonidoGolpe
@onready var head_visual: Node2D = get_node_or_null("HeadVisual") as Node2D

signal vida_cambiada(vida_actual)

func _physics_process(delta):
	velocity.x = 0.0

	if Input.is_action_pressed("simon_left"):
		velocity.x -= speed
	if Input.is_action_pressed("simon_right"):
		velocity.x += speed

	if velocity.x > 0.0:
		facing_dir = 1.0
	elif velocity.x < 0.0:
		facing_dir = -1.0

	if is_on_floor():
		if Input.is_action_just_pressed("simon_jump"):
			velocity.y = jump_velocity
	else:
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("simon_hit") and can_attack:
		_attack()

	_update_head_turn(delta)

	move_and_slide()

func _update_head_turn(delta: float) -> void:
	if head_visual == null:
		return

	var target_rotation: float = deg_to_rad(head_turn_degrees * facing_dir)
	head_visual.rotation = lerp_angle(head_visual.rotation, target_rotation, min(1.0, head_turn_speed * delta))

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
	var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
	if attack_shape == null or attack_shape.shape == null:
		return

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = attack_shape.shape
	query.transform = attack_shape.global_transform
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var results: Array = get_world_2d().direct_space_state.intersect_shape(query, 16)
	for result in results:
		var body: Node = result.get("collider")
		if body != null and body != self and body.has_method("recibir_dano"):
			body.call("recibir_dano", attack_damage)
			if sonido_golpe:
				if sonido_golpe.playing:
					sonido_golpe.stop()
				sonido_golpe.play()
			return

func recibir_dano(dano):
	vida -= dano
	if vida < 0:
		vida = 0
	emit_signal("vida_cambiada", vida)
	if vida <= 0:
		queue_free()

func recibir_vida(cantidad):
	vida = min(vida + cantidad, vida_maxima)
	emit_signal("vida_cambiada", vida)
