#
#Store all the global variables & functions that may be reused
#This script has to in root (due to references to it)
#In other scripts, you'll use it as g.member
#
extends Control

onready var main_graph = get_node('h_split/main_graph_container/main_graph')
onready var main_managers = get_node('h_split/main_managers')
onready var path_selector = get_node('h_split/main_graph_container/path_selector')
onready var node_selector = get_node('h_split/main_graph_container/node_selector')
onready var gaf_file = {}
const gr_nodes_group = 'gr_nodes'
const gr_nodes_file_path = 'res://adventure_parser/gr_nodes/gr_nodes.cfg' #repeated in parser.gd

#SAVE/LOAD FORMAT:
#{
#"connections":
#	[
#		{from_slot: 0, from: “name”, to_slot: 0, to: “name” }
#		,...
#	]
#, 
#"content":
#	{
#		"@node name@n":{
#				"position": "value",
#				"ref_name": "shared type name"
#				"data": "variable created & parsed by said node"
#				}
#		,...
#	}
#}