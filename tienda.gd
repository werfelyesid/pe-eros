extends CanvasLayer

## Tienda donde los jugadores pueden gastar sus monedas.

signal tienda_cerrada

@onready var titulo: Label = $Titulo
@onready var info: Label = $Info
@onready var label_cami: Label = $LabelCami
@onready var label_simon: Label = $LabelSimon

var monedero: Node

func _ready() -> void:
	monedero = get_node_or_null("/root/arena/Monedero")
	if monedero == null:
		# Buscar en el padre
		var arena := get_tree().get_first_node_in_group("arena")
		if arena:
			monedero = arena.get_node_or_null("Monedero")
	
	_actualizar_texto()

func _actualizar_texto() -> void:
	var mc := 0
	var ms := 0
	if monedero:
		mc = monedero.monedas_cami
		ms = monedero.monedas_simon
	
	titulo.text = "🏪 TIENDA PEÑEROS 🏪"
	info.text = "Precios:\n"
	info.text += "1: 🗡️ Espada (10🪙)  2: 🏹 Lanza (10🪙)  3: 🔨 Martillo (10🪙)\n"
	info.text += "4: 🛡️ Escudo (15🪙)  5: 👢 Botas (15🪙)  6: 🧥 Capa (20🪙)  7: 🦺 Pechera (15🪙)\n"
	info.text += "8: 🔥 Fuego (25🪙)\n\n"
	info.text += "Presiona ENTER para volver a pelear"
	
	label_cami.text = "Cami: %d 🪙" % mc
	label_simon.text = "Simon: %d 🪙" % ms

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			emit_signal("tienda_cerrada")
			queue_free()
