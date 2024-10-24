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
	
	current_response = response
	
	current_response.connect("title_changed",Callable(self,"update_title"))
	
	ResponseTitle.text = response.response_title
	ResponseColor.color = GlobalDeclarations.int_to_color(response.color_decimal)
	ResponseType.selected = response.option_type
	OptionCommand.text = response.option_command
	OptionCommand.visible = (response.option_type == 2)
	DialogIDSpinbox.value = response.to_dialog_id
	DialogIDSpinbox.visible = (response.option_type == 0)
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
