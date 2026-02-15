@tool
class_name Board extends Node2D

@export_color_no_alpha var light = Color("97bbd7")
@export_color_no_alpha var dark = Color("3f7247")

func _draw() -> void:
	for i in range(8):
		for j in range(8):
			draw_rect(Rect2((i-4)*40, (j-4)*40, 40, 40), dark if (i+j)%2 else light)
