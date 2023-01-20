extends Node
class_name mail_data_object

signal sender_changed
signal subject_changed
signal message_changed
signal quest_changed
signal items_changed


var pages = []
var mail_items = []
var quest_id = -1
var subject = ""
var sender = ""

func _ready():
	pass
	

func add_item(item_name : String):
	if mail_items.size() < 4:
		mail_items.append()

	
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
