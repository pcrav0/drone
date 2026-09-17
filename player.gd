extends CharacterBody3D

const VELOCIDADE_HORIZONTAL = 500.0
const VELOCIDADE_VOO = 20.0
const VELOCIDADE_VOO_MAX = 30.0
const MOUSE_SENSIBILIDADE = 0.01

var camera_i := 0
@onready var camera_offets := [Vector3(0, 0.6, -0.3), $Cabeca/Camera3D.position]

var aceleracao_das_asas := 0.0
const ACELERACAO_DAS_ASAS_BASE := 0.1

func _enter_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _leave_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _read():
	set_process_input(true)

func _input(event: InputEvent):
	if not event is InputEventMouse:
		return
	rotate_y(-event.relative.x * MOUSE_SENSIBILIDADE)
	$Cabeca.rotate_x(-event.relative.y * MOUSE_SENSIBILIDADE)
	$Cabeca.rotation.x = clamp($Cabeca.rotation.x, -PI / 2, PI / 2)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("camera"):
		$Cabeca/Camera3D.position = camera_offets[camera_i]
		camera_i += 1
		camera_i %= camera_offets.size()

func _physics_process(delta: float) -> void:
	if position.y <= -10: # caiu mto, volta pro comeco
		position = Vector3.ZERO
		position.y = 2
		velocity = Vector3.ZERO

	var input_dir := Input.get_vector("esquerda", "direita", "frente", "tras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * VELOCIDADE_HORIZONTAL * delta
		velocity.z = direction.z * VELOCIDADE_HORIZONTAL * delta
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE_HORIZONTAL) * delta
		velocity.z = move_toward(velocity.z, 0, VELOCIDADE_HORIZONTAL) * delta
	
	if Input.is_action_pressed("cima"):
		velocity.y += VELOCIDADE_VOO * delta
	elif Input.is_action_pressed("baixo"):
		velocity.y -= VELOCIDADE_VOO * delta

	velocity.y += get_gravity().y * delta
	velocity.y = clamp(velocity.y, -VELOCIDADE_VOO_MAX, VELOCIDADE_VOO_MAX)

	for i in range($Asa.get_children().size()):
		var it := $Asa.get_child(i)
		var n : int = -1 if i % 2 == 0 else 1
		it.rotate_y(n*delta*aceleracao_das_asas + n*ACELERACAO_DAS_ASAS_BASE)
		aceleracao_das_asas += max(velocity.y, 0.0) * 0.05
		aceleracao_das_asas -= 0.1
		aceleracao_das_asas = clamp(aceleracao_das_asas, 0.0, 30)

	move_and_slide()
