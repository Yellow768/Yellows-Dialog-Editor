extends Control

@export var heart_path : NodePath
@export var body_path : NodePath
@export var mind_path : NodePath
@export var target_value_path : NodePath

@export var tags_list_path : NodePath
@export var add_tag_path : NodePath
@export var pass_id_spinbox_path : NodePath
@export var fail_id_spinbox_path : NodePath
@export var xp_spinbox_path : NodePath

@onready var Heart : CheckBox = get_node(heart_path)
@onready var Body : CheckBox = get_node(body_path)
@onready var Mind : CheckBox = get_node(mind_path)
@onready var Target_Value : CheckBox = get_node(target_value_path)

@onready var Tags_List : CheckBox = get_node(tags_list_path)
@onready var Add_Tag_Button : CheckBox = get_node(add_tag_path)
@onready var Pass_ID_SpinBox : CheckBox = get_node(pass_id_spinbox_path)
@onready var Fail_ID_SpinBox : CheckBox = get_node(fail_id_spinbox_path)
@onready var XP_Spinbox : CheckBox = get_node(xp_spinbox_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
