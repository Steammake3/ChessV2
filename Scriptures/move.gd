class_name Move extends Node

var start_sq := 0
var end_sq := 0
var promo = 0 #0 Queen, 1 Rook, 2 Bishop, 3 Knight

func _init(s,e,p) -> void:
	start_sq = s
	end_sq = e
	promo = p
