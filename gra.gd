extends GraphEdit


func _ready():
	for i in 1050:
		var node = GraphNode.new()
		node.global_position = Vector2(randf_range(0,50),randf_range(0,50))
		node.visible = true
		add_child(node)
