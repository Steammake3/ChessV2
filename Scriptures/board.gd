@tool
class_name Board extends Node2D

@export_color_no_alpha var light = Color("97bbd7")
@export_color_no_alpha var dark = Color("3f7247")
@export var TILE_SIZE : int = 64
var FEN : String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

const Pieces = PhysicalPiece.Pieces

const FENMAPPINGS = {"r" : Pieces.Black | Pieces.Rook, 
	"n" : Pieces.Black | Pieces.Knight,
	"b" : Pieces.Black | Pieces.Bishop,
	"q" : Pieces.Black | Pieces.Queen,
	"k" : Pieces.Black | Pieces.King,
	"p" : Pieces.Black | Pieces.Pawn,
	"R" : Pieces.White | Pieces.Rook,
	"N" : Pieces.White | Pieces.Knight,
	"B" : Pieces.White | Pieces.Bishop,
	"Q" : Pieces.White | Pieces.Queen,
	"K" : Pieces.White | Pieces.King,
	"P" : Pieces.White | Pieces.Pawn}

var board : Array = []
var current_move : int = Pieces.White
var castling_rights : int = 0
var en_passant : int = -1
var halfmove : int = 0
var fullmove : int = 0
var pindeces : Array = []

func _init():
	var fields = FEN.strip_edges().split(" ")
	#Decipher FEN boardstate
	var ranks = fields[0].split("/")
	
	for rank in ranks:
		var final = []
		for char_ in rank:
			if char_ in "12345678":
				for i in range(int(char_)):
					final.append(Pieces.Empty)
			else: final.append(self.FENMAPPINGS[char_])
		self.board = final + self.board
	
	#Get whose move it is
	self.current_move = Pieces.Black if fields[1]=="b" else Pieces.White
	
	#Determine castling rights (Bitflags White then Black, King then Queen)
	self.castling_rights = 0
	self.castling_rights |= int("K" in fields[2]) << 3
	self.castling_rights |= int("Q" in fields[2]) << 2
	self.castling_rights |= int("k" in fields[2]) << 1
	self.castling_rights |= int("q" in fields[2])
	
	#En Passant Square (-1 for null)
	self.en_passant = -1 if fields[3]=="-" else Helper.pgn_to_index(fields[3])
	
	#Halfmove - ++ each turn, unless move was a capture or pawn push
	self.halfmove = int(fields[4])
	
	#Fullmove - ++ Every time Black plays a move
	self.fullmove = int(fields[5])
	
	self.update_pindeces()

func update_pindeces():
	var retval = []
	for i in range(64):
		if Helper.is_piece(self.board[i]): retval.append(i)
	self.pindeces = retval

func repr():
	var retfener = []
	
	#Boardstate
	var INVFEN = {}
	for k in self.FENMAPPINGS:
		var v = self.FENMAPPINGS[k]
		INVFEN[v] = k
	var FENranks = []
	var boardranks = []
	for i in range(0, 64, 8):
		boardranks.append(self.board.slice(i, i + 8))
	
	for boardrank in boardranks:
		var FENrankers = []
		var emptc = 0 #Counter for empty cells
		for square in boardrank:
			if Helper.is_empty(square): emptc+=1
			else:
				FENrankers.append("%s%s" % [str(emptc) if emptc else '', INVFEN[square]])
				emptc = 0
		FENranks.append("".join(FENrankers) if FENrankers else "8")
	
	FENranks.reverse()
	retfener.append("/".join(PackedStringArray(FENranks)) + " ")
	
	#Current Move
	retfener.append("w " if self.current_move==Pieces.White else "b ")
	
	#Castling (dash means none)
	const RIGHTS = ["-", "q", "k", "kq", "Q", "Qq", "Qk", "Qkq", "K", "Kq", "Kk", "Kkq", "KQ", "KQq", "KQk", "KQkq"]
	retfener.append(RIGHTS[self.castling_rights] + " ")
	
	#En Passant (-1 means dash)
	retfener.append(("-" if self.en_passant==-1 else Helper.index_to_pgn(self.en_passant)) + " ")
	
	#Halfmove + Fullmove combo
	retfener.append("%d %d" % [self.halfmove,self.fullmove])
	
	return "".join(retfener)

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
			if 8*i+j in pindeces:
				var piece = piecer.instantiate()
				piece.position = Vector2((j-4)*ts+ts/2.0, (3-i)*ts+ts/2.0)
				piece.name = "At%d" % (8*i+j)
				piece.scale = Vector2(ts/170.0, ts/171.0)
				piece.piece = self.board[8*i+j]
				$Pieces.add_child(piece)

func _draw() -> void:
	var ts = TILE_SIZE
	for i in range(8):
		for j in range(8):
			draw_rect(Rect2((i-4)*ts, (j-4)*ts, ts, ts), light if (i+j)%2 else dark)
	if en_passant != -1:
		draw_circle(Vector2.ZERO, 70, Color.RED)

func _enter_tree() -> void:
	setup_beginning()
	print(repr())

func playmove(move : Move) -> bool:
	
