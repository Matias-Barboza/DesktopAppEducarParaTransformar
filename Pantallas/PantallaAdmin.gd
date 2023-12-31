extends Control

var endpoint_division = Globals.URL + "/api/divisions"
var endpoint_alumnos_division = Globals.URL + "/api/divisions/students/"

var endpoint_division_0 = Globals.URL + "/api/students/classes/30"
var endpoint_division_1 = Globals.URL + "/api/students/classes/45"
var endpoint_division_2 = Globals.URL + "/api/students/classes/65"
var endpoint_division_3 = Globals.URL + "/api/students/classes/68"
var endpoint_cuotas_impagas = Globals.URL + "/api/fees/students"

onready var request_divisiones = $GetDivisiones
onready var request_alumnos = $GetAlumnosDivision
onready var request_horarios = $GetHorariosDivision


onready var tabla_alumno = $PanelDivision/TablaAlumnos
onready var tabla_horario = $PanelHorario/TablaHorariosDocente

onready var animation_player = $AnimationPlayer
onready var panel_bienvenida = $PanelBienvenida/LabelBienvenida

onready var label_bienvenida = $PanelBienvenida/LabelBienvenida
onready var label_division = $PanelDivision/NombreDivision
onready var label_horario = $PanelHorario/NombreDivision

onready var panel_division = $PanelDivision
onready var panel_seleccion_division = $PanelSeleccionDivision
onready var menu_seleccion_division = $PanelSeleccionDivision/Panel/OptionButton

onready var panel_horario = $PanelHorario
onready var panel_seleccion_horario = $PanelSeleccionHorario
onready var menu_seleccion_horario = $PanelSeleccionHorario/Panel/OptionButton

onready var request_cuotas_impagas = $HTTPRequestCuotasImpagas
onready var panel_cuotas = $PanelCuotas
onready var panel_seleccion_cuotas = $PanelSeleccionCuotasImpagas
onready var tabla_cuotas_impagas = $PanelCuotas/TablaCuotasImpagas
onready var menu_seleccion_cuotas = $PanelSeleccionCuotasImpagas/Panel/OptionButton

var paneles = []
var listaDivisiones = []
var division_seleccionada
var alumnos
var desplegado = false

func _ready():
	request_divisiones.request(endpoint_division)
	request_cuotas_impagas.request(endpoint_cuotas_impagas)
	
	panel_bienvenida.visible = true
	panel_division.visible = false
	panel_seleccion_division.visible = false
	panel_horario.visible = false
	panel_seleccion_horario.visible = false
	panel_cuotas.visible = false
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	paneles = [panel_bienvenida, panel_division, panel_seleccion_division, panel_horario, panel_seleccion_horario, panel_cuotas]


func activar_panel(panel_a_visibilizar):
	for panel in paneles:
		if panel != panel_a_visibilizar:
			panel.visible = false
		else:
			panel.visible = true
	animation_player.play("repliegue_menu_lateral")
	desplegado = not desplegado


func _on_ButtonHorarios_pressed():
	activar_panel(panel_seleccion_horario)

func _on_ButtonAlumnos_pressed():
	activar_panel(panel_seleccion_division)

func _on_ButtonCuotasImpagas_pressed():
	activar_panel(panel_cuotas)

func _on_ButtonSalir_pressed():
	Globals.userId = 0
	Globals.jwt = ""
	Globals.password = ""
	Globals.nombreCompleto = ""
	get_tree().change_scene("res://Pantallas/PantallaInicioDeSesion.tscn")


func _on_GetDivisiones_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		for division in json.result:
			listaDivisiones.append(division)
			menu_seleccion_division.get_popup().add_item(division["division_name"] + " " + educacion(division["education"]))
			menu_seleccion_horario.get_popup().add_item(division["division_name"] + " " + educacion(division["education"]))

func educacion(division):
	if division == "Primary":
		return "Primaria"
	elif division == "Secondary":
		return "Secuandaria"

func _on_SeleccionHorario_item_selected(index):
	var division = listaDivisiones[index]
	label_horario.text = "Division: " + division["division_name"]
	
	if index == 0:
		request_horarios.request(endpoint_division_0)
	elif index == 1:
		request_horarios.request(endpoint_division_1)
	elif index == 2:
		request_horarios.request(endpoint_division_2)
	elif index == 3:
		request_horarios.request(endpoint_division_3)
	
	activar_panel(panel_horario)


