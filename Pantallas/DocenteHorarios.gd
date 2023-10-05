extends Control

onready var animation_player = $AnimationPlayer
onready var panel_horario = $PanelHorario
onready var panel_bienvenida = $PanelBienvenida
onready var panel_notas = $PanelNotas
onready var panel_materias = $PanelMaterias
onready var menu_materias = $PanelMaterias/Panel/MenuButton

var desplegado = false
var paneles = []

func _ready():
	panel_bienvenida.visible = true
	panel_horario.visible = false
	panel_notas.visible = false
	
	paneles = [panel_bienvenida, panel_horario, panel_notas, panel_materias]


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

