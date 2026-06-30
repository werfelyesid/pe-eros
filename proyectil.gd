extends Area2D

## Bola de fuego que viaja en línea recta y daña al enemigo.

@export var velocidad := 600.0
@export var dano := 50
@export var tiempo_vida := 3.0

var direccion := 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Destruir después de tiempo_vida segundos
	await get_tree().create_timer(tiempo_vida).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position.x += velocidad * direccion * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("recibir_dano"):
		body.call("recibir_dano", dano)
	queue_free()
