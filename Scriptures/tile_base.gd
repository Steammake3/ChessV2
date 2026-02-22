class_name TileBase extends Area2D

var board : Board
var pos_ : int

func _ready() -> void:
	$Hovered.hide()
	$Selected.hide()
	board.clear_prev_select.connect(_on_clear_prev_select)

func _mouse_enter() -> void:
	$Hovered.show()

func _mouse_exit() -> void:
	$Hovered.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and $Hovered.visible and event.pressed:
			var piece = board.Game.board[pos_]
			
			if Helper.is_empty(piece): return
			if Helper.color_of_piece(piece) != board.Game.current_move: return
			
			board.emit_signal("clear_prev_select", pos_)
			$Selected.visible = not $Selected.visible 

func _on_clear_prev_select(post):
	if pos_ != post: $Selected.hide()
