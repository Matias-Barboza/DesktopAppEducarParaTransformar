extends Control

var endpointMaterias = Globals.URL + "/api/teachers/classes/" + str(Globals.userId)
var endpointAlumnos = Globals.URL + "/api/divisions/students/"

var desplegado = false
var paneles = []
var listaMaterias = []
var listaAlumnos = []
var arreglo_alumnos = []
var datos_alumno = []
var arreglo_materias = []
var datos_materia = []
var alumnos
var materia_seleccionada


onready var requestMaterias = $GetMaterias
onready var requestAlumnos = $GetAlumnos
onready var request_alumnos_nota = $GetAlumnosNota


onready var animation_player = $AnimationPlayer
onready var label_bienvenida = $PanelBienvenida/LabelBienvenida
onready var tabla_alumno = $PanelMateria/TablaAlumnos
onready var tabla_materias = $PanelHorario/TablaHorariosDocente

onready var panel_horario = $PanelHorario
onready var panel_bienvenida = $PanelBienvenida

onready var panel_nota = $PanelNota
onready var panel_seleccion_notas = $PanelSeleccionNota
onready var seleccion_materia_nota = $PanelSeleccionNota/OptionButtonMaterias
onready var seleccion_alumno_nota = $PanelSeleccionNota/OptionButtonAlumnos

onready var panel_materia = $PanelMateria
onready var panel_seleccion_materia = $PanelSeleccionMaterias
onready var seleccion_materia = $PanelSeleccionMaterias/Panel/OptionButton

onready var label_nombre_materias = $PanelMateria/NombreMateria


func _ready():
	
	requestMaterias.request(endpointMaterias)
	
	panel_bienvenida.visible = true
	panel_horario.visible = false
	panel_seleccion_notas.visible = false
	panel_materia.visible = false
	panel_seleccion_materia.visible = false
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	paneles = [panel_bienvenida, panel_horario, panel_seleccion_notas, panel_materia, panel_seleccion_materia, panel_nota]


func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		for materia in json.result:
			listaMaterias.append(materia)
			
			seleccion_materia.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
			seleccion_materia_nota.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
			
			for horario in materia.schedules:
				
				datos_materia.insert(0, materia["class_name"])
				datos_materia.insert(1, materia["division"]["division_name"])
				datos_materia.insert(2, materia["classroom"]["room_type"])
				datos_materia.insert(3, convertir_dia_a_espanol(horario["day"]))
				datos_materia.insert(4, horario["startingTime"] + " - " + horario["endTime"])
				arreglo_materias.append(datos_materia)
				datos_materia = []
			
		tabla_materias.set_data(arreglo_materias)
	else:
		print("Error al obtener los horarios")

func convertir_dia_a_espanol(dia_en_ingles: String) -> String:
	var dias = {
		"MONDAY": "Lunes",
		"TUESDAY": "Martes",
		"WEDNESDAY": "Miércoles",
		"THURSDAY": "Jueves",
		"FRIDAY": "Viernes",
		"SATURDAY": "Sábado",
		"SUNDAY": "Domingo"
	}
	
	if dias.has(dia_en_ingles):
		return dias[dia_en_ingles]
	else:
		return "Día no válido"

func _on_GetAlumnos_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		alumnos = json
		for alumno in json.result:
			datos_alumno.insert(0,alumno.file_number)
			datos_alumno.insert(1,alumno.lastname)
			datos_alumno.insert(2,alumno.firstname)
			arreglo_alumnos.append(datos_alumno)
			datos_alumno = []
		tabla_alumno.set_data(arreglo_alumnos)
		
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
	activar_panel(panel_seleccion_notas)

func _on_ButtonMaterias_pressed():
	activar_panel(panel_seleccion_materia)

func _on_OptionButton_item_selected(index):
	materia_seleccionada = listaMaterias[index]
	
	requestAlumnos.request('{URL}{id}'.format({"URL" : endpointAlumnos, "id" : materia_seleccionada["division"]["id"]}))
	activar_panel(panel_materia)
	
	seleccion_materia.selected = -1


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
				"class_name": materia_seleccionada["class_name"],
				"teacher": Globals.nombreCompleto,
				"cant": alumnos.result.size(),
				"division": materia_seleccionada["division"]["division_name"],
				"date": Time.get_date_string_from_system(),
				"students": alumnos.result
			}
		},
		"format": "pdf",
		"output": "url",
		"name": "Listado Alumnos"
	}
	$"Imprimir PDF".request(URL, header, true, HTTPClient.METHOD_POST, JSON.print(json_data))


func _on_Imprimir_PDF_request_completed(_result, response_code, _headers, body):
	
	if response_code == 201:
		var json = JSON.parse(body.get_string_from_utf8())
		OS.shell_open(json.result.response)
	else:
		print("Error en la solicitud. Código de respuesta:", response_code)


func _on_OptionButtonMaterias_item_selected(index):
	seleccion_alumno_nota.clear()
	
	seleccion_alumno_nota.disabled = false
	seleccion_alumno_nota.text = "Seleccione un Alumno"
	
	materia_seleccionada = listaMaterias[index]
	
	request_alumnos_nota.request('{URL}{id}'.format({"URL" : endpointAlumnos, "id" : materia_seleccionada["division"]["id"]}))


func _on_GetAlumnosNota_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		for alumno in json.result:
			listaAlumnos.append(alumno)
			seleccion_alumno_nota.get_popup().add_item(alumno["firstname"] + " " + alumno["lastname"])


func _on_alumnoNota_item_selected(index):
	var alumno = listaAlumnos[index]
	
