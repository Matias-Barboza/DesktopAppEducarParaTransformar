extends Control

var division = 1
var desplegado = false
var paneles = []
var headers = ["Content-Type: application/json"]
var endpoint = Globals.URL + "/api/teachers/classes/" + str(Globals.userId)
var endpointAlumnos = Globals.URL + "/api/divisions/" + str(division) + "/students"
var listaMaterias = {}
var listaDivisiones = {}



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

func _ready():
	request.request(endpoint)
	panel_bienvenida.visible = true
	panel_horario.visible = false
	panel_notas.visible = false
	panel_materias.visible = false
	panel_materias_especificas.visible = false
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	paneles = [panel_bienvenida, panel_horario, panel_notas, panel_materias, panel_materias_especificas]
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var i = 0
		var json = JSON.parse(body.get_string_from_utf8())
		for materia in json.result:
			listaMaterias[i] = materia["class_name"] + " ("+ materia.division.division_name + ")"
			listaDivisiones[i] = materia.division.id
			menu_materias.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")", i)
			i += 1
	else:
		print(body)


func _on_GetAlumnos_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		print("Mostrando alumnos de la division " + str(division))
	else:
		print("error")



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


