#data= {"position":"value","ref_name":"node name type",...}
extends GraphNode

const ref_name = 'Dialogue'
signal GR_NODE_DONE
var implied_port = 0

onready var dialogue_editor = get_node('WindowDialog')
onready var speech_path = get_node('speech_path')

var _public_node = {}
var _gaf_file = {}
var _dialogue_scene = {}
var _char_scene = {}

func _ready():
	connect('close_request', self, '_close')
func _close():
	self.queue_free()

func set_data(data):
	dialogue_editor.get_node("TextEdit").set_text(data["dialogue_text"])
	speech_path.set_text(data["speech_path"])

func get_data():
	var data = {}
	data["ref_name"] = ref_name
	data["dialogue_text"] = dialogue_editor.get_node("TextEdit").get_text()
	data["speech_path"] = speech_path.get_text()
	return data

func get_implied_from_port():
	return implied_port

func _on_btn_edit_dialogue_pressed():
	dialogue_editor.popup()

func action(data, gaf_file, init_object, public_node, view_shield):
	_public_node = public_node
	_gaf_file = gaf_file

	var dialogue_dict = {}
	data["dialogue_text"] = data["dialogue_text"].replace("'", '"')
	dialogue_dict.parse_json('{"content":[' + data["dialogue_text"] + ']}')
	var dialogue_arr = dialogue_dict["content"]
	dialogue_arr  = _replace_vars(dialogue_arr, init_object)

	for dict in dialogue_arr: #dict= {"name":"text to say"}
		for sentence in dict: #sentence= "name"
			var char_scene = gaf_file['characters'][sentence]
			#characters
			_display_char(char_scene)
			#display
			_display_text(sentence, dict[sentence])
			#TODO: speech

			#clear
			##########################################################################
			var optn_max_chars = _gaf_file['options']['max_chars_at_once'] #TODO!!!!!!
			var optn_timeout = _gaf_file['options']['timeout']

			view_shield.set_hidden(false)

			if optn_timeout == 0:
				#wait for click on view_shield
				yield(view_shield, 'pressed')
				view_shield.set_hidden(true)
			else:
				#wait for timeout ms
				var timer = Timer.new()
				timer.set_wait_time(optn_timeout / 1000)
				timer.set_one_shot(true)
				timer.start()
				yield(timer, 'timeout')

			#Dialogues are the only nodes not manually clearing to allow async
			#	_char_scene.queue_free()
			#	_dialogue_scene.queue_free()
			##########################################################################
	emit_signal('GR_NODE_DONE')

func _replace_vars(arr, init_object): #replace '$_var' with 'varible value'
	var _arr = arr
	for dict in _arr: #dict= {"name":"text to say"}
		for sentence in dict: #sentence= "name"
			while true:
				var var_start_idx = dict[sentence].find('$_')

				if var_start_idx != -1:
					var var_end_idx = dict[sentence].find('$', var_start_idx + 2)
					var var_length = (var_end_idx - var_start_idx) - 2
					var var_name = dict[sentence].substr(var_start_idx + 2, var_length)
					var var_value = init_object.get(var_name)
					dict[sentence] = dict[sentence].replace('$_' + var_name + '$', var_value)
				else:
					break
	return _arr

func _display_char(char_scene):
	_char_scene = char_scene.instance()
	_public_node.add_child(_char_scene)

func _display_text(name, text):
	var optn_typewriter = _gaf_file['options']['typewriter'] #TODO !!!!
	var optn_text_scene = _gaf_file['options']['dialogue_scene']

	_dialogue_scene = optn_text_scene.instance()
	_dialogue_scene.get_node('dialogue_text').set_bbcode(text)
	_dialogue_scene.get_node('dialogue_name').set_bbcode(name)
	_public_node.add_child(_dialogue_scene)
