extends Area2D

## Kamehameha estático: un rayo que sale del jugador y se queda en el lugar.

@export var dano := 50
@export var duracion := 3.0
@export var largo := 400.0

var cuerpos_golpeados: Array = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Auto-destruir después de la duración
	await get_tree().create_timer(duracion).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body in cuerpos_golpeados:
		return
	cuerpos_golpeados.append(body)
	if body.has_method("recibir_dano"):
		body.call("recibir_dano", dano)
