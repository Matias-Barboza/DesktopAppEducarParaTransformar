extends Control


signal rellenar_tabla


export var texto_tabla : PackedScene


var desplegado = false
var paneles = []
#PRUEBA!!!
var alumnos = 0
var headers = ["Content-Type: application/json"]
var URL = "https://educar-para-transformar.onrender.com/api/students"
var listaLegajoAlumnos = {}
var listaNombreAlumnos = {}
var listaApellidoAlumnos = {}


onready var panel_bienvenida = $PanelBienvenida
onready var panel_horarios = $PanelHorarios
onready var panel_notas = $PanelNotas
onready var panel_asistencia = $PanelAsistencia
onready var animation_player = $AnimationPlayer


onready var request = $HTTPRequest
onready var vbox_materias = $PanelHorarios/PanelTabla/ScrollContainer/HBoxContainer/VBoxContainerMateria
onready var vbox_horarios = $PanelHorarios/PanelTabla/ScrollContainer/HBoxContainer/VBoxContainerHorario
onready var vbox_aula_asig = $PanelHorarios/PanelTabla/ScrollContainer/HBoxContainer/VBoxContainerAulaAsignada


func _ready():
	connect("rellenar_tabla", self, "rellenar_tabla")
	request.request(URL)
	
	panel_bienvenida.visible = true
	panel_horarios.visible = false
	panel_notas.visible = false
	panel_asistencia.visible = false
	
	paneles = [panel_bienvenida, panel_horarios, panel_notas, panel_asistencia]
	
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



func _on_ButtonAsistencia_pressed():
	activar_panel(panel_asistencia)


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
			listaLegajoAlumnos[i] = alumno.file_number
			listaNombreAlumnos[i] = alumno.firstname
			listaApellidoAlumnos[i] = alumno.lastname
			alumnos += 1
			i+= 1
		
		emit_signal("rellenar_tabla")
	else:
		print("error")

func rellenar_tabla():
	var i = 0
	
	for legajo in listaLegajoAlumnos:
		vbox_materias.add_child(texto_tabla.instance())
		vbox_horarios.add_child(texto_tabla.instance())
		vbox_aula_asig.add_child(texto_tabla.instance())
	
	for legajo in listaLegajoAlumnos:
		vbox_materias.add_child(texto_tabla.instance())
		vbox_horarios.add_child(texto_tabla.instance())
		vbox_aula_asig.add_child(texto_tabla.instance())
	
	for legajo in listaLegajoAlumnos:
		var hijo = vbox_materias.get_child(i)
		var hijo2 = vbox_horarios.get_child(i)
		var hijo3 = vbox_aula_asig.get_child(i)
		hijo.get_node("LabelTabla").text = "%s" %listaLegajoAlumnos[i]
		hijo2.get_node("LabelTabla").text = "%s" %listaNombreAlumnos[i]
		hijo3.get_node("LabelTabla").text = "%s" %listaApellidoAlumnos[i]
		i += 1
