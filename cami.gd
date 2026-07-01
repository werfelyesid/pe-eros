extends CharacterBody2D

const PROYECTIL := preload("res://kamehameha.tscn")
const BOLA_FUEGO := preload("res://proyectil.tscn")

@export var speed := 500
@export var jump_velocity := -600
@export var gravity := 600
@export var attack_cooldown := 1.60
@export var attack_damage := 20
@export var arma_actual: ArmaData
@export var vida := 1000
@export var vida_maxima := 1000
@export var head_turn_degrees := 18.0
@export var head_turn_speed := 14.0
@export var cooldown_especial := 3
@export var cooldown_bola := 4

var can_attack := true
var puede_especial := true
var puede_bola := true
var cargando_especial := false
var usando_kamehameha := false
var tiempo_inicio_carga := 0.0
var facing_dir := 1.0
var multiplicador_dano_recibido := 1.0
@onready var sonido_golpe: AudioStreamPlayer = $SonidoGolpe
@onready var sonido_salto: AudioStreamPlayer = get_node_or_null("SonidoSalto") as AudioStreamPlayer
@onready var sonido_correr: AudioStreamPlayer = get_node_or_null("SonidoCorrer") as AudioStreamPlayer
@onready var head_visual: Node2D = get_node_or_null("HeadVisual") as Node2D

signal vida_cambiada(vida_actual)

func _ready() -> void:
	if arma_actual:
		var shape_dup = $AttackArea/CollisionShape2D.shape.duplicate()
		if shape_dup is RectangleShape2D:
			shape_dup.size = arma_actual.tamano_golpe
		$AttackArea/CollisionShape2D.shape = shape_dup

func aplicar_accesorio(acc: AccesorioData) -> void:
	if acc == null:
		return
	multiplicador_dano_recibido = acc.multiplicador_dano_recibido
	jump_velocity = int(jump_velocity * acc.multiplicador_salto)
	gravity = int(gravity * acc.multiplicador_gravedad)
	if acc.bonus_vida > 0:
		vida_maxima += acc.bonus_vida
		vida += acc.bonus_vida
	speed = max(80, int(float(speed) * acc.multiplicador_velocidad))

func _physics_process(delta):
	# Si está usando kamehameha, no moverse (congelado en el aire)
	if usando_kamehameha:
		velocity = Vector2.ZERO
		# Permitir apuntar arriba/abajo
		if Input.is_action_pressed("cami_jump"):
			$RayoKamehameha.rotation = deg_to_rad(-30)
		elif Input.is_action_pressed("cami_left") or Input.is_action_pressed("cami_right"):
			$RayoKamehameha.rotation = 0.0
		else:
			$RayoKamehameha.rotation = 0.0
		move_and_slide()
		return

	velocity.x = 0.0
	if Input.is_action_pressed("cami_left"):
		velocity.x -= speed
	if Input.is_action_pressed("cami_right"):
		velocity.x += speed
	if velocity.x > 0.0:
		facing_dir = 1.0
	elif velocity.x < 0.0:
		facing_dir = -1.0
	_actualizar_giro()
	if is_on_floor():
		if Input.is_action_just_pressed("cami_jump"):
			velocity.y = jump_velocity
			if sonido_salto:
				sonido_salto.play()
	else:
		velocity.y += gravity * delta
	if sonido_correr:
		if is_on_floor() and velocity.x != 0.0:
			if not sonido_correr.playing:
				sonido_correr.play()
		else:
			sonido_correr.stop()
	if Input.is_action_just_pressed("cami_hit") and can_attack:
		_attack()

	# Kamekameha con carga: mantén la tecla para cargar, suelta para disparar
	if Input.is_action_just_pressed("cami_especial") and puede_especial:
		cargando_especial = true
		tiempo_inicio_carga = Time.get_ticks_msec() / 1000.0

	if Input.is_action_just_released("cami_especial") and cargando_especial:
		cargando_especial = false
		var tiempo_carga := (Time.get_ticks_msec() / 1000.0) - tiempo_inicio_carga
		_ataque_especial(minf(tiempo_carga, 3.0))

	if Input.is_action_just_pressed("cami_bola") and puede_bola:
		_ataque_bola()

	_update_head_turn(delta)
	move_and_slide()

