extends Control

var desplegado = false
var paneles = []
var headers = ["Content-Type: application/json"]
var endpoint = Globals.URL + "/api/classes"
var listaMaterias = {}


export var escenaMateria : PackedScene

#Test
var ID = 68
#Test

onready var request = $HTTPRequest
onready var animation_player = $AnimationPlayer
onready var panel_horario = $PanelHorario
onready var panel_bienvenida = $PanelBienvenida
onready var panel_notas = $PanelNotas
onready var panel_materias = $PanelMaterias
onready var menu_materias = $PanelMaterias/Panel/OptionButton

func _ready():
	request.request(endpoint)
	panel_bienvenida.visible = true
	panel_horario.visible = false
	panel_notas.visible = false
	panel_materias.visible = false
	
	paneles = [panel_bienvenida, panel_horario, panel_notas, panel_materias]
	

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var i = 0
		var json = JSON.parse(body.get_string_from_utf8())
		for materia in json.result:
			if(materia.teacher.id == ID):
				listaMaterias[i] = materia["class_name"]
				menu_materias.get_popup().add_item(materia["class_name"], i)
				i += 1
		print("todo ok pa")
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
	Globals.materiaSeleccionada = listaMaterias[index]
	print(Globals.materiaSeleccionada)
	get_tree().change_scene_to(escenaMateria)
	
