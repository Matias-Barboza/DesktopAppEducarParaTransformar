extends Control

onready var request = $HTTPRequest
onready var conjuntoAlumnos = $Alumnos

export var alum: PackedScene


var alumnos = 0
var listaAlumnos = {}
var headers = ["Content-Type: application/json"]
var URL = "https://educar-para-transformar.onrender.com/api/students"

func _ready():
	request.request(URL)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var i = 0
		var json = JSON.parse(body.get_string_from_utf8())
		print("todo ok pa")
		print(json.result)
		for alumno in json.result:
			listaAlumnos[i] = alumno.file_number
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
		print(i)
		i += 1
		
func darValores():
	var i = 0
	while i < alumnos:
		var hijo = conjuntoAlumnos.get_child(i)
		hijo.get_node("LabelLegajo").text = listaAlumnos[i]
		i += 1
