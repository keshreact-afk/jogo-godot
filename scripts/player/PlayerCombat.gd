extends Node
class_name PlayerCombat
## Sistema de combos corpo a corpo (3 golpes) e do poder de apoio do
## jogador (investida com dano). Ativa a hitbox do personagem por uma
## janela curta a cada golpe e aplica dano em tudo que ela tocar.

signal combo_step_changed(step: int)
signal power_used
signal power_cooldown_changed(remaining: float, total: float)

const COMBO_DAMAGE: Array[float] = [10.0, 12.0, 18.0]
const COMBO_LOCK_TIME: Array[float] = [0.28, 0.3, 0.5]
const COMBO_WINDOW := 0.6      # tempo pra encadear o próximo golpe do combo
const HIT_ACTIVE_TIME := 0.18  # quanto tempo a hitbox fica ligada por golpe

const POWER_DAMAGE := 25.0
const POWER_COOLDOWN := 3.0
const POWER_LOCK_TIME := 0.35
const POWER_DASH_SPEED := 14.0
const POWER_DASH_TIME := 0.2

@onready var player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var model: Node3D = player.get_node("Model") as Node3D
@onready var hitbox: Area3D = player.get_node("Model/AttackHitbox") as Area3D

var _combo_index: int = 0
var _combo_timer: float = 0.0
var _lock_timer: float = 0.0
var _hit_timer: float = 0.0
var _power_cooldown_timer: float = 0.0
var _dash_timer: float = 0.0
var _current_hit_damage: float = 0.0
var _already_hit: Array[Node3D] = []


func _ready() -> void:
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _process(delta: float) -> void:
	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_index = 0
			combo_step_changed.emit(0)

	if _lock_timer > 0.0:
		_lock_timer -= delta

	if _hit_timer > 0.0:
		_hit_timer -= delta
		if _hit_timer <= 0.0:
			hitbox.monitoring = false

	if _power_cooldown_timer > 0.0:
		_power_cooldown_timer -= delta
		power_cooldown_changed.emit(max(_power_cooldown_timer, 0.0), POWER_COOLDOWN)

	if _dash_timer > 0.0:
		_dash_timer -= delta
		var forward := -model.global_transform.basis.z
		forward.y = 0.0
		forward = forward.normalized()
		player.velocity.x = forward.x * POWER_DASH_SPEED
		player.velocity.z = forward.z * POWER_DASH_SPEED


func can_move() -> bool:
	return _lock_timer <= 0.0


func try_attack() -> void:
	if _lock_timer > 0.0:
		return
	_combo_timer = COMBO_WINDOW
	_lock_timer = COMBO_LOCK_TIME[_combo_index]
	combo_step_changed.emit(_combo_index + 1)
	_activate_hit(COMBO_DAMAGE[_combo_index])
	_combo_index = (_combo_index + 1) % COMBO_DAMAGE.size()


func try_power() -> void:
	if _power_cooldown_timer > 0.0 or _lock_timer > 0.0:
		return
	_power_cooldown_timer = POWER_COOLDOWN
	_lock_timer = POWER_LOCK_TIME
	_dash_timer = POWER_DASH_TIME
	power_used.emit()
	_activate_hit(POWER_DAMAGE)


func _activate_hit(damage: float) -> void:
	_already_hit.clear()
	_current_hit_damage = damage
	hitbox.monitoring = true
	_hit_timer = HIT_ACTIVE_TIME


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body in _already_hit:
		return
	if not body.is_in_group("enemies"):
		return
	_already_hit.append(body)
	var target_health := body.get_node_or_null("Health") as Health
	if target_health:
		target_health.take_damage(_current_hit_damage)
