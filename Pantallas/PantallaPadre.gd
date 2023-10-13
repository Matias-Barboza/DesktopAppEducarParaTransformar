extends Control

var paneles = []
var desplegado = false

onready var animation_player = $AnimationPlayer
onready var panel_horario = $PanelHorario
onready var panel_bienvenida = $PanelBienvenida
onready var panel_notas = $PanelNotas
onready var panel_cuotas = $PanelCuotas
onready var label_bienvenida = $PanelBienvenida/LabelBienvenida


func _ready():
	panel_bienvenida.visible = true
	panel_horario.visible = false
	panel_notas.visible = false
	panel_cuotas.visible = false
	label_bienvenida.text = "Bienvenido " + Globals.nombreCompleto
	
	paneles = [panel_bienvenida, panel_horario, panel_notas, panel_cuotas]


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


func _on_ButtonCuotas_pressed():
	activar_panel(panel_cuotas)


func _on_ButtonSalir_pressed():
	Globals.userId = 0
	Globals.jwt = ""
	Globals.password = ""
	Globals.nombreCompleto = ""
	get_tree().change_scene("res://Pantallas/PantallaInicioDeSesion.tscn")
