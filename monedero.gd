extends Node

## Guarda y carga las monedas del jugador en un archivo JSON.
## Las monedas no se pierden al cerrar el juego.

const RUTA := "user://monedas_peñeros.json"

var monedas_cami := 0
var monedas_simon := 0

func _ready() -> void:
	_cargar()

func _cargar() -> void:
	if not FileAccess.file_exists(RUTA):
		return

	var archivo := FileAccess.open(RUTA, FileAccess.READ)
	if archivo == null:
		return

	var texto := archivo.get_as_text()
	archivo.close()

	var json := JSON.new()
	var error := json.parse(texto)
	if error == OK:
		var datos = json.data
		monedas_cami = int(datos.get("cami", 0))
		monedas_simon = int(datos.get("simon", 0))

func _guardar() -> void:
	var datos := {
		"cami": monedas_cami,
		"simon": monedas_simon
	}
	var archivo := FileAccess.open(RUTA, FileAccess.WRITE)
	if archivo == null:
		return

	archivo.store_string(JSON.stringify(datos, "\t"))
	archivo.close()

func sumar_monedas(jugador: String, cantidad: int) -> void:
	if jugador == "cami":
		monedas_cami += cantidad
	else:
		monedas_simon += cantidad
	_guardar()

func gastar_monedas(jugador: String, cantidad: int) -> bool:
	if jugador == "cami":
		if monedas_cami >= cantidad:
			monedas_cami -= cantidad
			_guardar()
			return true
	else:
		if monedas_simon >= cantidad:
			monedas_simon -= cantidad
			_guardar()
			return true
	return false
