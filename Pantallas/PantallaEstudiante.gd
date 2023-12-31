extends Control


var desplegado = false
var paneles = []
var datos_materia = []
var arreglo_materias = []
var datos_horario = []
var arreglo_horarios = []

var endpoint_notas = Globals.URL + "/api/notes/student/" + str(Globals.userId)
var endpoint_horario = Globals.URL + "/api/students/classes/" + str(Globals.userId)


onready var panel_bienvenida = $PanelBienvenida
onready var panel_horarios = $PanelHorarios
onready var panel_notas = $PanelNotas
onready var tabla_horarios = $PanelHorarios/TablaHorarios
onready var tabla_notas = $PanelNotas/TablaNotasBoletin
onready var animation_player = $AnimationPlayer
onready var label_bienvenida = $PanelBienvenida/LabelBienvenida
onready var http_request = $HTTPRequestNotas
onready var http_request_horarios = $HTTPRequestHorarios


func _ready():
	
	http_request.request(endpoint_notas)
	http_request_horarios.request(endpoint_horario)
	
	
	panel_bienvenida.visible = true
	panel_horarios.visible = false
	panel_notas.visible = false
	
	paneles = [panel_bienvenida, panel_horarios, panel_notas]
	
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
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


func _on_HTTPRequestNotas_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		for nota in json.result:
			datos_materia.insert(0, nota["class_name"])
			datos_materia.insert(1, asignarNota(nota.numeric_note_1))
			datos_materia.insert(2, asignarNota(nota.numeric_note_2))
			datos_materia.insert(3, asignarNota(nota.numeric_note_3))
			datos_materia.insert(4, asignarNota((nota.numeric_note_1 + nota.numeric_note_2 + nota.numeric_note_3) / 3))
			arreglo_materias.append(datos_materia)
			datos_materia= []
		
		tabla_notas.set_data(arreglo_materias)
	else:
		print("error")

func asignarNota(nota):
	if nota == 0:
		return ""
	return nota


func _on_HTTPRequestHorarios_request_completed(result, response_code, headers, body):
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		for materia in json.result:
			for horario in materia.schedules:
				datos_horario.insert(0, materia["class_name"])
				datos_horario.insert(1, materia["classroom"]["room_type"])
				datos_horario.insert(2, convertir_dia_a_espanol(horario["day"]))
				datos_horario.insert(3, horario["startingTime"] + " - " + horario["endTime"])
				arreglo_horarios.append(datos_horario)
				datos_horario = []
		
		arreglo_horarios.sort_custom(DayOfWeekSorter, "sort_by_day_of_week")
		tabla_horarios.set_data(arreglo_horarios)
	else:
		print("Error en al carga de horarios")


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

func _on_ButtonSalir_pressed():
	
	Globals.userId = 0
	Globals.jwt = ""
	Globals.password = ""
	Globals.nombreCompleto = ""
	get_tree().change_scene("res://Pantallas/PantallaInicioDeSesion.tscn")


#ESTO ES PARA ORDENAR LOS HORARIOS POR DIA

class DayOfWeekSorter:
	static func sort_by_day_of_week(a, b):
		var dias_de_semana = {
			"Lunes": 1,
			"Martes": 2,
			"Miércoles": 3,
			"Jueves": 4,
			"Viernes": 5,
			"Sábado": 6,
			"Domingo": 7
		}
		
		var day_a = dias_de_semana[a[2]]
		var day_b = dias_de_semana[b[2]]
		
		if day_a < day_b:
			return true
		elif day_a > day_b:
			return false
		else:
			# Si los días son iguales, compara las horas
			var time_a = a[3]
			var time_b = b[3]
			return time_a < time_b
