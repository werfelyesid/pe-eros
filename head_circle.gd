@tool
extends Node2D

@export var radio: float = 28.0:
	set(value):
		radio = max(value, 1.0)
		queue_redraw()

@export var color_relleno: Color = Color(1.0, 0.85, 0.7):
	set(value):
		color_relleno = value
		queue_redraw()

@export var color_borde: Color = Color(0, 0, 0):
	set(value):
		color_borde = value
		queue_redraw()

@export var grosor_borde: float = 2.0:
	set(value):
		grosor_borde = max(value, 0.0)
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radio, color_relleno)
	if grosor_borde > 0.0:
		draw_arc(Vector2.ZERO, radio, 0.0, TAU, 64, color_borde, grosor_borde)
