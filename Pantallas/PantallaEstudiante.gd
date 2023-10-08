extends Control


signal rellenar_tabla


var desplegado = false
var paneles = []
#PRUEBA!!!
var headers = ["Content-Type: application/json"]
var URL = "https://educar-para-transformar.onrender.com/api/students"
var datos_alumno = []


onready var panel_bienvenida = $PanelBienvenida
onready var panel_horarios = $PanelHorarios
onready var panel_notas = $PanelNotas
onready var tabla_horarios = $PanelHorarios/TablaHorarios
onready var animation_player = $AnimationPlayer

onready var request = $HTTPRequest


func _ready():
	request.request(URL)
	
	panel_bienvenida.visible = true
	panel_horarios.visible = false
	panel_notas.visible = false
	
	paneles = [panel_bienvenida, panel_horarios, panel_notas]
	
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


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var i = 0
		var json = JSON.parse(body.get_string_from_utf8())
		print("todo ok pa")
		for alumno in json.result:
			datos_alumno.insert(0, alumno.file_number)
			datos_alumno.insert(1, alumno.firstname)
			datos_alumno.insert(2, alumno.lastname)
	else:
		print("error")
