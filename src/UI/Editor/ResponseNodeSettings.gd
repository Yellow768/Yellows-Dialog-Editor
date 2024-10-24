extends TabContainer

@export var ResponseTitle : LineEdit
@export var ResponseText : Control
@export var ResponseColor : ColorPickerButton
@export var Commands : VBoxContainer
@export var AddCommandButton : Button
@export var ResponseType : OptionButton
@export var OptionCommand : Control
@export var DialogIDSpinbox : SpinBox

@export var CommandVisibilityButton: Button

var current_response : response_node
var command_text_instance = load("res://src/UI/Dialog Settings/Command.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	ResponseTitle.text = "test"

func load_response_settings(response: response_node):
	if current_response:
		current_response.disconnect("title_changed",Callable(self,"update_title"))
		current_response.disconnect("color_changed",Callable(self,"update_color"))
		current_response.disconnect("type_changed",Callable(self,"update_type"))
		current_response.disconnect("to_id_changed",Callable(self,"update_id"))
		current_response.disconnect("option_command_changed",Callable(self,"update_option_command"))
	current_response = response
	
	current_response.connect("title_changed",Callable(self,"update_title"))
	current_response.connect("color_changed",Callable(self,"update_color"))
	current_response.connect("type_changed",Callable(self,"update_type"))
	current_response.connect("to_id_changed",Callable(self,"update_id"))
	current_response.connect("option_command_changed",Callable(self,"update_option_command"))
	ResponseTitle.text = response.response_title
	ResponseColor.color = GlobalDeclarations.int_to_color(response.color_decimal)
	ResponseType.selected = response.option_type
	OptionCommand.text = response.option_command
	OptionCommand.visible = (response.option_type == 2)
	DialogIDSpinbox.value = response.to_dialog_id
	DialogIDSpinbox.visible = (response.option_type == 0)
	for child in Commands.get_children():
		Commands.remove_child(child)
		child.queue_free()
	for command in response.commands:
		var new_command = add_and_connect_command_component()
		new_command.text = command
	visible = true
	
		


func add_and_connect_command_component():
	var new_command_component = command_text_instance.instantiate()
	new_command_component.connect("text_changed",Callable(self,"command_text_changed"))
	new_command_component.connect("command_request_deletion",Callable(self,"delete_command"))
	Commands.add_child(new_command_component)
	return new_command_component
	
func delete_command(command):
	var slot = Commands.get_children().find(command)
	current_response.commands.remove_at(slot)
	Commands.remove_child(command)
	command.queue_free()


func _on_add_command_button_pressed():
	current_response.commands.append("")
	add_and_connect_command_component()


func _on_command_visibility_button_toggled(button_pressed):
	Commands.visible = button_pressed
	AddCommandButton.visible = button_pressed
	if button_pressed:
		CommandVisibilityButton.icon = load("res://Assets/UI Textures/Icon Font/chevron-down-line.svg")
	else:
		CommandVisibilityButton.icon = load("res://Assets/UI Textures/Icon Font/chevron-up-line.svg")
			





func _on_dialog_editor_no_response_selected():
	visible = false


func _on_response_title_text_changed(new_text):
	current_response.set_response_title(new_text)
	current_response.response_title = new_text

func update_title():
	ResponseTitle.text = current_response.response_title


func _on_color_picker_button_color_changed(color):
	var colorHex = "0x"+String(color.to_html(false))
	current_response.color_decimal = colorHex.hex_to_int()
	current_response.update_color(color)
	#ResponseTitle.add_theme_color_override("font_color",color)
	#ResponseText.add_theme_color_override("font_color",color)

func update_color(color):
	ResponseColor.color = color


func _on_option_type_button_item_selected(index):
	current_response.set_option_from_index(index)
	
func update_type():
	ResponseType.select(current_response.option_type)
	OptionCommand.visible = (current_response.option_type == 2)
	DialogIDSpinbox.visible = (current_response.option_type == 0)


func _on_spin_box_value_changed(value):
	current_response.attempt_to_connect_to_dialog_from_id(value)
	current_response.update_to_id_spinbox(value)
	
func update_id():
	DialogIDSpinbox.set_value_no_signal(current_response.to_dialog_id)
	
func update_option_command():
	OptionCommand.text = current_response.option_command


func _on_option_command_text_changed():
	current_response.set_command(OptionCommand.text)
	
	


func _on_response_text_text_changed():
	current_response.response_text = ResponseText.text

func command_text_changed(command_component):
	var slot = Commands.get_children().find(command_component)
	current_response.commands[slot] = command_component.text
