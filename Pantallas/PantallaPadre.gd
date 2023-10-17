extends Control

var paneles = []
var listaHijos = []
var datos_materia = []
var arreglo_materias = []
var datos_horario = []
var arreglo_horarios = []
var desplegado = false

var endpoint_hijos = Globals.URL + "/api/parents/" + str(Globals.userId)
var endpoint_horarios = Globals.URL + "/api/students/classes/"
var endpoint_notas = Globals.URL + "/api/notes/student/"


onready var panel_bienvenida = $PanelBienvenida
onready var label_bienvenida = $PanelBienvenida/LabelBienvenida
onready var animation_player = $AnimationPlayer

onready var panel_seleccion_horario = $PanelSeleccionHorario
onready var panel_horario = $PanelHorario
onready var tabla_horarios = $PanelHorario/TablaHorarios
onready var seleccion_hijos_horarios = $PanelSeleccionHorario/Panel/OptionButton

onready var panel_seleccion_notas = $PanelSeleccionNotas
onready var panel_notas = $PanelNotas
onready var tabla_notas = $PanelNotas/TablaNotasBoletin
onready var seleccion_hijos_notas = $PanelSeleccionNotas/Panel/OptionButton

onready var panel_cuotas = $PanelCuotas

onready var request_hijos = $HTTPRequestHijos
onready var request_horarios = $HTTPRequestHorarios
onready var request_notas = $HTTPRequestNotas


func _ready():
	request_hijos.request(endpoint_hijos)
	
	panel_bienvenida.visible = true
	panel_seleccion_horario.visible = false
	panel_seleccion_horario.visible = false
	panel_seleccion_notas.visible = false
	panel_seleccion_notas.visible = false
	panel_cuotas.visible = false
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	paneles = [panel_bienvenida, panel_horario, panel_notas, panel_cuotas, panel_seleccion_horario, panel_seleccion_notas]


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
	activar_panel(panel_seleccion_horario)


func _on_ButtonNotas_pressed():
	activar_panel(panel_seleccion_notas)


func _on_ButtonCuotas_pressed():
	activar_panel(panel_cuotas)


func _on_ButtonSalir_pressed():
	Globals.userId = 0
	Globals.jwt = ""
	Globals.password = ""
	Globals.nombreCompleto = ""
	get_tree().change_scene("res://Pantallas/PantallaInicioDeSesion.tscn")


func _on_RequestHijos_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		for hijo in json.result.childrens:
			listaHijos.append(hijo)
			
			
			#Carga de los nombres de los hijos en la seleccion de hijos para notas y horarios
			seleccion_hijos_horarios.get_popup().add_item(hijo["firstname"] + " " + hijo["lastname"])
			seleccion_hijos_notas.get_popup().add_item(hijo["firstname"] + " " + hijo["lastname"])
		


func _on_horarios_item_selected(index):
	var hijo = listaHijos[index]
	
	request_horarios.request('{endpoint}{id}'.format({"endpoint" : endpoint_horarios, "id" : hijo["id"]}))
	activar_panel(panel_horario)
	seleccion_hijos_horarios.selected = -1

func _on_Horarios_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		tabla_horarios.reiniciar_tabla()
		arreglo_horarios = []
		yield(get_tree().create_timer(0.5), "timeout")
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


func _on_notas_item_selected(index):
	var hijo = listaHijos[index]
	
	request_notas.request('{endpoint}{id}'.format({"endpoint" : endpoint_notas, "id" : hijo["id"]}))
	activar_panel(panel_notas)
	seleccion_hijos_notas.selected = -1

func _on_Notas_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		tabla_notas.reiniciar_tabla()
		arreglo_materias = []
		yield(get_tree().create_timer(0.5), "timeout")
		for nota in json.result:
			datos_materia.insert(0, nota["class_name"])
			datos_materia.insert(1, nota.numeric_note_1)
			datos_materia.insert(2, nota.numeric_note_2)
			datos_materia.insert(3, nota.numeric_note_3)
			datos_materia.insert(4, (nota.numeric_note_1 + nota.numeric_note_2 + nota.numeric_note_3) / 3)
			arreglo_materias.append(datos_materia)
			datos_materia= []
		
		tabla_notas.set_data(arreglo_materias)
	else:
		print("Error en la carga de notas")

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
