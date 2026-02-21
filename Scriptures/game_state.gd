class_name GameState

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

signal position_changed

func _init(fen):
	var fields = fen.strip_edges().split(" ")
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

func playmove(move : Move):
	#TODO : pindeces & normal moves
	if not is_legal(move): return false
	emit_signal("position_changed")
	var start = move.start_sq
	var end = move.end_sq
	var promo = move.promo
	var black_is : bool = Pieces.Black==current_move
	var explicit_moves : Array[Move] = []
	
	match self.board[start]&7:
		Pieces.King:
			self.castling_rights &= 0b1100 if black_is else 0b0011
			if Helper.kingly_dist(start, end)>1: #Castling
				var kingside : bool = (end-start)>0
				kingside = kingside != black_is
				explicit_moves.append(move.cleaned())
				match int(kingside)*2+int(black_is):
					0: explicit_moves.append(Move.new(0,3))
					1: explicit_moves.append(Move.new(56,59))
					2: explicit_moves.append(Move.new(7,5))
					3: explicit_moves.append(Move.new(63,61))
		Pieces.Rook:
			if start==(63 if black_is else 7): self.castling_rights &= 0b10 << (int(black_is)*2)
			elif start==(56 if black_is else 0): self.castling_rights &= 0b01 << (int(black_is)*2)
			explicit_moves.append(move.cleaned())
		Pieces.Pawn: #Oof this fina be painful
			if end==self.en_passant:
				explicit_moves.append(move.cleaned())
				self.board[end+(8 if black_is else -8)] = Pieces.Empty
			if (end>>3)==(0 if black_is else 7):
				_explicitly_move(move.cleaned())
				const PROMOMAP = [Pieces.Queen, Pieces.Rook, Pieces.Bishop, Pieces.Knight]
				self.board[end] = PROMOMAP[promo] | self.current_move

func is_legal(move : Move) -> bool:
	#Add legality logic
	return true

func _explicitly_move(move : Move):
	self.board[move.end_sq] = self.board[move.start_sq]
	self.board[move.start_sq] = Pieces.Empty
