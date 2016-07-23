
export var gaf_file_path = 'res://path_to.gaf'
export var _gr_nodes_file_path = 'res://adventure_parser/gr_nodes/gr_nodes.cfg'
var gaf_file = {}
var _gr_nodes_file = {}

var _save_file = {}
var _save_slot = '0' #TODO: implement save slot system
var _current_exe = '' #this is how saving/loading will work (along with _init_script)
var _init_script = '' #Contains the init script (from manager)
var init_object = {} #Contains _init_script script on an object

onready var public_node = get_tree().get_root().get_node('parser/game_content')
onready var view_shield = get_tree().get_root().get_node('parser/view_shield')

func _ready():
	_load_files()
	_preload_resources()
	_execute_init()
	_cycle_content()

func _load_files():
	var file = File.new()

	file.open(gaf_file_path, file.READ)
	gaf_file.parse_json(file.get_as_text())
	file.close()

	file.open(_gr_nodes_file_path, file.READ)
	_gr_nodes_file.parse_json(file.get_as_text())
	file.close()

	if file.file_exists('user://'+_save_slot+'.sav'):
		file.open('user://'+_save_slot+'.sav', file.READ)
		_save_file.parse_json(file.get_as_text())
		_init_script = _save_file["init"]
		_current_exe = _save_file["current_exe"]
		file.close()
	else:
		_init_script = gaf_file["init"]
		_current_exe = 'Start'

func _preload_resources():
	#character scenes
	for char in gaf_file["characters"]:
		gaf_file["characters"][char] = load(gaf_file["characters"][char])
	#dialogue scene
	gaf_file['options']['dialogue_scene'] = load(gaf_file['options']['dialogue_scene'])
	#TODO: scenes
	#TODO: media

func _execute_init():
	var script = GDScript.new()
	script.set_source_code(_init_script)
	script.reload()
	init_object = Node.new()
	init_object.set_script(script)

func _cycle_content():
	var conn_arr = gaf_file["connections"]
	var cont_dict = gaf_file["content"]
	var prev_node_name = ''
	var keep_cycling = true
	
	#Find _current_exe
	for conn in conn_arr:
		if conn['from'] == _current_exe:
			_current_exe = conn['to']
			break
	
	while keep_cycling:
		var curr_name = cont_dict[_current_exe]['ref_name']
		var node_scene = load(_gr_nodes_file[curr_name])
		node_scene = node_scene.instance()
		get_node('gr_nodes_parent').add_child(node_scene)
		
		node_scene.action(cont_dict[_current_exe], gaf_file, init_object, public_node, view_shield)
		yield(node_scene, 'GR_NODE_DONE')
		var implied_from_port = node_scene.get_implied_from_port()
		
		keep_cycling = false
		node_scene.queue_free()
		
		
		for conn in conn_arr:
			if conn['from'] == _current_exe:
				if conn['from_port'] == implied_from_port:
					_current_exe = conn['to']
					keep_cycling = true
					break
		
		#Option: Async
		var next_name = cont_dict[_current_exe]['ref_name']
		if !((next_name == "Choice") || (next_name == "Media")) && gaf_file['options']['async']:
			for child in public_node.get_children():
					child.queue_free()
		
		_save_files() #every new node

func _save_files():
	#Saving _current_exe, & the script on init_object into the _save_slot
	var file = File.new()
	file.open('user://'+_save_slot+'.sav', file.WRITE)
	_save_file = {}
	_save_file["current_exe"] = _current_exe
	_save_file["init"] = init_object.get_script().get_source_code()
	file.store_string(_save_file.to_json())
	file.close()
