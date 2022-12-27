Yellow's CustomNPC's Dialog Editor
===================================
Yellow's CustomNPC's Dialog Editor is a node based, dialog tree editor aiming to make creating branching dialog trees for the Minecraft mod CustomNPCS faster and easier.

Why?
============

The in game editor and other external editors have been lackluster and have been hindering my performance. The in-game editor has submenu after submenu, no way to
visualise the connections between dialogs, and most frustrating of all is no way to create and connect two dialogs in one fell swoop.

Instead, you must make the dialog you want first, then go back into the starting dialog, open the response options, edit response option 1, select dialog, and then find it in the list

There have only been two external editors (that I could find). The first is the official one released by Noppes, which is just the in-game editor but now as it's own program. It
suffers from the same issues as above.

The only other one had terrible UX and UI, felt clunky and horrible to use.

Additionally, both external editors lacked the functionality of seeing and selecting quests and factions by name, instead relying on the user to know the faction and quest ID.
Connections between dialogs was also handled by IDs.

Other dialog editors, unrelated to CustomNPCs, are not designed for this mod's specific architecture. There's lots of features that don't apply, and no way to natively export
it into the Minecraft world, meaning that in the end, you still need to deal with the in-game editors interface.

So what does this do?
========

This editor aims to make everything about making dialogs convienent and intuitve. Features and settings are readily accesible, but out of sight when not needed. Clicking has
been way reduced.

There are two types of nodes, a Dialog Node, which has a text box for both the title and the actual text itself right on it. As soon as a dialog is created, we can start writing.

The other node is a Response Node. Response Nodes are tethered to the Dialog Node, and are created by clicking the plus button, or by hitting "Ctrl-R" while selecting a node.

Response nodes may connect to one dialog node, either by dragging the connection line to an existing dialog, or by clicking the plus button to automatically create a new dialog
with a defined title.


I also automatically load in quest and faction data, and keep in memory a list of all dialogs, that way they can be referenced by name. The editor can also natively export dialogs directly to the world, all that is required from there is a simple run of the command "/noppes dialog reload"

The editor can also import in existing dialogs, both from the minecraft world, and on their own, and will automatically create the correct IDs for it.
