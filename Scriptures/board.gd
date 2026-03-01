@tool
class_name Board extends Node2D

@export_color_no_alpha var light = Color("97bbd7")
@export_color_no_alpha var dark = Color("3f7247")
@export var TILE_SIZE : int = 64
@export var animation_time : float = 1.0
@export var SZ_STRONG : float = 0.125
@export var variable_speed : bool = true
@export var promoter : Options

const FEN : String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
const tiler = preload("res://Scenes/tile_base.tscn")
const piecer = preload("res://Scenes/physical_piece.tscn")

var Game := GameState.new(FEN)
var en_passant_handled := false
var selection : int
signal clear_prev_select(id : int)
signal general_select(id : int)

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
	tile.pos_ = int(8*i+j)
	tile.board = self
	#tile.call_deferred("set_scale", Vector2(ts/64, ts/64))
	return tile

func new_piece_at(i, j, ts, scalar = 1) -> PhysicalPiece:
	var piece := piecer.instantiate() as PhysicalPiece
	piece.board = self
	piece.position = Vector2((j-4)*ts+ts/2.0, (3-i)*ts+ts/2.0)
	piece.name = "At%d" % (8*i+j)
	piece.scale = Vector2(ts/170.0*scalar, ts/171.0*scalar)
	piece.set_piece(int(Game.board[8*i+j]))
	return piece

func _draw() -> void:
	var ts = TILE_SIZE
	for i in range(8):
		for j in range(8):
			draw_rect(Rect2((i-4)*ts, (j-4)*ts, ts, ts), light if (i+j)%2 else dark)
	if Game.en_passant != -1 and not en_passant_handled:
		var piece : PhysicalPiece = new_piece_at(int(Game.en_passant / 8.0), Game.en_passant%8, ts, 0.5)
		piece.name = "AtEP"
		piece.en_passant_repr = Game.en_passant
		piece.modulate.a = 0.5
		const Pieces = PhysicalPiece.Pieces
		piece.set_piece(Pieces.Pawn | (Pieces.Black if Game.en_passant>31 else Pieces.White))
		piece.rotation  = TAU/2.0
		$Pieces.add_child(piece)
		en_passant_handled = true
	if Game.en_passant==-1 and en_passant_handled:
		get_node("Pieces/AtEP").queue_free()
		en_passant_handled = false

func _ready() -> void:
	Game.position_changed.connect(_on_position_changed)
	clear_prev_select.connect(_on_select_cleared)
	general_select.connect(_on_general_selection)
	setup_beginning()
	print(Game.repr())

func _on_position_changed(explicit_moves, promod):
	if promod>0:
		await move_piece(explicit_moves[0])
		get_node("Pieces/At%d" % explicit_moves[0].end_sq).set_piece(promod)
	elif promod==-1:
		for move in explicit_moves: move_piece(move)
	elif promod==0:
		move_piece(explicit_moves[0])
		var piece : PhysicalPiece = new_piece_at(int(Game.en_passant / 8.0), Game.en_passant%8, TILE_SIZE, 0.5)
		piece.name = "AtEP"
		piece.en_passant_repr = Game.en_passant
		piece.modulate.a = 0
		const Pieces = PhysicalPiece.Pieces
		piece.set_piece(Pieces.Pawn | (Pieces.Black if Game.en_passant>31 else Pieces.White))
		piece.rotation  = TAU/2.0
		$Pieces.add_child(piece)
		await piece.create_thyself(animation_time)

func _on_select_cleared(post):
	if post==-1: selection=-1; return
	if Helper.color_of_piece(Game.board[post])==Game.current_move:
		selection = post

func _on_general_selection(post):
	if selection!=-1:
		Game.playmove(Move.new(selection, post, promoter.choice if promoter else 0))
		emit_signal("clear_prev_select", -1)

func move_piece(move : Move):
	var ts = TILE_SIZE
	var start_piece = get_node("Pieces/At%d" % move.start_sq)
	var o_scale = start_piece.scale
	
	var end_vec = Helper.index_to_vec(move.end_sq)
	end_vec = Vector2((end_vec.x-4)*ts+ts/2.0, (3-end_vec.y)*ts+ts/2.0)
	var anim_time = Helper.index_to_vec(move.end_sq).distance_to(Helper.index_to_vec(move.start_sq))
	var x = anim_time/(8*sqrt(2))
	anim_time = animation_time/(1-0.3*(1-x)*(1-x)) if variable_speed else animation_time
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(start_piece, "position", end_vec, anim_time) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	#Scale bruh
	tween.tween_method(
		func(x):
			if not start_piece: return
			var factor = 1 + SZ_STRONG - 16 * SZ_STRONG * pow(x - 0.5, 4)
			start_piece.scale = o_scale * factor,
	0.0, 1.0, anim_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	var captured = get_node_or_null("Pieces/At%d" % move.end_sq)
	var en_passnt = get_node_or_null("Pieces/AtEP")
	
	if move.start_sq==move.end_sq: start_piece.queue_free()
	elif en_passnt:
		if move.end_sq==en_passnt.en_passant_repr:
			get_node("Pieces/AtEP").queue_free()
	elif captured:
		captured.name = "MeantToDie"
		captured.queue_free()
	
	start_piece.call_deferred("set_name", "At%d" % move.end_sq)
