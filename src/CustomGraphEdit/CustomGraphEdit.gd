extends Container

var dragging := false
var selected := []
var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()

func _ready():
	for i in 950:
		var new_node = load("res://src/CustomGraphEdit/CustomDialogNode.tscn").instantiate()
		new_node.position = Vector2(randf_range(0,5020),randf_range(0,2080))
		add_child(new_node)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# We only want to start a drag if there's no selection.
			if selected.size() == 0:
				dragging = true
				drag_start = get_global_mouse_position()
		elif dragging:
			# Button released while dragging.
			dragging = false
	if event.is_action_released("drag"):
		dragging = false
		update()
	if event is InputEventMouseMotion and dragging:
		update()

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
				Color(.5, .5, .5), false)



