extends Area2D

## Proyectil que viaja en línea recta, daña enemigos y dura varios segundos.

@export var velocidad := 600.0
@export var dano := 50
@export var tiempo_vida := 3.0

var direccion := 1.0
var cuerpos_golpeados: Array = []

func _ready() -> void:
	# Pequeño delay para no golpear al que lo lanza
	monitoring = false
	await get_tree().create_timer(0.15).timeout
	monitoring = true
	body_entered.connect(_on_body_entered)

	# Auto-destruir después del tiempo de vida
	await get_tree().create_timer(tiempo_vida).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position.x += velocidad * direccion * delta

func _on_body_entered(body: Node) -> void:
	# No hacer daño dos veces al mismo cuerpo
	if body in cuerpos_golpeados:
		return
	cuerpos_golpeados.append(body)

	if body.has_method("recibir_dano"):
		body.call("recibir_dano", dano)
