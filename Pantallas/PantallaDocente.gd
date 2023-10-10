extends Control


onready var request = $HTTPRequest
onready var conjuntoAlumnos = $PanelDatos/Alumnos
onready var labelMateria = $Panel/LabelNombreMateria


export var alum: PackedScene

var alumnos = 0
var listaLegajoAlumnos = {}
var listaNombreAlumnos = {}
var listaApellidoAlumnos = {}
var listaNotaAlumnos = {}
var endpoint = Globals.URL + "/api/students"

var students


func _ready():
	request.request(endpoint)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		
		labelMateria.text = Globals.materiaSeleccionada
		var json = JSON.parse(body.get_string_from_utf8())
		students = json
		
		var i = 0
		for alumno in json.result:
			listaLegajoAlumnos[i] = alumno.file_number
			listaNombreAlumnos[i] = alumno.firstname
			listaApellidoAlumnos[i] = alumno.lastname
			#listaNotaAlumnos[i] = alumno.id
			alumnos += 1
			i+= 1
		
		instanciarAlumnos()
		espaciarAlumnos()
		darValores()
	else:
		print("error")


func instanciarAlumnos():
	var x = alumnos
	while x > 0:
		conjuntoAlumnos.add_child(alum.instance())
		x -= 1


func espaciarAlumnos():
	var posicionInicial = Vector2.ZERO
	var i = 1
	while i < alumnos:
		var hijo = conjuntoAlumnos.get_child(i)
		posicionInicial = conjuntoAlumnos.get_child(i-1).get_position()
		hijo.rect_position.y = posicionInicial.y + 35 
		i += 1


func darValores():
	var i = 0
	while i < alumnos:
		var hijo = conjuntoAlumnos.get_child(i)
		hijo.get_node("LabelLegajo").text = listaLegajoAlumnos[i]
		hijo.get_node("LabelNombre").text = listaNombreAlumnos[i]
		hijo.get_node("LabelApellido").text = listaApellidoAlumnos[i]
		#hijo.get_node("LabelNota").text = "%s" % listaNotaAlumnos[i]
		i += 1


func _on_Imprimir_PDF_request_completed(result, response_code, headers, body):
	if response_code == 201:
		var json = JSON.parse(body.get_string_from_utf8())
		OS.shell_open(json.result.response)
	else:
		print("Error en la solicitud. Código de respuesta:", response_code)


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
