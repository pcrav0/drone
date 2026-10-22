extends CharacterBody3D

const VELOCIDADE_HORIZONTAL = 500.0
const VELOCIDADE_VOO = 20.0
const VELOCIDADE_VOO_MAX = 30.0
const MOUSE_SENSIBILIDADE = 0.01
const MASSA = 0.1
const JOYSTICK_CAMERA_SENSIBILIDADE = 0.05
const ROTACAO_SENSIBILIDADE = 5

#var camera_i := 0
#@onready var camera_offets := [Vector3(0, 0.6, -0.3), $RemoteTransform3D.position]

var aceleracao_das_asas := 0.0
const ACELERACAO_DAS_ASAS_BASE := 0.1

var rotacao_x: float = 0
var rotacao_z: float = 0

func _enter_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _leave_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	if event is InputEventJoypadMotion:
		match event.axis: # BUG: se isso nao for colocado em uma fila pode se perder valores
			2:
				rotacao_z = -event.axis_value
			3:
				rotacao_x = -event.axis_value

	if event is InputEventMouseMotion:
		pass # print(event)

func _process(_delta: float) -> void:
	if false:
		rotate_y(rotacao_z * JOYSTICK_CAMERA_SENSIBILIDADE)
		$Cabeca.rotate_x(rotacao_x * JOYSTICK_CAMERA_SENSIBILIDADE)
		$Cabeca.rotation.x = clamp($Cabeca.rotation.x, -PI / 2, PI / 2)

	#if Input.is_action_just_pressed("camera"):
		#$Cabeca/Camera3D.position = camera_offets[camera_i]
		#camera_i += 1
		#camera_i %= camera_offets.size()

func _physics_process(delta: float) -> void:
	var velocidade_antiga := velocity

	if position.y <= -10: # caiu mto, volta pro comeco
		position = Vector3.ZERO
		position.y = 2
		velocity = Vector3.ZERO

	#var input_dir := Input.get_vector("esquerda", "direita", "frente", "tras")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	#direction *= 0.75

	if is_on_floor() and not (Input.is_action_pressed("cima") || Input.is_action_pressed("baixo")):
		velocity = Vector3.ZERO

	var c := ROTACAO_SENSIBILIDADE * delta

	if true: # controle PID
		# rotacao em z e x
		if abs(rotacao_z) > 0.1 or abs(rotacao_x) > 0.1:
			quaternion *= Quaternion(Vector3(1, 0, 0), -1 * rotacao_x * c/2)
			quaternion *= Quaternion(Vector3(0, 0, 1), rotacao_z * c/2)
		if abs(rotation.x) >= 0.1:
			quaternion *= Quaternion(Vector3(1, 0, 0), -1 * sign(rotation.x) * c/5)
		elif abs(rotacao_x) < 0.01:
			rotation.x = 0
		if abs(rotation.z) >= 0.1:
			quaternion *= Quaternion(Vector3(0, 0, 1), -1 * sign(rotation.z) * c/5)
		elif abs(rotacao_z) < 0.01:
			rotation.z = 0

		# rocatcao em y
		var y := 0
		if Input.is_action_pressed("rotacao_y_esquerda"):
			y += 1
		if Input.is_action_pressed("rotacao_y_direita"):
			y -= 1
		quaternion *= Quaternion(Vector3(0, 1, 0), 0.3 * y * c)
		
		# max / min
		var angle = PI/4
		rotation.x = clampf(rotation.x, -angle, angle)
		rotation.z = clampf(rotation.z, -angle, angle)

	var vel = Vector3.ZERO
	vel += Vector3(-rotacao_z, 0, -rotacao_x) * c

	var vel_basis = Basis.from_euler(rotation).inverse()

	var direction = Vector3(0, 1, 0)
	if Input.is_action_pressed("cima"):
		vel += direction * VELOCIDADE_VOO * delta
	elif Input.is_action_pressed("baixo"):
		vel -= direction * VELOCIDADE_VOO * delta

	vel.y += get_gravity().y * delta
	vel.y = clamp(vel.y, -VELOCIDADE_VOO_MAX, VELOCIDADE_VOO_MAX)

	velocity += vel * vel_basis

	for i in range($Asa.get_children().size()):
		var it := $Asa.get_child(i)
		var n : int = -1 if i % 2 == 0 else 1
		it.rotate_y(n*delta*aceleracao_das_asas + n*ACELERACAO_DAS_ASAS_BASE)
		aceleracao_das_asas += max(velocity.y, 0.0) * 0.05
		aceleracao_das_asas -= 0.1
		aceleracao_das_asas = clamp(aceleracao_das_asas, 0.0, 30)

	$HUD/Rotacao.text = "rotação: %.2v" % rotation
	$HUD/Posicao.text = "posição: %.2v" % position
	$HUD/Velocidade.text = "velocidade: %.2v" % velocity

	if true:
		var delta_vel := velocity - velocidade_antiga
		var aceleracao := delta_vel / delta
		var forca := MASSA * aceleracao
		$HUD/Aceleracao.text = "aceleração: %.2v" % aceleracao
		$HUD/Forca.text = "força: %.2v" % forca

	move_and_slide()
