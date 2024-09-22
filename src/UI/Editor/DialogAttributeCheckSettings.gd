extends Control

var tag_container = load("res://src/Nodes/attributes/tag_container.tscn")

@export var information_panel_path : NodePath
@onready var InformationPanel : Panel = get_node(information_panel_path)


@export var heart_path : NodePath
@export var body_path : NodePath
@export var mind_path : NodePath
@export var target_value_path : NodePath
@export var attributes_selection_container : NodePath

@export var tags_list_path : NodePath
@export var add_tag_path : NodePath
@export var pass_id_spinbox_path : NodePath
@export var fail_id_spinbox_path : NodePath
@export var xp_spinbox_path : NodePath

@export var update_dialog_button_path : NodePath

@onready var Heart : CheckBox = get_node(heart_path)
@onready var Body : CheckBox = get_node(body_path)
@onready var Mind : CheckBox = get_node(mind_path)
@onready var Target_Value : SpinBox = get_node(target_value_path)
@onready var Attribute_Selection_Container : VBoxContainer = get_node(attributes_selection_container)

@onready var Tags_List : VBoxContainer = get_node(tags_list_path)
@onready var Add_Tag_Button : Button = get_node(add_tag_path)
@onready var Pass_ID_SpinBox : SpinBox = get_node(pass_id_spinbox_path)
@onready var Fail_ID_SpinBox : SpinBox = get_node(fail_id_spinbox_path)
@onready var XP_Spinbox : SpinBox = get_node(xp_spinbox_path)

@onready var Update_Dialog_Button : Button = get_node(update_dialog_button_path)

var current_dialog
# Called when the node enters the scene tree for the first time.
func _ready():
	print(createAttributeCheckJson())

func load_current_dialog_settings(dialog_to_load : dialog_node):
	
	current_dialog = dialog_to_load
	print(current_dialog.attribute_check)
	return
	var attribute_check = JSON.parse_string(current_dialog.attribute_check)
	if attribute_check.attributes.has("Heart"):
		Heart.button_pressed = true
	if attribute_check.attributes.has("Body"):
		Body.button_pressed = true
	if attribute_check.attributes.has("Mind"):
		Mind.button_pressed = true
	Pass_ID_SpinBox.value = attribute_check.passID
	Fail_ID_SpinBox.value = attribute_check.failID
	XP_Spinbox.value = attribute_check.XP
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func createAttributeCheckJson():
	var attributes_array = []
	
	for attribute in Attribute_Selection_Container.get_children() :
		if attribute.button_pressed:
			attributes_array.append(attribute.text)
	var tags = []
	for tag in Tags_List.get_children():
		tags.append(tag.export())
	var json = {
		"target" : Target_Value.value,
		"attributes" : attributes_array, 
		"tag_modifiers":tags,
		"passID":Pass_ID_SpinBox.value,
		"failID":Fail_ID_SpinBox.value,
		"xp" : XP_Spinbox.value
	}
	return json



func _on_update_dialog_pressed():
	InformationPanel.current_dialog.set_dialog_text(JSON.stringify(createAttributeCheckJson()))
	InformationPanel.current_dialog.attribute_check = createAttributeCheckJson()
	print(current_dialog.attribute_check)

func _on_add_tag_button_pressed():
	var new_tag_instance = tag_container.instantiate()
	Tags_List.add_child(new_tag_instance)
