extends CanvasLayer

## Fase 1: elegir arma (1,2,3). Fase 2: elegir accesorio (1,2,3,4).

@export var arma_1: ArmaData
@export var arma_2: ArmaData
@export var arma_3: ArmaData
@export var acc_1: AccesorioData
@export var acc_2: AccesorioData
@export var acc_3: AccesorioData
@export var acc_4: AccesorioData

var eleccion_arma_cami: ArmaData
var eleccion_arma_simon: ArmaData
var eleccion_acc_cami: AccesorioData
var eleccion_acc_simon: AccesorioData
var fase_armas := true

signal seleccion_completa(arma_cami: ArmaData, arma_simon: ArmaData, acc_cami: AccesorioData, acc_simon: AccesorioData)

@onready var label_cami: Label = $VBoxCami/LabelCami
@onready var opcion_cami: Label = $VBoxCami/OpcionCami
@onready var label_simon: Label = $VBoxSimon/LabelSimon
@onready var opcion_simon: Label = $VBoxSimon/OpcionSimon
@onready var titulo: Label = $Titulo
@onready var timer_inicio: Timer = $TimerInicio

func _ready() -> void:
	_mostrar_fase_armas()

func _mostrar_fase_armas() -> void:
	titulo.text = "⚔️ ELIGE TU ARMA ⚔️\n1: %s  |  2: %s  |  3: %s" % [arma_1.nombre_arma, arma_2.nombre_arma, arma_3.nombre_arma]
	label_cami.text = "CAMI (teclas 1, 2, 3)"
	label_simon.text = "SIMON (NumPad 1, 2, 3)"
	opcion_cami.text = ""
	opcion_simon.text = ""

func _mostrar_fase_accesorios() -> void:
	titulo.text = "🛡️ ELIGE TU ACCESORIO 🛡️\n1:%s  2:%s  3:%s  4:%s" % [acc_1.nombre_accesorio, acc_2.nombre_accesorio, acc_3.nombre_accesorio, acc_4.nombre_accesorio]
	label_cami.text = "CAMI (teclas 1, 2, 3, 4)"
	label_simon.text = "SIMON (NumPad 1, 2, 3, 4)"
	opcion_cami.text = ""
	opcion_simon.text = ""

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return

	if fase_armas:
		_input_armas(event)
	else:
		_input_accesorios(event)

func _input_armas(event: InputEventKey) -> void:
	if eleccion_arma_cami == null:
		match event.keycode:
			KEY_1: eleccion_arma_cami = arma_1
			KEY_2: eleccion_arma_cami = arma_2
			KEY_3: eleccion_arma_cami = arma_3
		if eleccion_arma_cami != null:
			opcion_cami.text = "✅ %s" % eleccion_arma_cami.nombre_arma
			opcion_cami.add_theme_color_override("font_color", eleccion_arma_cami.color_arma)

	if eleccion_arma_simon == null:
		match event.keycode:
			KEY_KP_1: eleccion_arma_simon = arma_1
			KEY_KP_2: eleccion_arma_simon = arma_2
			KEY_KP_3: eleccion_arma_simon = arma_3
		if eleccion_arma_simon != null:
			opcion_simon.text = "✅ %s" % eleccion_arma_simon.nombre_arma
			opcion_simon.add_theme_color_override("font_color", eleccion_arma_simon.color_arma)

	if eleccion_arma_cami != null and eleccion_arma_simon != null:
		fase_armas = false
		await get_tree().create_timer(1.0).timeout
		_mostrar_fase_accesorios()

func _input_accesorios(event: InputEventKey) -> void:
	var acc_cami: AccesorioData
	var acc_simon: AccesorioData

	if eleccion_acc_cami == null:
		match event.keycode:
			KEY_1: acc_cami = acc_1
			KEY_2: acc_cami = acc_2
			KEY_3: acc_cami = acc_3
			KEY_4: acc_cami = acc_4
		if acc_cami != null:
			eleccion_acc_cami = acc_cami
			opcion_cami.text = "✅ %s" % acc_cami.nombre_accesorio
			opcion_cami.add_theme_color_override("font_color", acc_cami.color_accesorio)

	if eleccion_acc_simon == null:
		match event.keycode:
			KEY_KP_1: acc_simon = acc_1
			KEY_KP_2: acc_simon = acc_2
			KEY_KP_3: acc_simon = acc_3
			KEY_KP_4: acc_simon = acc_4
		if acc_simon != null:
			eleccion_acc_simon = acc_simon
			opcion_simon.text = "✅ %s" % acc_simon.nombre_accesorio
			opcion_simon.add_theme_color_override("font_color", acc_simon.color_accesorio)

	if eleccion_acc_cami != null and eleccion_acc_simon != null:
		titulo.text = "¡Listos! A pelear..."
		timer_inicio.start()

func _on_timer_inicio_timeout() -> void:
	emit_signal("seleccion_completa", eleccion_arma_cami, eleccion_arma_simon, eleccion_acc_cami, eleccion_acc_simon)
	queue_free()
