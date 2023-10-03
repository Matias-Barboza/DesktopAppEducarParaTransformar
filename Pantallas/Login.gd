extends Control

var URL = "http://localhost:8080/auth/login"
onready var request = $LoginRequest
var headers = ["Content-Type: application/json"]


func _on_LoginRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		decodeJWT(json.result.token)
		print("iniciaste sesion capo")
	else:
		print("error")

func _on_ButtonIS_pressed():
	loginRequest()

func loginRequest() -> void:
	var body := {
		"username" : $PanelInicioDeSesion/VBoxContainerDatos/TextEditCE.text,
		"password" : $PanelInicioDeSesion/VBoxContainerDatos/TextEditContrasenha.text
		}
	request.request(URL, headers, true, HTTPClient.METHOD_POST, to_json(body))

func decodeJWT(jwt : String) -> void:
	#Se decodifica vaya a saber uno como y
	var jwt_decoder: JWTDecoder = JWT.decode(jwt)
	var decodedPayload = JWTUtils.base64URL_decode(jwt_decoder.get_payload())
	var playload = JSON.parse(decodedPayload.get_string_from_utf8()).result
	
	#Asigno el userId, username y el JWT en las variables globales
	Globals.jwt = jwt
	Globals.userId = playload.jti
	Globals.username = playload.sub
