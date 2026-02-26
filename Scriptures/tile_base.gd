class_name TileBase extends Area2D

var board : Board
var pos_ : int

@onready var shape = $CollisionShape2D

func set_size(ts):
	var rect = shape.shape as RectangleShape2D
	rect.size = Vector2(ts - 12, ts - 12) # keep margin similar to 52 vs 64

	$Selected/Fill.offset_left = -ts/2
	$Selected/Fill.offset_top = -ts/2
	$Selected/Fill.offset_right = ts/2
	$Selected/Fill.offset_bottom = ts/2

	$Hovered.offset_left = -ts/2
	$Hovered.offset_top = -ts/2
	$Hovered.offset_right = ts/2
	$Hovered.offset_bottom = ts/2
	set_width(6*ts/64)

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
			
			if Helper.is_empty(piece):
				board.emit_signal("general_select", pos_)
				return
			if Helper.color_of_piece(piece) != board.Game.current_move:
				board.emit_signal("general_select", pos_)
				return
			
			board.emit_signal("clear_prev_select", pos_)
			$Selected.visible = not $Selected.visible 

func _on_clear_prev_select(post):
	if pos_ != post: $Selected.hide()

func set_width(w):
	$Selected/Outline.width=w
