class_name Options extends Node2D

#TODO : make sure that it chooses and updates on color

const Pieces = PhysicalPiece.Pieces

var color : int
signal chosen(choosed)
var choice : int = 0

func _init(colour = 8) -> void:
	color = colour

func _ready() -> void:
	$Options/Queen.toggled.connect(_queen)
	$Options/Rook.toggled.connect(_rook)
	$Options/Bishop.toggled.connect(_bishop)
	$Options/Knight.toggled.connect(_knight)
	chosen.connect(_update_choice)
	order_up()

func _queen(x):
	emit_signal("chosen", 0)

func _rook(x):
	emit_signal("chosen", 1)

func _bishop(x):
	emit_signal("chosen", 2)

func _knight(x):
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

func _update_choice(chose):
	choice = chose
