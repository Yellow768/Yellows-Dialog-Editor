extends Node
class_name mail_data_object

signal sender_changed
signal subject_changed
signal message_changed
signal quest_changed
signal items_changed

var pages = []
var items_slots = [{},{},{},{}]
var quest_id = -1
var subject = ""
var sender = ""

func _ready():
	pass
	

func create_slot_string(item : Dictionary,slot_index) -> String:
	var slot_nbt_string : String
	if item.custom_nbt != "":
		slot_nbt_string = '		"Slot": '+str(slot_index)+'b,\n				'+item.custom_nbt
	else:
		slot_nbt_string = '		"Slot": '+str(slot_index)+'b, 
				"ForgeCaps": {
					"customnpcs:itemscripteddata": {
 					}
				},
				"id": "'+item.id+'",
				"Count": '+str(item.count)+"b"
	return slot_nbt_string
		

func compose_items_string():
	var string := ""
	for item in items_slots.size():
		if items_slots[item] != {}:
			var item_as_string := create_slot_string(items_slots[item],item)
			if string != "":
				string += ",\n			{\n		"+item_as_string+"\n			}"
			else:
				string += "			{\n		"+item_as_string+"\n			}"
	return string.replace("\\'","'")
			
func compose_pages_string(new_version : bool = false):
	var string = ""
	if !pages.is_empty() && !new_version:
		string += '			"pages": ['
		for page_index in pages.size():
			var page_text : String = pages[page_index].c_escape().replace("\\n","\n").replace("\\'","'")
			string += '\n				"'+page_text+'"'
			if page_index != pages.size()-1 && pages.size() != 1:
				string += ","
		string += "\n			]"
	elif !pages.is_empty() && new_version:
		for page in pages:
			string+=page.c_escape().replace("\\n","\n").replace("\\'","'")+"\n"
	return string #.c_unescape().replace("\\'","'")
	
			
	
#"DialogMail": {
#        "Sender": "Bobaa",
#        "BeenRead": 0b,
#        "Message": {
#            "pages": [
#                "aaaaa
#bbb
#ccc
#\"ad\"\\/...
#11111111111111111111111111111111111111222222222222222222222222222222222222221234567891234567891abcdefghijklmnopqrstuvwxyz",
#                ""
#            ]
#        },
#        "MailItems": [
#            {
#                "Slot": 0b,
#                "ForgeCaps": {
#                    "customnpcs:itemscripteddata": {
#                    }
#                },
#                "id": "minecraft:gravel",
#                "Count": 1b
#            },
#            {
#                "Slot": 1b,
#                "ForgeCaps": {
#                    "customnpcs:itemscripteddata": {
#                    }
#                },
#                "id": "minecraft:gravel",
#                "Count": 3b
#            },
#            {
#                "Slot": 2b,
#                "ForgeCaps": {
#                    "customnpcs:itemscripteddata": {
#                    }
#                },
#                "id": "minecraft:gravel",
#                "Count": 1b
#            }
#        ],
#        "MailQuest": -1,
#        "TimePast": 236875L,
#        "Time": 1673243269932L,
#        "Subject": "Testaa"
#    }
