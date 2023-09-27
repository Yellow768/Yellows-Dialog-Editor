extends Control

@export var message_box_path : NodePath
@export var prev_button_path : NodePath
@export var next_button_path : NodePath
@export var delete_button_path : NodePath
@export var start_quest_path : NodePath
@export var item_slots_path : NodePath
@export var subject_line_path : NodePath
@export var sender_line_path : NodePath
@export var page_label_path : NodePath

@onready var MessageBox : TextEdit = get_node(message_box_path)
@onready var PrevButton : Button = get_node(prev_button_path)
@onready var NextButton : Button = get_node(next_button_path)
@onready var DeleteButton : Button = get_node(delete_button_path)
@onready var StartQuest = get_node(start_quest_path)
@onready var ItemSlots : VBoxContainer = get_node(item_slots_path)
@onready var SubjectLine : LineEdit = get_node(subject_line_path)
@onready var SenderLine : LineEdit = get_node(sender_line_path)
@onready var PageLabel : Label = get_node(page_label_path)

var current_mail_object : mail_data_object
var current_page = 1

var loading_mail : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in ItemSlots.get_children():
		slot.connect("id_changed",Callable(self,"update_slot").bind(slot.slot))
		slot.connect("nbt_changed",Callable(self,"update_slot").bind(slot.slot))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_mail_data(data : mail_data_object):
	loading_mail = true
	current_mail_object = data
	current_page = 1
	if current_mail_object.pages.size() != 0:
		MessageBox.text = current_mail_object.pages[0]
	else:
		MessageBox.text = ""
	SenderLine.text = current_mail_object.sender
	SubjectLine.text = current_mail_object.subject
	loading_mail = false
	
		


func update_slot(slot : mail_item_slot):
	var slot_nbt_string : String
	if !slot.nbt_data.is_empty():
		slot.nbt_data.replace('"Slot": 0b',"")
		slot.nbt_data.replace('"Slot": 1b',"")
		slot.nbt_data.replace('"Slot": 2b',"")
		slot.nbt_data.replace('"Slot": 3b',"")
		slot.nbt_data.strip_edges()
		slot_nbt_string = '"Slot": '+str(slot.slot)+'b\\n'+slot.nbt_data
	else:
		slot_nbt_string = '"Slot": '+str(slot.slot)+'b\\n'+slot.item_id+"\\n"+str(slot.item_count)
	current_mail_object.items_slots[slot.slot] = "{"+slot_nbt_string+"}"
		
		
		
func _on_next_page_button_pressed():
	current_page += 1
	if current_mail_object.pages.is_empty():
		current_mail_object.pages.append("")
	if current_mail_object.pages.size() < current_page:
		current_mail_object.pages.append("")
	MessageBox.text = current_mail_object.pages[current_page-1]
	PageLabel.text = "Page "+str(current_page)+"/"+str(current_mail_object.pages.size())
		


func _on_prev_page_button_pressed():
	if current_page != 0:
		current_page -=1
	MessageBox.text = current_mail_object.pages[current_page-1]
	PageLabel.text = "Page "+str(current_page)+"/"+str(current_mail_object.pages.size())
	



func _on_delete_page_button_pressed():
	if current_mail_object.pages.size() == 0:
		MessageBox.text = ""
		return
	current_mail_object.pages.pop_at(current_page-1)
	if current_page-1 == current_mail_object.pages.size():
		current_page-=1
	MessageBox.text = current_mail_object.pages[current_page-1]
	PageLabel.text = "Page "+str(current_page)+"/"+str(current_mail_object.pages.size())


func _on_start_quest_mail_id_changed():
	current_mail_object.quest_id = StartQuest.quest_id


func _on_message_text_changed():
	if loading_mail:
		return
	if current_mail_object.pages.size() < current_page-1 || current_mail_object.pages.size() == 0:
		current_mail_object.pages.append(MessageBox.text)
	else:
		current_mail_object.pages[current_page-1] = MessageBox.text




func _on_sender_line_edit_text_changed(new_text):
	if loading_mail:
		return
	current_mail_object.sender = new_text


func _on_subject_line_edit_text_changed(new_text):
	if loading_mail:
		return
	current_mail_object.subject = new_text