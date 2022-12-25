extends Panel


func _ready():
	for i in 650:
		var node = GraphNode.new()
		node.rect_global_position = Vector2(rand_range(0,50),rand_range(0,50))
		add_child(node)


func _process(delta):
	if Input.is_action_pressed("shift"):
		$Camera2D.position += Vector2(10,0)
