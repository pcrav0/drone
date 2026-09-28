extends CharacterBody3D

const VELOCIDADE_HORIZONTAL = 500.0
const VELOCIDADE_VOO = 20.0
const VELOCIDADE_VOO_MAX = 30.0
const MOUSE_SENSIBILIDADE = 0.01
const MASSA = 0.1
const JOYSTICK_CAMERA_SENSIBILIDADE = 0.05

var camera_i := 0
@onready var camera_offets := [Vector3(0, 0.6, -0.3), $Cabeca/Camera3D.position]

var aceleracao_das_asas := 0.0
const ACELERACAO_DAS_ASAS_BASE := 0.1

var camera_move_x: float = 0
var camera_move_y: float = 0

func _enter_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _leave_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _read():
	set_process_input(true)

func _input(event: InputEvent):
	print(event)
	if event is InputEventJoypadMotion:
		match event.axis:
			2:
				camera_move_x = -event.axis_value
			3:
				camera_move_y = -event.axis_value

	match event:
		InputEventMouse:
			rotate_y(-event.relative.x * MOUSE_SENSIBILIDADE)
			$Cabeca.rotate_x(-event.relative.y * MOUSE_SENSIBILIDADE)
			$Cabeca.rotation.x = clamp($Cabeca.rotation.x, -PI / 2, PI / 2)

func _process(_delta: float) -> void:
	rotate_y(camera_move_x * JOYSTICK_CAMERA_SENSIBILIDADE)
	$Cabeca.rotate_x(camera_move_y * JOYSTICK_CAMERA_SENSIBILIDADE)
	$Cabeca.rotation.x = clamp($Cabeca.rotation.x, -PI / 2, PI / 2)

	if Input.is_action_just_pressed("camera"):
		$Cabeca/Camera3D.position = camera_offets[camera_i]
		camera_i += 1
		camera_i %= camera_offets.size()

func _physics_process(delta: float) -> void:
	var velocidade_antiga := velocity

	if position.y <= -10: # caiu mto, volta pro comeco
		position = Vector3.ZERO
		position.y = 2
		velocity = Vector3.ZERO

	var input_dir := Input.get_vector("esquerda", "direita", "frente", "tras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	direction += Vector3(0, 1, 0)
	direction *= 0.75

	if Input.is_action_pressed("cima"):
		velocity += direction * VELOCIDADE_VOO * delta
	elif Input.is_action_pressed("baixo"):
		velocity -= direction * VELOCIDADE_VOO * delta

	velocity.y += get_gravity().y * delta
	velocity.y = clamp(velocity.y, -VELOCIDADE_VOO_MAX, VELOCIDADE_VOO_MAX)

	if false:
		var delta_vel := velocity - velocidade_antiga
		var aceleracao := delta_vel / delta
		var forca := MASSA * aceleracao
		print(aceleracao, " ", forca)

	if is_on_floor() and not (Input.is_action_pressed("cima") || Input.is_action_pressed("baixo")):
		velocity = Vector3.ZERO

	for i in range($Asa.get_children().size()):
		var it := $Asa.get_child(i)
		var n : int = -1 if i % 2 == 0 else 1
		it.rotate_y(n*delta*aceleracao_das_asas + n*ACELERACAO_DAS_ASAS_BASE)
		aceleracao_das_asas += max(velocity.y, 0.0) * 0.05
		aceleracao_das_asas -= 0.1
		aceleracao_das_asas = clamp(aceleracao_das_asas, 0.0, 30)

	move_and_slide()
