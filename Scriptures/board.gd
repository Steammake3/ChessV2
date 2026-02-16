@tool
class_name Board extends Node2D

@export_color_no_alpha var light = Color("97bbd7")
@export_color_no_alpha var dark = Color("3f7247")
@export var TILE_SIZE : int = 64

const FEN : String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
const tiler = preload("res://Scenes/tile_base.tscn")
const piecer = preload("res://Scenes/physical_piece.tscn")

var Game := GameState.new(FEN)
var selection : int
signal clear_prev_select(id : int)

func setup_beginning():
	var ts = TILE_SIZE
	queue_redraw()
	for i in range(8):
		for j in range(8):
			$Areas.add_child(new_tilebase_at(i, j, ts))
			if 8*i+j in Game.pindeces:
				$Pieces.add_child(new_piece_at(i, j, ts))

func new_tilebase_at(i, j, ts):
	var tile := tiler.instantiate() as TileBase
	tile.position = Vector2((j-4)*ts+ts/2.0, (3-i)*ts+ts/2.0)
	tile.name = "Tile%d" % (8*i+j)
	tile.pos = int(8*i+j)
	tile.board = self
	return tile

func new_piece_at(i, j, ts, scalar = 1) -> PhysicalPiece:
	var piece := piecer.instantiate() as PhysicalPiece
	piece.position = Vector2((j-4)*ts+ts/2.0, (3-i)*ts+ts/2.0)
	piece.name = "At%d" % (8*i+j)
	piece.scale = Vector2(ts/170.0*scalar, ts/171.0*scalar)
	piece.piece = int(Game.board[8*i+j])
	return piece

func _draw() -> void:
	var ts = TILE_SIZE
	for i in range(8):
		for j in range(8):
			draw_rect(Rect2((i-4)*ts, (j-4)*ts, ts, ts), light if (i+j)%2 else dark)
	if Game.en_passant != -1:
		var piece : PhysicalPiece = new_piece_at(int(Game.en_passant / 8.0), Game.en_passant%8, ts, 0.5)
		piece.modulate.a = 0.5
		const Pieces = PhysicalPiece.Pieces
		piece.piece = Pieces.Pawn | (Pieces.Black if Game.en_passant>31 else Pieces.White)
		piece.rotation  = TAU/2.0
		$Pieces.add_child(piece)

func _ready() -> void:
	Game.position_changed.connect(_on_position_changed)
	clear_prev_select.connect(_on_select_cleared)
	setup_beginning()
	print(Game.repr())

func _on_position_changed():
	#TODO : Do piece moving logic
	pass

func _on_select_cleared(post):
	if post==-1: return
	if Helper.color_of_piece(Game.board[post])==Game.current_move:
		selection = post
