extends CharacterBody3D
class_name Enemy
## Inimigo comum: fica parado até notar o jogador (DetectionArea),
## persegue e ataca corpo a corpo (AttackArea) quando perto, e depois
## de morrer, reaparece após alguns segundos — bom pra testar combate
## repetidamente numa área pequena enquanto o mundo maior não existe.

enum State { IDLE, CHASE, ATTACK }

@export var move_speed: float = 3.2
@export var attack_damage: float = 8.0
@export var attack_cooldown: float = 1.2
@export var attack_range: float = 1.6
@export var respawn_time: float = 4.0
## Se o personagem aparecer de costas/de lado em relação a pra onde anda,
## ajuste aqui (normalmente 0 ou 180) em vez de mexer no cálculo abaixo.
@export var model_facing_offset_degrees: float = 0.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var state: State = State.IDLE

var _player: Node3D = null
var _attack_timer: float = 0.0
var _spawn_position: Vector3

@onready var model: Node3D = $Model as Node3D
@onready var health: Health = $Health as Health
@onready var detection_area: Area3D = $DetectionArea as Area3D
@onready var attack_area: Area3D = $Model/AttackArea as Area3D
@onready var animation: EnemyAnimation = $Animation as EnemyAnimation


func _ready() -> void:
	add_to_group("enemies")
	_spawn_position = global_position
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = -0.1
	else:
		velocity.y -= gravity * delta

	if _attack_timer > 0.0:
		_attack_timer -= delta

	match state:
		State.CHASE:
			_process_chase(delta)
		State.ATTACK, State.IDLE:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()


func _process_chase(delta: float) -> void:
	if _player == null:
		state = State.IDLE
		return

	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	var distance := to_player.length()

	if distance < attack_range:
		state = State.ATTACK
		_start_attack()
		return

	var dir := to_player.normalized()
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	var target_angle := atan2(dir.x, dir.z) + deg_to_rad(model_facing_offset_degrees)
	model.rotation.y = lerp_angle(model.rotation.y, target_angle, 10.0 * delta)


func _start_attack() -> void:
	if _attack_timer > 0.0:
		return
	_attack_timer = attack_cooldown
	animation.play_attack()
	for body in attack_area.get_overlapping_bodies():
		_apply_attack_damage(body)
	await get_tree().create_timer(0.3).timeout
	if state == State.ATTACK:
		state = State.CHASE


func _apply_attack_damage(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var target_health := body.get_node_or_null("Health") as Health
	if target_health:
		target_health.take_damage(attack_damage)


func _on_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player = body
		state = State.CHASE


func _on_detection_body_exited(body: Node3D) -> void:
	if body == _player:
		_player = null
		state = State.IDLE
		velocity.x = 0.0
		velocity.z = 0.0


func _on_died() -> void:
	set_physics_process(false)
	visible = false
	collision_layer = 0
	collision_mask = 0
	state = State.IDLE
	_player = null
	await get_tree().create_timer(respawn_time).timeout
	global_position = _spawn_position
	health.reset()
	animation.reset()
	visible = true
	collision_layer = 4
	collision_mask = 1
	set_physics_process(true)
