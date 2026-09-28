extends Node
class_name EnemyAnimation
## Toca as animações do inimigo comum (Monk, do pack CC0 da Quaternius —
## ver CREDITS.md): parado, perseguindo, atacando, tomando dano e morrendo.

const ATTACK_ANIMATIONS: Array[String] = ["Attack", "Attack2"]
const HIT_ANIMATIONS: Array[String] = ["RecieveHit", "RecieveHit_2"]
const DEATH_ANIMATION := "Death"
const MOVE_ANIMATION := "Run"
const IDLE_ANIMATION := "Idle"
const MOVE_SPEED_THRESHOLD := 0.5

@onready var enemy: CharacterBody3D = get_parent() as CharacterBody3D
@onready var anim_player: AnimationPlayer = (
	enemy.get_node("Model/MonkModel/AnimationPlayer") as AnimationPlayer
)
@onready var health: Health = enemy.get_node("Health") as Health

var _action_playing: bool = false
var _attack_index: int = 0
var _hit_index: int = 0


func _ready() -> void:
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	anim_player.animation_finished.connect(_on_animation_finished)

	for anim_name in ATTACK_ANIMATIONS + HIT_ANIMATIONS + [DEATH_ANIMATION]:
		var anim := anim_player.get_animation(anim_name)
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

	anim_player.play(IDLE_ANIMATION)


func _process(_delta: float) -> void:
	if _action_playing:
		return

	var horizontal_speed := Vector2(enemy.velocity.x, enemy.velocity.z).length()
	var target := MOVE_ANIMATION if horizontal_speed > MOVE_SPEED_THRESHOLD else IDLE_ANIMATION
	if anim_player.current_animation != target or not anim_player.is_playing():
		anim_player.play(target)


func play_attack() -> void:
	var animation_name: String = ATTACK_ANIMATIONS[_attack_index]
	_attack_index = (_attack_index + 1) % ATTACK_ANIMATIONS.size()
	_play_action(animation_name)


func reset() -> void:
	_action_playing = false
	anim_player.play(IDLE_ANIMATION)


func _on_damaged(_amount: float, current: float) -> void:
	if current <= 0.0:
		return
	var animation_name: String = HIT_ANIMATIONS[_hit_index]
	_hit_index = (_hit_index + 1) % HIT_ANIMATIONS.size()
	_play_action(animation_name)


func _on_died() -> void:
	_play_action(DEATH_ANIMATION)


func _play_action(animation_name: String) -> void:
	_action_playing = true
	anim_player.play(animation_name)


func _on_animation_finished(_anim_name: StringName) -> void:
	_action_playing = false
