extends GraphEdit


func _ready():
	for i in 1050:
		var node = GraphNode.new()
		node.rect_global_position = Vector2(rand_range(0,50),rand_range(0,50))
		node.visible = true
		add_child(node)
