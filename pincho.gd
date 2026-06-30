extends Area2D

@export var dano := 10
@export var fuerza_rebote := 1000
@onready var sonido_pincho: AudioStreamPlayer = get_node_or_null("SonidoPincho") as AudioStreamPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Aplicar daño
	if body.has_method("recibir_dano"):
		body.call("recibir_dano", dano)

	# Aplicar rebote (impulso hacia arriba)
	if body is CharacterBody2D:
		body.velocity.y = -fuerza_rebote

	# Sonido de pincho
	if sonido_pincho:
		sonido_pincho.play()
