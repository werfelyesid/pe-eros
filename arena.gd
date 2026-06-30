extends Node2D

@onready var simon: CharacterBody2D = $simon
@onready var cami: CharacterBody2D = $cami
@onready var simon_vida_bar: ProgressBar = $UI/SimonVida
@onready var cami_vida_bar: ProgressBar = $UI/CamiVida
@onready var estado_label: Label = $UI/Estado
@onready var label_monedas: Label = $UI/Monedas
@onready var musica_fondo: AudioStreamPlayer = get_node_or_null("MusicaFondo") as AudioStreamPlayer
@onready var sonido_victoria: AudioStreamPlayer = get_node_or_null("SonidoVictoria") as AudioStreamPlayer
@onready var sonido_caida: AudioStreamPlayer = get_node_or_null("SonidoCaida") as AudioStreamPlayer

var victoria_sonada := false
var partida_terminada := false
var pelea_iniciada := false

func _ready() -> void:
	# Crear monedero (guarda monedas en archivo)
	var monedero := preload("res://monedero.gd").new()
	monedero.name = "Monedero"
	add_child(monedero)
	_actualizar_label_monedas()

	# Desactivar jugadores hasta que elijan armas
	simon.set_process(false)
	simon.set_physics_process(false)
	cami.set_process(false)
	cami.set_physics_process(false)

	# Mostrar pantalla de selección de armas y accesorios
	var seleccion := preload("res://seleccion_arma.tscn").instantiate()
	seleccion.seleccion_completa.connect(_on_seleccion_completa)
	add_child(seleccion)

func _on_seleccion_completa(arma_cami: ArmaData, arma_simon: ArmaData, acc_cami: AccesorioData, acc_simon: AccesorioData) -> void:
	# Asignar armas a los jugadores
	cami.arma_actual = arma_cami
	simon.arma_actual = arma_simon

	# Aplicar accesorios a los jugadores
	cami.aplicar_accesorio(acc_cami)
	simon.aplicar_accesorio(acc_simon)

	# Iniciar la pelea
	_iniciar_pelea()

func _iniciar_pelea() -> void:
	pelea_iniciada = true

	# Activar jugadores
	simon.set_process(true)
	simon.set_physics_process(true)
	cami.set_process(true)
	cami.set_physics_process(true)

	# Conectar señales de vida
	if simon and simon.has_signal("vida_cambiada"):
		simon.connect("vida_cambiada", _on_simon_vida_cambiada)
	if cami and cami.has_signal("vida_cambiada"):
		cami.connect("vida_cambiada", _on_cami_vida_cambiada)

	# Configurar barras de vida
	if simon:
		var simon_vida_inicial: int = int(simon.get("vida"))
		simon_vida_bar.max_value = simon_vida_inicial
		simon_vida_bar.value = simon_vida_inicial
	if cami:
		var cami_vida_inicial: int = int(cami.get("vida"))
		cami_vida_bar.max_value = cami_vida_inicial
		cami_vida_bar.value = cami_vida_inicial

	estado_label.text = "Pelea en curso"

	# Música de fondo
	if musica_fondo:
		musica_fondo.play()

func _process(_delta: float) -> void:
	if partida_terminada:
		return

	# Detectar caída al vacío
	if is_instance_valid(simon) and simon.global_position.y > 1100:
		simon.queue_free()
		_tocar_sonido_caida()
	if is_instance_valid(cami) and cami.global_position.y > 1100:
		cami.queue_free()
		_tocar_sonido_caida()

	# Detectar quién ganó
	if not is_instance_valid(simon) and not is_instance_valid(cami):
		estado_label.text = "Empate"
		_tocar_victoria()
	elif not is_instance_valid(simon):
		estado_label.text = "Gana Cami +5🪙"
		_dar_monedas("cami", 5)
		_tocar_victoria()
	elif not is_instance_valid(cami):
		estado_label.text = "Gana Simon +5🪙"
		_dar_monedas("simon", 5)
		_tocar_victoria()

func _tocar_sonido_caida() -> void:
	if sonido_caida and not sonido_caida.playing:
		sonido_caida.play()

func _tocar_victoria() -> void:
	if victoria_sonada:
		return
	victoria_sonada = true
	partida_terminada = true
	if sonido_victoria:
		sonido_victoria.play()
	# Parar música de fondo
	if musica_fondo and musica_fondo.playing:
		musica_fondo.stop()

	# Mostrar tienda después de 2 segundos
	await get_tree().create_timer(2.0).timeout
	var tienda := preload("res://tienda.tscn").instantiate()
	tienda.tienda_cerrada.connect(_on_tienda_cerrada)
	add_child(tienda)

func _on_tienda_cerrada() -> void:
	# Reiniciar la escena para volver a pelear
	get_tree().reload_current_scene()

func _on_simon_vida_cambiada(vida_actual: int) -> void:
	simon_vida_bar.value = max(0, vida_actual)

func _on_cami_vida_cambiada(vida_actual: int) -> void:
	cami_vida_bar.value = max(0, vida_actual)

func _dar_monedas(jugador: String, cantidad: int) -> void:
	var monedero := get_node_or_null("Monedero")
	if monedero and monedero.has_method("sumar_monedas"):
		monedero.sumar_monedas(jugador, cantidad)
		_actualizar_label_monedas()

func _actualizar_label_monedas() -> void:
	var monedero := get_node_or_null("Monedero")
	if monedero and label_monedas:
		label_monedas.text = "🪙 Cami: %d  |  Simon: %d" % [monedero.monedas_cami, monedero.monedas_simon]
