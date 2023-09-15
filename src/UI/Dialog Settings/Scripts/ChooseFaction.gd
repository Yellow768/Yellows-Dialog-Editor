extends Button

signal import_faction_popup
signal faction_chosen

var faction_data = {}

func _ready():
	pass


func _on_ChooseFaction_pressed():
	$FactionFinder.position = global_position
	$FactionFinder.popup()




	
func load_faction_data(faction_dict : Dictionary):
	faction_data = faction_dict
	$FactionFinder.clear()
	$FactionFinder.add_item("Cancel...",10000)
	$FactionFinder.add_separator("",10001)
	for key in faction_data.keys():
		$FactionFinder.add_item(key,faction_data[key])



func _on_FactionFinder_id_pressed(id):
	if(id == 10000):
		$FactionFinder.hide()
	else:
		emit_signal("faction_chosen",id)


func set_faction_name_from_id(id):
	var fact_name
	fact_name = "Unindexed Faction"
	if id == -1:
		fact_name = "Choose Faction"
	for key in faction_data.keys():
		if faction_data[key] == id:
			fact_name = key	
	tooltip_text = fact_name
	text = fact_name
