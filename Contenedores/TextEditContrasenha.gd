extends TextEdit


func _on_text_changed():
	
	if Input.is_action_just_pressed("abc123") or Input.is_action_pressed("abc123") or Input.is_action_just_released("abc123"):
		var texto_con_asteriscos
		Globals.password += text.substr(text.length() - 1, text.length())
		
		texto_con_asteriscos = cambiar_texto_por_asteriscos(get_text())
		set_text(texto_con_asteriscos)
		cursor_set_column(texto_con_asteriscos.length() + 1)


func cambiar_texto_por_asteriscos(texto):
	
	var nuevo_texto = ""
	
	for caracter in texto:
		nuevo_texto += "*"
	
	return nuevo_texto
