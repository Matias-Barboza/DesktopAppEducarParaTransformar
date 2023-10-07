extends Control


var fila = preload("res://Contenedores/Contenedor Docente/Fila.tscn")
var numero = 0
var data = [
	{"materia":"Matematicas", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Lengua", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Historia", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Sociales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Inglés", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"},
	{"materia":"Ciencias Naturales", "horario":"18:10", "aulaasignada":"1.1"}
]


onready var tabla = get_node("VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer")


func _ready():
	rellenar_tabla()

func rellenar_tabla():
	#Crear filas
	for i in range(0, data.size()):
		var nueva_fila = fila.instance()
		nueva_fila.name = str(numero)
		
		tabla.add_child(nueva_fila)
		
		get_node("VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer/"+nueva_fila.name+"/1").text = data[i].materia
		get_node("VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer/"+nueva_fila.name+"/2").text = data[i].horario
		get_node("VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer/"+nueva_fila.name+"/3").text = data[i].aulaasignada
		
		numero += 1

func set_data(data_externa:Array):
	data = data_externa
