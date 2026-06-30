class_name AccesorioData extends Resource

## Datos de un accesorio que modifica las habilidades del jugador.

enum Tipo {
	ESCUDO,    # Recibe la mitad de daño
	BOTAS,     # Salta más alto
	CAPA,      # Gravedad reducida (planear)
	PECHERA    # +20 vida máxima, -20% velocidad
}

@export var nombre_accesorio := "Accesorio"
@export var tipo: Tipo = Tipo.ESCUDO
@export var descripcion := ""
@export var color_accesorio := Color.WHITE

## Valor del efecto (ej: 0.5 para escudo = 50% menos daño)
@export var multiplicador_dano_recibido := 1.0
@export var multiplicador_salto := 1.0
@export var multiplicador_gravedad := 1.0
@export var bonus_vida := 0
@export var multiplicador_velocidad := 1.0
