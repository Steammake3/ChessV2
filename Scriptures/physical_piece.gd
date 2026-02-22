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

signal piece_change
var piece : int = 14
var en_passant_repr := -1
var _internal_ep_counter = 0

func _ready() -> void:
	piece_change.connect(_piece_changed)
	board.Game.position_changed.connect(_move_made)
	piece_change.emit()

func _piece_changed():
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
	$PieceImg.texture = texture_mapping[piece]

func set_piece(pieced):
	if pieced==piece: return
	piece=pieced
	emit_signal("piece_change")

func _move_made(explicit_moves, promod):
	if en_passant_repr>=0: _internal_ep_counter+=1
	if _internal_ep_counter==1: await delete_thyself(board.animation_time)

func delete_thyself(animation_time):
	var a34 = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT) \
		.tween_property(self, "modulate:a", 0, animation_time)
	await a34.finished
	self.queue_free()

func create_thyself(animation_time):
	create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT) \
			.tween_property(self, "modulate:a", 0.5, animation_time)
