extends Node2D

@onready var simon: CharacterBody2D = $simon
@onready var cami: CharacterBody2D = $cami
@onready var simon_vida_bar: ProgressBar = $UI/SimonVida
@onready var cami_vida_bar: ProgressBar = $UI/CamiVida
@onready var estado_label: Label = $UI/Estado

func _ready() -> void:
	if simon and simon.has_signal("vida_cambiada"):
		simon.connect("vida_cambiada", _on_simon_vida_cambiada)
	if cami and cami.has_signal("vida_cambiada"):
		cami.connect("vida_cambiada", _on_cami_vida_cambiada)

	if simon:
		var simon_vida_inicial: int = int(simon.get("vida"))
		simon_vida_bar.max_value = simon_vida_inicial
		simon_vida_bar.value = simon_vida_inicial
	if cami:
		var cami_vida_inicial: int = int(cami.get("vida"))
		cami_vida_bar.max_value = cami_vida_inicial
		cami_vida_bar.value = cami_vida_inicial

	estado_label.text = "Pelea en curso"

func _process(_delta: float) -> void:
	if not is_instance_valid(simon) and not is_instance_valid(cami):
		estado_label.text = "Empate"
	elif not is_instance_valid(simon):
		estado_label.text = "Gana Cami"
	elif not is_instance_valid(cami):
		estado_label.text = "Gana Simon"

func _on_simon_vida_cambiada(vida_actual: int) -> void:
	simon_vida_bar.value = max(0, vida_actual)

func _on_cami_vida_cambiada(vida_actual: int) -> void:
	cami_vida_bar.value = max(0, vida_actual)
