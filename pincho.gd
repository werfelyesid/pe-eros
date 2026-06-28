extends Area2D

@export var dano := 10
@export var fuerza_rebote := 1000

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Aplicar daño
	if body.has_method("recibir_dano"):
		body.call("recibir_dano", dano)

	# Aplicar rebote (impulso hacia arriba)
	if body is CharacterBody2D:
		body.velocity.y = -fuerza_rebote
