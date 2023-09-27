Yellow's CustomNPC's Dialog Editor
===================================
Yellow's CustomNPC's Dialog Editor is a node based, dialog tree editor aiming to make creating branching dialog trees for the Minecraft mod CustomNPCS faster and easier.

Why?
============

The in game editor and other external editors are cumbersome and have been hindering my performance. The in-game editor has submenu after submenu, no way to visualise the connections between dialogs, and most frustrating of all is no way to create and connect two dialogs in one fell swoop.

Instead, you must make the dialog you want first, then go back into the starting dialog, open the response options, edit response option 1, select dialog, and then find it in the list

I haven't been able to find a suitable external editor, the official one from Noppes replicates the same interface, and the only other one I've found was cumbersome in it's own way.

Additionally, external editors lacked the functionality of seeing and selecting quests and factions by name, instead relying on the user to know the faction and quest ID.
Connections between dialogs was also handled by IDs.

Other dialog editors, unrelated to CustomNPCs, are not designed for this mod's specific architecture. There's lots of features that don't apply, and no way to natively export
it into the Minecraft world, meaning that in the end, you still need to deal with the in-game editors interface.

So what does this do?
========

This editor aims to make making dialogs convienent and intuitve. Features and settings are readily accesible, but out of sight when not needed. There are far less submenus to navigate through.

There are two types of nodes, a Dialog Node, which has a text box for both the title and the actual text itself right on it. As soon as a dialog is created, we can start writing.

The other node is a Response Node. Response Nodes are tethered to the Dialog Node, and are created by clicking the plus button, or by hitting "Ctrl-R" while selecting a node.

Response nodes may connect to one dialog node, either by dragging the connection line to an existing dialog, or by clicking the plus button to automatically create a new dialog with a defined title.


I also automatically load in quest and faction data, and keep in memory a list of all dialogs, that way they can be referenced by name. The editor can also natively export dialogs directly to the world, all that is required from there is a simple run of the command "/noppes dialog reload"

The editor can also import in existing dialogs, both from the minecraft world, and on their own, and will automatically create the correct IDs for it.

Technical Documentation
==========

When a directory is selected, the program will do a couple of things.

A) It scans through all the folders in customnpcs/dialogs, indexing them as categories.
B) Searches for a highest_index.json to define the current highest ID number. If it can't be found, it will index all numerical.jsons and set the highest one as the highest ID
C) The settings panel indexes the quest categories, and retrieves the title and ID from the json files, and passes it to the choose quest buttons
D) Extracts the bytes from the faction.dat file, manually searching for the correct identifiers to grab faction names and IDs.


In the Main scene, the Category Panel retrieves the category index from the EnvironmentIndexer, and creates a list of buttons corresponding to each category. When a category is selected, it emits a signal to the GraphEdit node "Dialog Editor" requesting to load a category. The  DialogEditor is responsible for creating, selecting, connecting, and deleting graph nodes.

The Dialog Editor creates a new category_loader object, that searches for a YDEC file in the selected directory. If one is found, it parses the json and recreates all the nodes and connects them together.

If none is found, a signal is sent to the Dialog Editor to create a category_importer object.  It creates an array of all the dialog data from the jsons in the directory, and prompts the user to select a dialog to begin the tree. Once selected, the category_importer creates a dialog node, gives it all the data from the json, and creates all the response nodes from the Options{} part of the JSON. It then searches for the json indicated by the response's to_dialog ID number, and creates a dialog node from that json, repeating the process, and removing it from the array of jsons.

Once the tree is followed all the way through, it chooses the first available dialog in the array, and repeats the process until all jsons are loaded.

Dialog and Response nodes contain all the data held about that specific dialog and response. Dialogs have arrays of availability objects, custom classes which contain properties such as Quest ID, Before/After, things like that.

When a dialog node is selected, a reference to the node is passed via signal to the Settings Panel, which is responsbile for editing data regarding availability, quests, factions, and mail. The availability editors retrieve their data from the dialog node's availability objects. The quest and faction selectors retrieve their list from the faction_indexer and quest_indexer objects. When something is changed on the settings panel, it assigns that new value to the dialog node.

When the category is exported, a category_exporter object is created, which gathers all the nodes in the "Save" group. Going through each one, it creates a JSON file named the dialog_id, and correctly writes the CNPC dialog json format with the necessary information from the dialog node. Dialog Nodes hold an array of references to each of it's responses, and so the data for the options is gathered from that.


