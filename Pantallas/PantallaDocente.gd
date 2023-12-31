extends Control

var header = [ "content-type: application/json"]
var endpointMaterias = Globals.URL + "/api/teachers/classes/" + str(Globals.userId)
var endpointAlumnos = Globals.URL + "/api/classes/"
var endpointNota = Globals.URL + "/api/notes/student/"
var endpointModificarNota = Globals.URL + "/api/notes"

var desplegado = false
var paneles = []
var listaMaterias = []
var listaAlumnos = []
var arreglo_alumnos = []
var datos_alumno = []
var arreglo_materias = []
var datos_materia = []
var alumnos_por_materia = []
var alumnos
var materia_seleccionada
var nota_Seleccionada


onready var requestMaterias = $GetMaterias
onready var requestAlumnos = $GetAlumnos
onready var request_alumnos_nota = $GetAlumnosNota
onready var request_notas = $GetNota
onready var request_modificar_notas = $ModificarNota

onready var label_nombre_materia = $PanelMateria/NombreMateria

onready var animation_player = $AnimationPlayer
onready var label_bienvenida = $PanelBienvenida/LabelBienvenida
onready var tabla_alumno = $PanelMateria/TablaAlumnos
onready var tabla_materias = $PanelHorario/TablaHorariosDocente

onready var panel_horario = $PanelHorario
onready var panel_bienvenida = $PanelBienvenida

onready var panel_nota = $PanelNota
onready var label_nota_nombre = $PanelNota/LabelNotaAlumno
onready var label_nota_materia = $PanelNota/LabelNotaMateria
onready var panel_nota_exitoso = $PanelNota/PanelEfecto/PanelExito
onready var panel_nota_fallido = $PanelNota/PanelEfecto/PanelError

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
	panel_nota.visible = false
	panel_nota_exitoso.visible = false
	panel_nota_fallido.visible = false
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	paneles = [panel_bienvenida, panel_horario, panel_seleccion_notas, panel_materia, panel_seleccion_materia, panel_nota]


func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		tabla_materias.reiniciar_tabla()
		yield(get_tree().create_timer(0.5), "timeout")
		
		for materia in json.result:
			listaMaterias.append(materia)
			
			var request = HTTPRequest.new()
			request.connect("request_completed", self, "_on_request_alumnos_completed", [materia])
			add_child(request)
			request.request('{URL}{id}/students'.format({"URL" : endpointAlumnos, "id" : materia["id"]}))
			
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

func _on_request_alumnos_completed(_result, response_code, _headers, body, params):
	var materia = params["class_name"] + params["division"]["division_name"]
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var datos_materia = {"materia": materia, "alumnos": json.result}
		alumnos_por_materia.append(datos_materia)
		print("alumnos de materia: ", materia)
		
	else:
		print("Error al obtener los alumnos de la materia", materia, ". Código de respuesta:", response_code)

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
		tabla_alumno.reiniciar_tabla()
		arreglo_alumnos = []
		yield(get_tree().create_timer(0.5), "timeout")
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
	
	label_nombre_materia.text = materia_seleccionada["class_name"]
	
	var alumnos_de_la_materia = obtener_alumnos_de_materia(materia_seleccionada["class_name"] + materia_seleccionada["division"]["division_name"])
	
	if alumnos_de_la_materia.empty():
		seleccion_materia.selected = -1
		return
	
	alumnos = alumnos_de_la_materia
	tabla_alumno.reiniciar_tabla()
	arreglo_alumnos = []
	
	yield(get_tree().create_timer(0.2), "timeout")
	for alumno in alumnos_de_la_materia:
		datos_alumno.insert(0,alumno.file_number)
		datos_alumno.insert(1,alumno.lastname)
		datos_alumno.insert(2,alumno.firstname)
		arreglo_alumnos.append(datos_alumno)
		datos_alumno = []
	tabla_alumno.set_data(arreglo_alumnos)
	
	activar_panel(panel_materia)
	
	seleccion_materia.selected = -1

func obtener_alumnos_de_materia(materia):
	for datos_materia in alumnos_por_materia:
		if datos_materia["materia"] == materia:
			return datos_materia["alumnos"]
	return []

func _on_ButtonSalir_pressed():
	
	Globals.userId = 0
	Globals.jwt = ""
	Globals.password = ""
	Globals.nombreCompleto = ""
	get_tree().change_scene("res://Pantallas/PantallaInicioDeSesion.tscn")


func _on_Button_pressed():
	
	var headers = [ "content-type: application/json" , "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmZWJlMjNhYjBiYmNlMTI2NzQ0NTgwODUxNzIzZTZlMDYyM2VmZjA5NTMwZGVjMDg2NjE4NTI2NzAzZDRkOWUyIiwic3ViIjoiYWxlam9jem9tYm9zQGdtYWlsLmNvbSIsImV4cCI6OTk5OTk5OTk5OX0.C56uSBRKnsVO9MYBlN7dfFtGvXV0JhA1gveiNIp2lXE" ]
	var URL = "https://us1.pdfgeneratorapi.com/api/v4/documents/generate"
	
	var json_data = {
		"template": {
			"id": 856150,
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
	$"Imprimir PDF".request(URL, headers, true, HTTPClient.METHOD_POST, JSON.print(json_data))


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
	var alumnos_de_la_materia = obtener_alumnos_de_materia(materia_seleccionada["class_name"] + materia_seleccionada["division"]["division_name"])
	
	for alumno in alumnos_de_la_materia:
		listaAlumnos.append(alumno)
		seleccion_alumno_nota.get_popup().add_item(alumno["firstname"] + " " + alumno["lastname"])


func _on_alumnoNota_item_selected(index):
	var alumno = listaAlumnos[index]
	
	request_notas.request('{URL}{id}'.format({"URL" : endpointNota, "id" : alumno["id"]}))
	
	label_nota_nombre.text = "Notas de " + alumno["lastname"] + ", " + alumno["firstname"]
	label_nota_materia.text = str(materia_seleccionada["class_name"] + " ("+ str(materia_seleccionada["division"]["division_name"]) + ")") 
	
	activar_panel(panel_nota)
	
	seleccion_alumno_nota.clear()
	seleccion_alumno_nota.selected = -1
	seleccion_materia_nota.clear()
	seleccion_materia_nota.selected = -1


func _on_GetNota_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		for nota in json.result:
			
			if nota["class_name"] == materia_seleccionada["class_name"]:
				nota_Seleccionada = nota
				
				$PanelNota/Nota_1.text = str(nota["numeric_note_1"])
				$PanelNota/Nota_2.text = str(nota["numeric_note_2"])
				$PanelNota/Nota_3.text = str(nota["numeric_note_3"])


func _on_ButtonIS_pressed():
	var json_data = {
		"id" : nota_Seleccionada["id"],
		"numeric_note_1" : $PanelNota/Nota_1.text,
		"numeric_note_2" : $PanelNota/Nota_2.text,
		"numeric_note_3" : $PanelNota/Nota_3.text
	}
	request_modificar_notas.request(endpointModificarNota, header, true, HTTPClient.METHOD_PUT, JSON.print(json_data))


func _on_ModificarNota_request_completed(result, response_code, headers, body):
	if response_code == 200:
		panel_nota_exitoso.visible = true
		panel_nota_fallido.visible = false
	else:
		panel_nota_exitoso.visible = false
		panel_nota_fallido.visible = true
