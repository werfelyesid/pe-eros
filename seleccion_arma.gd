extends CanvasLayer

## Fase 0: elegir modo (1P/2P). Fase 1: arma. Fase 2: accesorio.

@export var arma_1: ArmaData
@export var arma_2: ArmaData
@export var arma_3: ArmaData
@export var acc_1: AccesorioData
@export var acc_2: AccesorioData
@export var acc_3: AccesorioData
@export var acc_4: AccesorioData

var modo_un_jugador := false
var eleccion_arma_cami: ArmaData
var eleccion_arma_simon: ArmaData
var eleccion_acc_cami: AccesorioData
var eleccion_acc_simon: AccesorioData
var fase_actual := 0  # 0=modo, 1=armas, 2=accesorios

signal seleccion_completa(arma_cami: ArmaData, arma_simon: ArmaData, acc_cami: AccesorioData, acc_simon: AccesorioData, un_jugador: bool)

@onready var label_cami := $VBoxCami/LabelCami as Label
@onready var opcion_cami := $VBoxCami/OpcionCami as Label
@onready var label_simon := $VBoxSimon/LabelSimon as Label
@onready var opcion_simon := $VBoxSimon/OpcionSimon as Label
@onready var titulo := $Titulo as Label
@onready var timer_inicio := $TimerInicio as Timer

func _ready() -> void:
	_mostrar_fase_modo()

func _mostrar_fase_modo() -> void:
	titulo.text = "¿1 JUGADOR o 2 JUGADORES?\nCAMI: presiona 1 (solo) o 2 (vs Simon)"
	label_cami.text = "CAMI elige el modo"
	label_simon.text = ""
	opcion_cami.text = "1 = vs CPU    2 = vs Simon"
	opcion_simon.text = ""

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

	if fase_actual == 0:
		_input_modo(event)
	elif fase_actual == 1:
		_input_armas(event)
	else:
		_input_accesorios(event)

func _input_modo(event: InputEventKey) -> void:
	match event.keycode:
		KEY_1:
			modo_un_jugador = true
			opcion_cami.text = "✅ vs CPU"
			fase_actual = 1
			await get_tree().create_timer(0.5).timeout
			_mostrar_fase_armas()
		KEY_2:
			modo_un_jugador = false
			opcion_cami.text = "✅ vs Simon"
			fase_actual = 1
			await get_tree().create_timer(0.5).timeout
			_mostrar_fase_armas()

func _input_armas(event: InputEventKey) -> void:
	# En modo 1P, Simon elige aleatorio
	if modo_un_jugador and eleccion_arma_simon == null:
		eleccion_arma_simon = [arma_1, arma_2, arma_3][randi() % 3]
		opcion_simon.text = "✅ %s (CPU)" % eleccion_arma_simon.nombre_arma
		opcion_simon.add_theme_color_override("font_color", eleccion_arma_simon.color_arma)

	if eleccion_arma_cami == null:
		match event.keycode:
			KEY_1: eleccion_arma_cami = arma_1
			KEY_2: eleccion_arma_cami = arma_2
			KEY_3: eleccion_arma_cami = arma_3
		if eleccion_arma_cami != null:
			opcion_cami.text = "✅ %s" % eleccion_arma_cami.nombre_arma
			opcion_cami.add_theme_color_override("font_color", eleccion_arma_cami.color_arma)

	if not modo_un_jugador and eleccion_arma_simon == null:
		match event.keycode:
			KEY_KP_1: eleccion_arma_simon = arma_1
			KEY_KP_2: eleccion_arma_simon = arma_2
			KEY_KP_3: eleccion_arma_simon = arma_3
		if eleccion_arma_simon != null:
			opcion_simon.text = "✅ %s" % eleccion_arma_simon.nombre_arma
			opcion_simon.add_theme_color_override("font_color", eleccion_arma_simon.color_arma)

	if eleccion_arma_cami != null and eleccion_arma_simon != null:
		if modo_un_jugador:
			opcion_cami.text += "\nPresiona ENTER para seguir"
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				fase_actual = 2
				await get_tree().create_timer(0.5).timeout
				_mostrar_fase_accesorios()
		else:
			fase_actual = 2
			await get_tree().create_timer(1.0).timeout
			_mostrar_fase_accesorios()

func _input_accesorios(event: InputEventKey) -> void:
	var acc_cami: AccesorioData
	var acc_simon: AccesorioData

	# En modo 1P, Simon elige aleatorio
	if modo_un_jugador and eleccion_acc_simon == null:
		eleccion_acc_simon = [acc_1, acc_2, acc_3, acc_4][randi() % 4]
		opcion_simon.text = "✅ %s (CPU)" % eleccion_acc_simon.nombre_accesorio
		opcion_simon.add_theme_color_override("font_color", eleccion_acc_simon.color_accesorio)

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

	if not modo_un_jugador and eleccion_acc_simon == null:
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
		if modo_un_jugador:
			opcion_cami.text += "\nPresiona ENTER para pelear"
			if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
				titulo.text = "¡A pelear!"
				timer_inicio.start()
		else:
			titulo.text = "¡Listos! A pelear..."
			timer_inicio.start()

func _on_timer_inicio_timeout() -> void:
	emit_signal("seleccion_completa", eleccion_arma_cami, eleccion_arma_simon, eleccion_acc_cami, eleccion_acc_simon, modo_un_jugador)
	queue_free()
