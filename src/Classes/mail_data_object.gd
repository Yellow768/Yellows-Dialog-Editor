extends Node
class_name mail_data_object

signal sender_changed
signal subject_changed
signal message_changed
signal quest_changed
signal items_changed

var mail_item = {
	"id" : "minecraft:grass",
	"count" : 1,
	"tag" : "",
	"ForgeCaps": ""
}


var pages : Array[String]= []
var items_slots = ["","","",""]
var quest_id = -1
var subject = ""
var sender = ""

func _ready():
	pass
	

func compose_items_string():
	var string := ""
	for item in items_slots:
		if item != "":
			if string != "":
				string += ",\n{\n"+item+"\n}"
			else:
				string += "\n{\n"+item+"\n}"
	return string
			
func compose_pages_string():
	var string = ""
	if !pages.is_empty():
		string += '"pages":['
		for page_index in pages.size():
			string += "\n"+pages[page_index]
			if page_index != pages.size():
				string += "\n,"
		string += "\n]"
	return string
			
	
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
