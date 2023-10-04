extends Control


var desplegado = false
var paneles = []

onready var panel_bienvenida = $PanelBienvenida
onready var panel_horarios = $PanelHorarios
onready var panel_notas = $PanelNotas
onready var panel_asistencia = $PanelAsistencia
onready var animation_player = $AnimationPlayer


func _ready():
	panel_bienvenida.visible = true
	panel_horarios.visible = false
	panel_notas.visible = false
	panel_asistencia.visible = false
	
	paneles = [panel_bienvenida, panel_horarios, panel_notas, panel_asistencia]


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
