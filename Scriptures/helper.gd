class_name Helper

const Pieces = PhysicalPiece.Pieces

static func pgn_to_index(coord = "a1"):
	const tis = "abcdefgh"
	return (int(coord[1])-1)*8 + tis.find(coord[0].to_lower())

static func index_to_pgn(index=8):
	const tis = "abcdefgh"
	return (tis[index%8] + str(int(index/8.0)+1))

static func is_empty(piece : int):
	return not (piece&7)

static func is_piece(piece : int):
	return bool(piece&7)

static func is_white(piece : int):
	return (piece>>3)==1

static func is_black(piece : int):
	return (piece>>3)==2

static func color_of_piece(piece : int):
	return Pieces.Black if is_black(piece) else Pieces.White

static func index_to_vec(index : int):
	return Vector2(index%8, int(index/8.0))

static func vec_to_index(vec : Vector2):
	return vec.x+vec.y*8

static func kingly_dist(start : int, end : int):
	var s = index_to_vec(start)
	var e = index_to_vec(end)
	return max(abs(s.x-e.x),abs(s.y-e.y))