func _on_GetHorariosDivision_request_completed(_result, response_code, _headers, body):
	var arreglo_materias = []
	var datos_materia = []
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		tabla_horario.reiniciar_tabla()
		yield(get_tree().create_timer(0.5), "timeout")
		
		for materia in json.result:
			
			for horario in materia.schedules:
				
				datos_materia.insert(0, materia["class_name"])
				datos_materia.insert(1, materia["division"]["division_name"])
				datos_materia.insert(2, materia["classroom"]["room_type"])
				datos_materia.insert(3, convertir_dia_a_espanol(horario["day"]))
				datos_materia.insert(4, horario["startingTime"] + " - " + horario["endTime"])
				arreglo_materias.append(datos_materia)
				datos_materia = []
			
		tabla_horario.set_data(arreglo_materias)

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


func _on_SeleccionDivision_item_selected(index):
	division_seleccionada = listaDivisiones[index]
	label_division.text = "Division: " + division_seleccionada["division_name"]
	request_alumnos.request('{url}{id}'.format({"url" : endpoint_alumnos_division, "id" : division_seleccionada["id"]}))
	activar_panel(panel_division)

func _on_GetAlumnosDivision_request_completed(_result, response_code, _headers, body):
	var arreglo_alumnos = []
	var datos_alumno = []
	
	if response_code == 200:
		
		var json = JSON.parse(body.get_string_from_utf8())
		alumnos = json
		
		tabla_alumno.reiniciar_tabla()
		yield(get_tree().create_timer(0.5), "timeout")
		
		for alumno in json.result:
			datos_alumno.insert(0,alumno.file_number)
			datos_alumno.insert(1,alumno.lastname)
			datos_alumno.insert(2,alumno.firstname)
			arreglo_alumnos.append(datos_alumno)
			datos_alumno = []
		tabla_alumno.set_data(arreglo_alumnos)
	else:
		print("Error al obtener los alumnos")


func _on_imprimirPDF_pressed():
		
	var headers = [ "content-type: application/json" , "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhMThiZWVhMjdmZDgxMzA5ZWFhZTA5NGFkMmU1NjQyOTU4NmMwNzBmMGY5MDdmYzM1ZTI0NWI3NjEwYTY4ODgzIiwic3ViIjoiYWxlam9vY3p0d2l0Y2hAZ21haWwuY29tIiwiZXhwIjo5OTk5OTk5OTk5fQ._-fbaWRNvua_SmCWQ48U2apGTdc_2_PW-Nga9IG1qxQ" ]
	var URL = "https://us1.pdfgeneratorapi.com/api/v4/documents/generate"
	
	var json_data = {
		"template": {
			"id": 819280,
			"data": {
				"division": division_seleccionada["division_name"],
				"cant": alumnos.result.size(),
				"date": Time.get_date_string_from_system(),
				"students": alumnos.result
			}
		},
		"format": "pdf",
		"output": "url",
		"name": "Listado Alumnos"
	}
	$ImprimirPDF.request(URL, headers, true, HTTPClient.METHOD_POST, JSON.print(json_data))


func _on_ImprimirPDF_request_completed(_result, response_code, _headers, body):
	if response_code == 201:
		var json = JSON.parse(body.get_string_from_utf8())
		OS.shell_open(json.result.response)
	else:
		print("Error al generar el PDF")


func _on_ButtonMenuDesplegable_pressed():
	if not desplegado:
		animation_player.play("despliegue_menu_lateral")
	else:
		animation_player.play("repliegue_menu_lateral")
	desplegado = not desplegado


func _on_HTTPRequestCuotasImpagas_request_completed(result, response_code, headers, body):
	var datos_alumno = []
	var arreglo_alumnos = []
	
	
	if response_code == 200:
		
		var json = JSON.parse(body.get_string_from_utf8())

		tabla_cuotas_impagas.reiniciar_tabla()
		yield(get_tree().create_timer(0.5), "timeout")

		for alumno in json.result:
			datos_alumno.insert(0, alumno.file_number)
			datos_alumno.insert(1, alumno.lastname)
			datos_alumno.insert(2, alumno.firstname)
			for mes in alumno.unpaidMonthlyFees:
				datos_alumno.insert(3, convertir_mes_a_espanol(mes["month"]))
			arreglo_alumnos.append(datos_alumno)
			datos_alumno = []
		
		tabla_cuotas_impagas.set_data(arreglo_alumnos)
	else:
		print("Error al obtener las cuotas impagas")


func convertir_mes_a_espanol(mes_en_ingles: String) -> String:
	var meses = {
		"JANUARY": "Enero",
		"FEBRUARY": "Febrero",
		"MARCH": "Marzo",
		"APRIL": "Abril",
		"MAY": "Mayo",
		"JUNE": "Junio",
		"JULY": "Julio",
		"AUGUST": "Agosto",
		"SEPTEMBER": "Septiembre",
		"OCTOBER": "Octubre"
	}
	
	if meses.has(mes_en_ingles):
		return meses[mes_en_ingles]
	else:
		return "Día no válido"
