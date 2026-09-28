extends CharacterBody3D
## Controlador do personagem principal: movimento em terceira pessoa,
## câmera com mouse look (SpringArm3D com colisão) e integração com o
## sistema de combate (scripts/player/PlayerCombat.gd).

@export var move_speed: float = 6.0
@export var jump_velocity: float = 8.0
@export var mouse_sensitivity: float = 0.0035
@export var turn_speed: float = 12.0
@export var camera_pitch_min_degrees: float = -60.0
@export var camera_pitch_max_degrees: float = 20.0
## Se o personagem aparecer de costas/de lado em relação a pra onde anda,
## ajuste aqui (normalmente 0 ou 180) em vez de mexer no cálculo abaixo.
@export var model_facing_offset_degrees: float = 0.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

@onready var camera_pivot: Node3D = $CameraPivot as Node3D
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D as SpringArm3D
@onready var model: Node3D = $Model as Node3D
@onready var health: Health = $Health as Health
@onready var combat: PlayerCombat = $Combat as PlayerCombat


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health.died.connect(_on_died)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		camera_pivot.rotate_y(-motion.relative.x * mouse_sensitivity)
		var new_pitch := spring_arm.rotation.x - motion.relative.y * mouse_sensitivity
		spring_arm.rotation.x = clamp(
			new_pitch,
			deg_to_rad(camera_pitch_min_degrees),
			deg_to_rad(camera_pitch_max_degrees)
		)

	if event.is_action_pressed("toggle_mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("attack"):
		combat.try_attack()

	if event.is_action_pressed("power_1"):
		combat.try_power()


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= gravity * delta


func _handle_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump") and combat.can_move():
		velocity.y = jump_velocity


func _handle_movement(delta: float) -> void:
	if not combat.can_move():
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 3.0)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 3.0)
		return

	var input_dir := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)
	if input_dir.length() > 1.0:
		input_dir = input_dir.normalized()

	var forward := camera_pivot.global_transform.basis.z
	var right := camera_pivot.global_transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var move_dir := right * input_dir.x + forward * input_dir.y

	if move_dir.length() > 0.01:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		var target_angle := atan2(move_dir.x, move_dir.z) + deg_to_rad(model_facing_offset_degrees)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)


func _on_died() -> void:
	# Prototipo: sem tela de game over ainda, só reposiciona e restaura vida
	# pra continuar testando o combate sem precisar reiniciar o jogo.
	print("Player morreu — reiniciando posição de teste.")
	global_position = Vector3.ZERO
	velocity = Vector3.ZERO
	health.reset()
