extends Control


var desplegado = false
var paneles = []
var datos_materia = []
var arreglo_materias = []
var datos_horario = []
var arreglo_horarios = []
var endpoint_notas = Globals.URL + "/api/notes/student/" + str(Globals.userId)


onready var panel_bienvenida = $PanelBienvenida
onready var panel_horarios = $PanelHorarios
onready var panel_notas = $PanelNotas
onready var tabla_horarios = $PanelHorarios/TablaHorarios
onready var tabla_notas = $PanelNotas/TablaNotasBoletin
onready var animation_player = $AnimationPlayer
onready var label_bienvenida = $PanelBienvenida/LabelBienvenida
onready var http_request = $HTTPRequestNotas
#onready var http_request_horarios = $HTTPRequestHorarios


func _ready():
	
	http_request.request(endpoint_notas)
	#http_request_horarios.request()
	
	
	panel_bienvenida.visible = true
	panel_horarios.visible = false
	panel_notas.visible = false
	
	paneles = [panel_bienvenida, panel_horarios, panel_notas]
	
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	for panel in paneles:
		panel.connect("replegar_panel", self, "replegar_panel")


func _on_ButtonMenuDesplegable_pressed():
	
	if not desplegado:
		animation_player.play("despliegue_menu_lateral")
	else:
		animation_player.play("repliegue_menu_lateral")
	
	desplegado = not desplegado


func _on_ButtonHorarios_pressed():
	
	activar_panel(panel_horarios)


func _on_ButtonNotas_pressed():
	
	activar_panel(panel_notas)


func activar_panel(panel_a_visibilizar):
	
	for panel in paneles:
		if panel != panel_a_visibilizar:
			panel.visible = false
		else:
			panel.visible = true
	
	animation_player.play("repliegue_menu_lateral")
	
	desplegado = not desplegado


func replegar_panel():
	
	if desplegado:
		animation_player.play("repliegue_menu_lateral")
		desplegado = not desplegado


func _on_HTTPRequestNotas_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		for nota in json.result:
			datos_materia.insert(0, nota["class_name"])
			datos_materia.insert(1, nota.numeric_note)
			datos_materia.insert(2, "1")
			datos_materia.insert(3, "1")
			datos_materia.insert(4, "1")
			arreglo_materias.append(datos_materia)
			datos_materia= []
		
		tabla_notas.set_data(arreglo_materias)
	else:
		print("error")


#func _on_HTTPRequestHorarios_request_completed(result, response_code, headers, body):
#	
#	if response_code == 200:
#		var json = JSON.parse(body.get_string_from_utf8())
#		for horario in json.result:
#
#
#		tabla_horarios.set_data(arreglo_horarios)
#	else:
#		print("error")


func _on_ButtonSalir_pressed():
	
	Globals.userId = 0
	Globals.jwt = ""
	Globals.password = ""
	Globals.nombreCompleto = ""
	get_tree().change_scene("res://Pantallas/PantallaInicioDeSesion.tscn")
