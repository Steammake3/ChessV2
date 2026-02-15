class_name Helper extends Node

const Pieces = PhysicalPiece.Pieces

static func pgn_to_index(coord = "a1"):
	const tis = "abcdefgh"
	return (int(coord[1])-1)*8 + tis.find(coord[0].lower())

static func index_to_pgn(index=8):
	const tis = "abcdefgh"
	return (tis[index%8] + str(int(index/8.0)+1))

static func is_empty(piece):
	return not (piece&7)

static func is_piece(piece):
	return bool(piece&7)

static func is_white(piece):
	return (piece>>3)==1

static func is_black(piece):
	return (piece>>3)==2
