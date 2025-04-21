extends PanelContainer


@export var overall_task_label_path : NodePath
@export var progress_bar_path : NodePath
@export var current_item_label_path : NodePath

@onready var OverallTaskLabel : Label = get_node(overall_task_label_path)
@onready var Progress : ProgressBar = get_node(progress_bar_path)
@onready var CurrentItemLabel : Label = get_node(current_item_label_path)




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_overall_task_name(text):
	if not is_inside_tree(): await self.ready
	OverallTaskLabel.text = text
	
func set_current_item_text(text):
	if not is_inside_tree(): await self.ready
	CurrentItemLabel.text = text
	
func set_progress(progress):
	if not is_inside_tree(): await self.ready
	Progress.value = progress

func set_max_progress(max_progress):
	if not is_inside_tree(): await self.ready
	Progress.max_value = max_progress
