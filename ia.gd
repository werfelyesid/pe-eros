extends Node

## IA simple que controla un personaje para pelear contra el jugador.

var objetivo: CharacterBody2D
var personaje: CharacterBody2D
var activo := false
var timer_especial := 0.0
var timer_ataque := 0.0

func iniciar(pj: CharacterBody2D, obj: CharacterBody2D) -> void:
	personaje = pj
	objetivo = obj
	# Desactivar el control del jugador en Simon
	personaje.set_physics_process(false)
	activo = true

func _physics_process(delta: float) -> void:
	if not activo or not is_instance_valid(personaje) or not is_instance_valid(objetivo):
		return

	var dist_x := objetivo.global_position.x - personaje.global_position.x
	var dist_y := objetivo.global_position.y - personaje.global_position.y
	var distancia: float = abs(dist_x)

	# Moverse hacia el objetivo
	if distancia > 80:
		personaje.velocity.x = personaje.speed * 0.7 * sign(dist_x)
		personaje.facing_dir = sign(dist_x)
	else:
		personaje.velocity.x = 0.0

	# Gravedad
	if not personaje.is_on_floor():
		personaje.velocity.y += personaje.gravity * delta

	# Saltar si el objetivo está más alto
	if personaje.is_on_floor() and dist_y < -30 and distancia < 300:
		personaje.velocity.y = personaje.jump_velocity

	# Atacar cuando está cerca
	timer_ataque -= delta
	if distancia < 100 and timer_ataque <= 0.0:
		if personaje.can_attack:
			personaje._attack()
			timer_ataque = 1.0

	# Ataque especial de vez en cuando
	timer_especial -= delta
	if distancia < 250 and timer_especial <= 0.0:
		if personaje.puede_especial:
			personaje._ataque_bola()
			timer_especial = 5.0
		elif personaje.puede_bola:
			personaje._ataque_bola()
			timer_especial = 5.0

	personaje._actualizar_giro()
	personaje.move_and_slide()
