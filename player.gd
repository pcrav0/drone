extends CharacterBody3D

const VELOCIDADE_HORIZONTAL = 5.0
const VELOCIDADE_VOO = 1

func _physics_process(delta: float) -> void:
	if position.y <= -10: # caiu mto, volta pro comeco
		position = Vector3.ZERO
		position.y = 2
		velocity = Vector3.ZERO
	
	if not is_on_floor():
		velocity += get_gravity() * delta * VELOCIDADE_VOO

	var input_dir := Input.get_vector("esquerda", "direita", "frente", "tras")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * VELOCIDADE_HORIZONTAL
		velocity.z = direction.z * VELOCIDADE_HORIZONTAL
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDADE_HORIZONTAL)
		velocity.z = move_toward(velocity.z, 0, VELOCIDADE_HORIZONTAL)
		
	if Input.is_action_pressed("cima"):
		velocity.y += VELOCIDADE_VOO
	elif Input.is_action_pressed("baixo"):
		velocity.y -= VELOCIDADE_VOO

	move_and_slide()
