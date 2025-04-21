extends Control
class_name custom_text_edit
signal text_changed


var built_in_environment_variables = {
	"$CategoryName" : "get_category_name",
	"$DialogNode" : "get_dialog_node",
	"$DialogID" : "get_dialog_id"
	}


var text : set = set_text, get = get_text

@export var parent_node : Node

func _ready():
	$TextEdit.size = size
	$RichTextLabel.size = size

# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_dialog_node():
	if not is_inside_tree(): await self.ready
	if parent_node.is_class("GraphNode") && parent_node.node_type == "Dialog Node":
		return parent_node.node_index
	else:
		return "DialogNode"
		
func get_category_name():
	return CurrentEnvironment.current_category_name

func get_dialog_id():
	if parent_node.is_class("GraphNode") && parent_node.node_type == "Dialog Node":
		return parent_node.dialog_id
	else:
		return "DialogNode"

func update_rich_text_label():
	var text = $TextEdit.text
	for variable in built_in_environment_variables:
		text = text.replace(variable,(str(call(built_in_environment_variables[variable]))))
	$RichTextLabel.text = text+"\n"


func _on_dialog_text_text_changed():
	text_changed.emit()
	update_rich_text_label()


func _on_text_edit_text_set():
	update_rich_text_label()
	
func set_text(value):
	$TextEdit.text = value
	update_rich_text_label()

func get_text():
	return $TextEdit.text


func _on_text_edit_mouse_entered():
	$RichTextLabel.visible = false


func _on_text_edit_mouse_exited():
	if !$TextEdit.has_selection():
		$RichTextLabel.visible = true
		$RichTextLabel.get_v_scroll_bar().set_value_no_signal($TextEdit.get_v_scroll()*21)
