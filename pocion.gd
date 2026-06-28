extends Area2D

@export var curacion := 50

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.has_method("recibir_vida"):
		body.call("recibir_vida", curacion)
		queue_free()
