class_name PhysicalPiece extends Node

enum Pieces {
	Empty = 0,
	King = 1,
	Queen = 2,
	Bishop = 3,
	Rook = 4,
	Knight = 5,
	Pawn = 6,
	
	White = 8,
	Black = 16
}

const WK = preload("res://Pieces/white/king.png")
const WQ = preload("res://Pieces/white/queen.png")
const WB = preload("res://Pieces/white/bishop.png")
const WN = preload("res://Pieces/white/knight.png")
const WR = preload("res://Pieces/white/rook.png")
const WP = preload("res://Pieces/white/pawn.png")
#Now the black pieces
const BK = preload("res://Pieces/black/king.png")
const BQ = preload("res://Pieces/black/queen.png")
const BB = preload("res://Pieces/black/bishop.png")
const BN = preload("res://Pieces/black/knight.png")
const BR = preload("res://Pieces/black/rook.png")
const BP = preload("res://Pieces/black/pawn.png")
const legal = preload("res://Pieces/legal.png")

@export var board : Board
@export_enum("King:1", "Queen:2", "Bishop:3", "Rook:4", "Knight:5", "Pawn:6") var piece : int = 6
@export_enum("White:8", "Black:16") var side : int = 8

func _process(delta: float) -> void:
	const texture_mapping = {
		9 : WK,
		10 : WQ,
		11 : WB,
		12 : WR,
		13 : WN,
		14 : WP, #Now the black pieces
		17 : BK,
		18 : BQ,
		19 : BB,
		20 : BR,
		21 : BN,
		22 : BP}
	$PieceImg.texture = texture_mapping[side | piece]
