extends Control

var tag_container = load("res://src/Nodes/attributes/tag_container.tscn")

@export var information_panel_path : NodePath
@onready var InformationPanel : Panel = get_node(information_panel_path)


@export var heart_path : NodePath
@export var body_path : NodePath
@export var mind_path : NodePath
@export var soul_path : NodePath
@export var target_value_path : NodePath
@export var attributes_selection_container : NodePath

@export var tags_list_path : NodePath
@export var add_tag_path : NodePath
@export var white_check_checkbox_path : NodePath
@export var pass_xp_spinbox_path : NodePath
@export var fail_xp_spinbox_path : NodePath

@export var update_dialog_button_path : NodePath

@onready var Heart : CheckBox = get_node(heart_path)
@onready var Body : CheckBox = get_node(body_path)
@onready var Mind : CheckBox = get_node(mind_path)
@onready var Soul : CheckBox = get_node(soul_path)
@onready var Target_Value : SpinBox = get_node(target_value_path)
@onready var Attribute_Selection_Container : VBoxContainer = get_node(attributes_selection_container)

@onready var Tags_List : VBoxContainer = get_node(tags_list_path)
@onready var Add_Tag_Button : Button = get_node(add_tag_path)
@onready var White_Check_Checkbox : CheckBox = get_node(white_check_checkbox_path)
@onready var Pass_XP_Spinbox : SpinBox = get_node(pass_xp_spinbox_path)
@onready var Fail_XP_Spinbox : SpinBox = get_node(fail_xp_spinbox_path)

@onready var Update_Dialog_Button : Button = get_node(update_dialog_button_path)

var current_dialog
# Called when the node enters the scene tree for the first time.
func _ready():
	print(createAttributeCheckJson())

func load_current_dialog_settings(dialog_to_load : dialog_node):
	
	current_dialog = dialog_to_load
	var attribute_check = current_dialog.attribute_check
	if attribute_check == {}: 
		attribute_check = {
		"target" : 0,
		"attributes" : [], 
		"tag_modifiers":[],
		"white_check":true,
		"pass_xp" : 0,
		"fail_xp" : 0
	}
	var keys = ["target","attributes","tag_modifiers","white_check","pass_xp","fail_xp"]
	for key in keys:
		if !attribute_check.has(key):
			attribute_check[key] = 0
	
	Heart.button_pressed = attribute_check.attributes.has("Heart")
	Body.button_pressed = attribute_check.attributes.has("Body")
	Mind.button_pressed =attribute_check.attributes.has("Mind")
	Soul.button_pressed = attribute_check.attributes.has("Soul")
	White_Check_Checkbox.button_pressed = attribute_check.white_check
	Pass_XP_Spinbox.value = attribute_check.pass_xp
	Fail_XP_Spinbox.value = attribute_check.fail_xp
	Target_Value.value = attribute_check.target
	for child in Tags_List.get_children():
		child.queue_free()
	var tags =attribute_check.tag_modifiers
	for tag in tags:
		var parse_tag = JSON.parse_string(tag)
		var new_tag = tag_container.instantiate()
		new_tag.display = parse_tag.display
		new_tag.id = parse_tag.id
		new_tag.value = parse_tag.value
		Tags_List.add_child(new_tag)
	

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
		"white_check":White_Check_Checkbox.button_pressed,
		"pass_xp" : Pass_XP_Spinbox.value,
		"fail_xp" : Fail_XP_Spinbox.value
	}
	return json



func _on_update_dialog_pressed():
	InformationPanel.current_dialog.set_dialog_text("<att check> \n"+JSON.stringify(createAttributeCheckJson()))
	InformationPanel.current_dialog.attribute_check = createAttributeCheckJson()
	

func _on_add_tag_button_pressed():
	var new_tag_instance = tag_container.instantiate()
	Tags_List.add_child(new_tag_instance)