func _actualizar_giro() -> void:
	$AttackArea.position.x = 90 * facing_dir
	$AttackArea.scale.x = 1.0
	var sprite := get_node_or_null("Sprite2D") as Node2D
	if sprite:
		sprite.scale.x = abs(sprite.scale.x) * facing_dir

func _update_head_turn(delta: float) -> void:
	if head_visual == null:
		return
	var target_rotation: float = deg_to_rad(head_turn_degrees * facing_dir)
	head_visual.rotation = lerp_angle(head_visual.rotation, target_rotation, min(1.0, head_turn_speed * delta))

func _attack():
	can_attack = false
	$AttackArea/CollisionShape2D.position = Vector2.ZERO
	$AttackArea.monitoring = true
	await get_tree().physics_frame
	_try_apply_hit()
	await get_tree().create_timer(0.08).timeout
	$AttackArea.monitoring = false
	var cooldown := arma_actual.enfriamiento if arma_actual else attack_cooldown
	await get_tree().create_timer(cooldown).timeout
	can_attack = true

func _try_apply_hit():
	var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
	if attack_shape == null or attack_shape.shape == null:
		return
	var forma := attack_shape.shape
	if arma_actual:
		forma = forma.duplicate()
		if forma is RectangleShape2D:
			forma.size = arma_actual.tamano_golpe
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = forma
	query.transform = attack_shape.global_transform
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var results: Array = get_world_2d().direct_space_state.intersect_shape(query, 16)
	for result in results:
		var body: Node = result.get("collider")
		if body != null and body != self and body.has_method("recibir_dano"):
			var dano_a_aplicar := arma_actual.dano if arma_actual else attack_damage
			body.call("recibir_dano", dano_a_aplicar)
			if sonido_golpe:
				if sonido_golpe.playing:
					sonido_golpe.stop()
				sonido_golpe.play()
			return

func _ataque_especial(tiempo_carga: float = 0.0) -> void:
	puede_especial = false
	usando_kamehameha = true

	# Crear rayo estático como hijo del jugador
	var rayo := Area2D.new()
	rayo.name = "RayoKamehameha"
	rayo.add_to_group("kamehameha")

	var colision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(400, 40)
	colision.shape = forma
	colision.position = Vector2(200 * facing_dir, 0)
	rayo.add_child(colision)

	# Visual: rectángulo azul
	var visual := ColorRect.new()
	visual.color = Color(0.2, 0.4, 1, 0.7)
	visual.position = Vector2(0, -20)
	visual.size = Vector2(400, 40)
	rayo.add_child(visual)

	# Núcleo blanco
	var nucleo := ColorRect.new()
	nucleo.color = Color(0.7, 0.9, 1, 1)
	nucleo.position = Vector2(0, -8)
	nucleo.size = Vector2(400, 16)
	visual.add_child(nucleo)

	rayo.body_entered.connect(_on_rayo_golpea)
	add_child(rayo)

	# El rayo apunta en la dirección del jugador
	rayo.scale.x = facing_dir

	await get_tree().create_timer(3.0).timeout

	# Terminar kamehameha
	if is_instance_valid(rayo):
		rayo.queue_free()
	usando_kamehameha = false
	await get_tree().create_timer(cooldown_especial).timeout
	puede_especial = true

func _on_rayo_golpea(body: Node) -> void:
	if body != self and body.has_method("recibir_dano"):
		body.call("recibir_dano", 50)

func _ataque_bola() -> void:
	puede_bola = false
	var bola := BOLA_FUEGO.instantiate()
	bola.direccion = facing_dir
	bola.dano = 30
	bola.global_position = global_position + Vector2(50 * facing_dir, 0)
	get_parent().add_child(bola)
	await get_tree().create_timer(cooldown_bola).timeout
	puede_bola = true

func recibir_dano(dano):
	var dano_real := int(dano * multiplicador_dano_recibido)
	vida -= dano_real
	if vida < 0:
		vida = 0
	emit_signal("vida_cambiada", vida)
	if vida <= 0:
		queue_free()

func recibir_vida(cantidad):
	vida = min(vida + cantidad, vida_maxima)
	emit_signal("vida_cambiada", vida)
