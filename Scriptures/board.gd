@tool
class_name Board extends Node2D

@export_color_no_alpha var light = Color("97bbd7")
@export_color_no_alpha var dark = Color("3f7247")
@export var TILE_SIZE : int = 64
var FEN : String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

var Game = GameState.new(FEN)

func setup_beginning():
	var ts = TILE_SIZE
	queue_redraw()
	const tiler = preload("res://Scenes/tile_base.tscn")
	const piecer = preload("res://Scenes/physical_piece.tscn")
	for i in range(8):
		for j in range(8):
			var tile = tiler.instantiate()
			tile.position = Vector2((j-4)*ts+ts/2.0, (3-i)*ts+ts/2.0)
			tile.name = "Tile%d" % (8*i+j)
			$Areas.add_child(tile)
			if 8*i+j in Game.pindeces:
				var piece = piecer.instantiate()
				piece.position = Vector2((j-4)*ts+ts/2.0, (3-i)*ts+ts/2.0)
				piece.name = "At%d" % (8*i+j)
				piece.scale = Vector2(ts/170.0, ts/171.0)
				piece.piece = Game.board[8*i+j]
				$Pieces.add_child(piece)

func _draw() -> void:
	var ts = TILE_SIZE
	for i in range(8):
		for j in range(8):
			draw_rect(Rect2((i-4)*ts, (j-4)*ts, ts, ts), light if (i+j)%2 else dark)
	if Game.en_passant != -1:
		draw_circle(Vector2.ZERO, 70, Color.RED)

func _enter_tree() -> void:
	Game.position_changed.connect(_on_position_changed)
	setup_beginning()
	print(Game.repr())

func _on_position_changed():
	#TODO : Do piece moving logic
	pass
