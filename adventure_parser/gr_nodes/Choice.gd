
extends GraphNode

const ref_name = 'Choice'
signal GR_NODE_DONE
var implied_port = 0

var choice_text_arr = [] #see _ready()
onready var optn_timer = get_node('optn_timer')
onready var choice_text_template = preload('res://adventure_parser/gr_nodes/choice_text.scn')

var _current_choice_idx = 3 #ALSO BELOW

func _ready():
	connect('close_request', self, '_close')
func _close():
	self.queue_free()

func set_data(data):
	optn_timer.set_text(data["optn_timer"])
	choice_text_arr = data["choice_text_arr"]
	for choice_text in choice_text_arr:
		var dupe = _add_choice_node()
		dupe.set_text(choice_text)

func get_data():
	var data = {}
	data["ref_name"] = ref_name
	data["optn_timer"] = optn_timer.get_text()
	data["choice_text_arr"] = []
	for child in get_children():
		if child.is_in_group('gr_node_choice_text'):
			data["choice_text_arr"].append(child.get_text())
	return data

func get_implied_from_port():
	return implied_port

func _add_choice_node():
	var dupe = choice_text_template.instance()
	add_child(dupe)
	set_slot(_current_choice_idx, false, 0, Color(255, 255, 255), true, 0, Color(255, 255, 255))
	_current_choice_idx = _current_choice_idx + 1
	return dupe

func _remove_choice_node():
	var nodes = get_children()
	if nodes[nodes.size() - 1].is_in_group('gr_node_choice_text'):
		set_size(Vector2(get_size().x, get_size().y - nodes[nodes.size() - 1].get_size().y))
		nodes[nodes.size() - 1].queue_free()
		nodes.pop_back()

func action(data, gaf_file, init_object, public_node, view_shield):

	var choice_scene = load(gaf_file["options"]["choice_scene"])
	choice_scene = choice_scene.instance()
	public_node.add_child(choice_scene)

	var btn_arr_node = choice_scene.get_node('btn_arr')

	for choice_text in data["choice_text_arr"]: #choice= "choice text"
		btn_arr_node.add_button(choice_text)

	yield(btn_arr_node, 'button_selected')
	implied_port = btn_arr_node.get_selected() #ALSO ABOVE

	choice_scene.queue_free()
	emit_signal('GR_NODE_DONE')
