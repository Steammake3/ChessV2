class_name Options extends Node2D

#TODO : make sure that it chooses and updates on color

const Pieces = PhysicalPiece.Pieces

var color : int
signal chosen(choosed)

func _init(colour = 16) -> void:
	color = colour

func _ready() -> void:
	$Options/Queen.pressed.connect(_queen)
	$Options/Rook.pressed.connect(_rook)
	$Options/Bishop.pressed.connect(_bishop)
	$Options/Knight.pressed.connect(_knight)
	order_up()

func _queen():
	emit_signal("chosen", 0)

func _rook():
	emit_signal("chosen", 1)

func _bishop():
	emit_signal("chosen", 2)

func _knight():
	emit_signal("chosen", 3)
	
func order_up():
	if color==Pieces.Black:
		$Options/Queen.icon=preload("res://Pieces/black/queen.png")
		$Options/Rook.icon=preload("res://Pieces/black/rook.png")
		$Options/Bishop.icon=preload("res://Pieces/black/bishop.png")
		$Options/Knight.icon=preload("res://Pieces/black/knight.png")
		var littlekids = $Options.get_children()
		#Ordering
		for i in range(0,4):
			$Options.move_child(littlekids[i], 3-i)
