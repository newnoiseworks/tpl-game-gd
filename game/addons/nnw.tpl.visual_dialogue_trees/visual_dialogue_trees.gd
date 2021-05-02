tool
extends EditorPlugin

var MainScreen = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/MainScreen.tscn"
)

var DialogueNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/DialogueNode.tscn"
)

var ScriptNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/ScriptNode.tscn"
)

var MissionEntryNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/MissionEntryNode.tscn"
)

var MissionExitNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/MissionExitNode.tscn"
)

var MissionExitFailedNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/MissionExitFailedNode.tscn"
)

var MissionExitFinishedNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/MissionExitFinishedNode.tscn"
)

var StartMissionScriptNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/StartMissionScriptNode.tscn"
)

var FinishMissionScriptNode = ResourceLoader.load(
	"res://addons/nnw.tpl.visual_dialogue_trees/main_screen/Nodes/FinishMissionScriptNode.tscn"
)

var _main_screen_instance

var _file_dialog

var _current_resource: String = ""


func _enter_tree():
	_main_screen_instance = MainScreen.instance()
	_main_screen_instance.connect("reset_file", self, "_on_reset_file")
	get_editor_interface().get_editor_viewport().add_child(_main_screen_instance)

	_file_dialog = FileDialog.new()
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.connect("file_selected", self, "_on_file_selected")

	get_editor_interface().get_base_control().add_child(_file_dialog)

	make_visible(false)


func _exit_tree():
	if _main_screen_instance:
		_main_screen_instance.disconnect("reset_file", self, "_on_reset_file")
		_main_screen_instance.queue_free()

	if _file_dialog:
		_file_dialog.queue_free()
		_file_dialog.disconnect("file_selected", self, "_on_file_selected")


func _on_reset_file():
	_current_resource = ""
	_file_dialog.visible = true
	_file_dialog.popup_centered_ratio()


func _on_file_selected(file):
	_current_resource = file
	_main_screen_instance.node_types.Dialogue = DialogueNode
	_main_screen_instance.node_types.Script = ScriptNode
	_main_screen_instance.node_types.MissionEntry = MissionEntryNode
	_main_screen_instance.node_types.MissionExit = MissionExitNode
	_main_screen_instance.node_types.MissionExitFailed = MissionExitFailedNode
	_main_screen_instance.node_types.MissionExitFinished = MissionExitFinishedNode
	_main_screen_instance.node_types.StartMissionScript = StartMissionScriptNode
	_main_screen_instance.node_types.FinishMissionScript = FinishMissionScriptNode
	_main_screen_instance._file_loaded(file)


func has_main_screen():
	return true


func make_visible(visible):
	if _main_screen_instance:
		_main_screen_instance.visible = visible

	if visible:
		if _current_resource == "":
			_file_dialog.visible = visible
			_file_dialog.popup_centered_ratio()
		else:
			_file_dialog.visible = false


func get_plugin_name():
	return "Visual Dialogue Tree Editor"


func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
