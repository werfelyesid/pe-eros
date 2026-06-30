extends Area2D

@export var curacion := 50
@onready var sonido_recoger: AudioStreamPlayer = get_node_or_null("SonidoRecoger") as AudioStreamPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.has_method("recibir_vida"):
		body.call("recibir_vida", curacion)
		if sonido_recoger:
			sonido_recoger.play()
	queue_free()
