extends Control


signal data_recibida


export var ruta_fila = ""


var data = [0,1,2,3,4,5,6,7,8,9]
var numero_columnas = 0
var fila


onready var tabla = get_node("VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer")


func _ready():
	fila = load(ruta_fila)
	
	crear_filas()
	rellenar_tabla()
	
	connect("data_recibida", self, "data_a_completar")


func crear_filas():
	
	#Crea tanta filas como el tamaño del array de data
	for i in range(0, data.size()):
		var nueva_fila = fila.instance()
		nueva_fila.name = str(i)
		
		tabla.add_child(nueva_fila)


func rellenar_tabla():
	
	numero_columnas = obtener_numero_columnas()
	
	for i in range(0, data.size()):
		fila = tabla.get_child(i)
		
		for j in range(0, numero_columnas):
			fila.get_node("VBoxContainer/HBoxContainer").get_child(j).text = "Prueba"
			print(data[i])


func obtener_numero_columnas():
	return get_node("VBoxContainer/PanelContainer/HBoxContainer").get_child_count()


func set_data(data_externa:Array):
	data = data_externa
	emit_signal("data_recibida")


func data_a_completar():
	crear_filas()
	rellenar_tabla()
