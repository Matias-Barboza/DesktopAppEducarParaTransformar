extends Control


var division = 1
var desplegado = false
var paneles = []
var headers = ["Content-Type: application/json"]
var endpoint = Globals.URL + "/api/teachers/classes/" + str(Globals.userId)
var endpointAlumnos = Globals.URL + "/api/divisions/students/" + str(division)
var listaMaterias = {}
var listaDivisiones = {}
var arreglo_alumnos = []
var datos_alumno = []
var arreglo_materias = []
var datos_materia = []
var students


onready var request = $HTTPRequest
onready var requestAlumnos = $GetAlumnos
onready var animation_player = $AnimationPlayer
onready var panel_horario = $PanelHorario
onready var panel_bienvenida = $PanelBienvenida
onready var panel_notas = $PanelNotas
onready var panel_materias = $PanelMaterias
onready var menu_materias = $PanelMaterias/Panel/OptionButton
onready var panel_materias_especificas = $PanelMateriaEspecifica
onready var label_nombre_materias = $PanelMateriaEspecifica/NombreMateria
onready var label_bienvenida = $PanelBienvenida/LabelBienvenida
onready var tabla_alumno = $PanelMateriaEspecifica/TablaAlumnos
onready var tabla_materias = $PanelHorario/TablaHorariosDocente


func _ready():
	
	request.request(endpoint)
	
	panel_bienvenida.visible = true
	panel_horario.visible = false
	panel_notas.visible = false
	panel_materias.visible = false
	panel_materias_especificas.visible = false
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	paneles = [panel_bienvenida, panel_horario, panel_notas, panel_materias, panel_materias_especificas]


func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		var i = 0
		var json = JSON.parse(body.get_string_from_utf8())
		for materia in json.result:
			listaMaterias[i] = materia["class_name"] + " ("+ materia.division.division_name + ")"
			listaDivisiones[i] = materia.division.id
			menu_materias.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")", i)
			i += 1
			datos_materia.insert(0, materia["class_name"])
			datos_materia.insert(1, materia.division.division_name)
			datos_materia.insert(2, materia.classroom.room_type)
			datos_materia.insert(3, "Horario XD")
			arreglo_materias.append(datos_materia)
			datos_materia = []
		tabla_materias.set_data(arreglo_materias)
	else:
		print("Error en el primer request")


func _on_GetAlumnos_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		students = json
		for alumno in json.result:
			datos_alumno.insert(0,alumno.file_number)
			datos_alumno.insert(1,alumno.lastname)
			datos_alumno.insert(2,alumno.firstname)
			arreglo_alumnos.append(datos_alumno)
			datos_alumno = []
		tabla_alumno.set_data(arreglo_alumnos)
		
		print("Mostrando alumnos de la division " + str(division))
	else:
		print("Error en la request alumnos")



func _on_ButtonMenuDesplegable_pressed():
	
	if not desplegado:
		animation_player.play("despliegue_menu_lateral")
	else:
		animation_player.play("repliegue_menu_lateral")
	desplegado = not desplegado


func activar_panel(panel_a_visibilizar):
	
	for panel in paneles:
		if panel != panel_a_visibilizar:
			panel.visible = false
		else:
			panel.visible = true
	animation_player.play("repliegue_menu_lateral")
	desplegado = not desplegado


func _on_ButtonHorarios_pressed():
	
	activar_panel(panel_horario)


func _on_ButtonNotas_pressed():
	
	activar_panel(panel_notas)


func _on_ButtonMaterias_pressed():
	
	activar_panel(panel_materias)


func _on_OptionButton_item_selected(index):
	
	label_nombre_materias.text = listaMaterias[index]
	division = listaDivisiones[index]
	requestAlumnos.request(endpointAlumnos)
	activar_panel(panel_materias_especificas)
	menu_materias.selected = -1


func _on_ButtonSalir_pressed():
	
	Globals.userId = 0
	Globals.jwt = ""
	Globals.password = ""
	Globals.nombreCompleto = ""
	get_tree().change_scene("res://Pantallas/PantallaInicioDeSesion.tscn")


func _on_Button_pressed():
	
	var header = [ "content-type: application/json" , "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhMThiZWVhMjdmZDgxMzA5ZWFhZTA5NGFkMmU1NjQyOTU4NmMwNzBmMGY5MDdmYzM1ZTI0NWI3NjEwYTY4ODgzIiwic3ViIjoiYWxlam9vY3p0d2l0Y2hAZ21haWwuY29tIiwiZXhwIjo5OTk5OTk5OTk5fQ._-fbaWRNvua_SmCWQ48U2apGTdc_2_PW-Nga9IG1qxQ" ]
	var URL = "https://us1.pdfgeneratorapi.com/api/v4/documents/generate"
	
	var json_data = {
		"template": {
			"id": 808188,
			"data": {
				"students": students.result
			}
		},
		"format": "pdf",
		"output": "url",
		"name": "Listado Alumnos"
	}
	print(JSON.print(json_data))
	$"Imprimir PDF".request(URL, header, true, HTTPClient.METHOD_POST, JSON.print(json_data))


func _on_Imprimir_PDF_request_completed(_result, response_code, _headers, body):
	
	if response_code == 201:
		var json = JSON.parse(body.get_string_from_utf8())
		OS.shell_open(json.result.response)
	else:
		print("Error en la solicitud. Código de respuesta:", response_code)
