extends Tree


func _ready():
	var root = create_item()
	root.set_text(0,"test")
	create_item(root).set_text(0,"test")
	create_item(root)
