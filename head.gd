extends Node2D

@export var radio: float = 30.0
@export var color_cabeza: Color = Color(1.0, 0.85, 0.7)

func _draw():
	draw_circle(Vector2.ZERO, radio, color_cabeza)

func _ready():
	queue_redraw() # Fuerza el dibujo inicial
