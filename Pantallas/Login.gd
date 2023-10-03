extends Control

var URL = "https://educar-para-transformar.onrender.com/auth/login"
var headers = ["Content-Type: application/json"]


onready var request = $LoginRequest
onready var correo = $PanelInicioDeSesion/VBoxContainerDatos/TextEditCE


func _on_LoginRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		decodeJWT(json.result.token)
		print("iniciaste sesion capo")
	else:
		print("error")


func _on_ButtonIS_pressed():
	if(mail_valido(correo.text)):
		loginRequest()
	else:
		print("Flaco, tas equivocado")


func loginRequest() -> void:
	var body := {
		"username" : correo.text,
		"password" : Globals.password
		}
	request.request(URL, headers, true, HTTPClient.METHOD_POST, to_json(body))
	Globals.password = ""


func decodeJWT(jwt : String) -> void:
	#Se decodifica vaya a saber uno como y
	var jwt_decoder: JWTDecoder = JWT.decode(jwt)
	var decodedPayload = JWTUtils.base64URL_decode(jwt_decoder.get_payload())
	var playload = JSON.parse(decodedPayload.get_string_from_utf8()).result
	
	#Asigno el userId, username y el JWT en las variables globales
	Globals.jwt = jwt
	Globals.userId = playload.jti
	Globals.username = playload.sub


func mail_valido(correo):
	var expresion_regular = "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$"
	var regex = RegEx.new()
	
	regex.compile(expresion_regular)
	
	return regex.search(correo, 0, correo.length() - 1) != null
