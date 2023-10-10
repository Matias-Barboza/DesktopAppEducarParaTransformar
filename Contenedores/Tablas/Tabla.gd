extends Control


signal data_recibida


export var ruta_fila = ""


var data = []
var numero_columnas = 0
var fila


onready var tabla = get_node("VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer")


func _ready():
	
	fila = load(ruta_fila)
	
	connect("data_recibida", self, "data_a_completar")


func crear_filas():
	
	#Crea tantas filas como el tamaño del array de data
	for i in range(0, data.size()):
		var nueva_fila = fila.instance()
		nueva_fila.name = str(i)
		
		tabla.add_child(nueva_fila)


func rellenar_tabla():
	
	#Obtiene numero de columnas en base a la cantidad de labels que ofician de las mismas
	numero_columnas = obtener_numero_columnas()
	
	for i in range(0, data.size()):
		fila = tabla.get_child(i)
		
		for j in range(0, numero_columnas):
			fila.get_node("VBoxContainer/HBoxContainer").get_child(j).text = str(data[i][j])


func obtener_numero_columnas():
	return get_node("VBoxContainer/PanelContainer/HBoxContainer").get_child_count()


func set_data(data_externa:Array):
	data = data_externa
	emit_signal("data_recibida")


func data_a_completar():
	crear_filas()
	rellenar_tabla()
