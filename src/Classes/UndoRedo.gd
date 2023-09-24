extends Node
class_name UndoSystem

var action_history = []

func create_action(node : dialog_node):
	var node_reference = node.duplicate(DUPLICATE_USE_INSTANTIATION)
	var action = {
		"do" : {"function" : "add_dialog_node","node": GlobalDeclarations.DIALOG_NODE.instantiate()},
		"undo" : {"function" : "delete_dialog_node","node": GlobalDeclarations.DIALOG_NODE.instantiate()}
	}


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
