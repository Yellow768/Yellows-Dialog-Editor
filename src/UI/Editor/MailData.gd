extends Control

@export var message_box_path : NodePath
@export var prev_button_path : NodePath
@export var next_button_path : NodePath
@export var delete_button_path : NodePath
@export var start_quest_path : NodePath


@onready var MessageBox : TextEdit = get_node(message_box_path)
@onready var PrevButton : Button = get_node(prev_button_path)
@onready var NextButton : Button = get_node(next_button_path)
@onready var DeleteButton : Button = get_node(delete_button_path)
@onready var StartQuest = get_node(start_quest_path)

var current_mail_object : mail_data_object
var current_page = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_page_button_pressed():
	current_page += 1
	if current_mail_object.pages.size() < current_page-1:
		current_mail_object.pages[current_page-1] = ""
	MessageBox.text = current_mail_object.pages[current_page-1]
		


func _on_prev_page_button_pressed():
	if current_page != 0:
		current_page -=1
	MessageBox.text = current_mail_object.pages[current_page-1]
	



func _on_delete_page_button_pressed():
	if current_mail_object.pages.size() == 0:
		MessageBox.text = ""
		return
	current_mail_object.pages.pop_at(current_page-1)
	if current_page-1 == current_mail_object.pages.size():
		current_page-=1
	MessageBox.text = current_mail_object.pages[current_page-1]


func _on_start_quest_mail_id_changed():
	pass # Replace with function body.
