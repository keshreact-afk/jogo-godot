extends Node
class_name PlayerAnimation
## Toca as animações do personagem (Warrior, do pack CC0 da Quaternius —
## ver CREDITS.md) de acordo com o estado do jogador: parado, andando,
## golpe de combo, poder, dano e morte.
##
## Se o personagem aparecer virado pro lado errado ao andar, ajuste
## `model_facing_offset_degrees` no Player.gd (que é quem controla a
## rotação do nó Model) em vez de mexer neste script.

const COMBO_ANIMATIONS: Array[String] = ["Sword_Attack", "Sword_Attack2", "Punch"]
const POWER_ANIMATION := "Roll"
const HIT_ANIMATION := "RecieveHit"
const DEATH_ANIMATION := "Death"
const MOVE_ANIMATION := "Run"
const IDLE_ANIMATION := "Idle"
const MOVE_SPEED_THRESHOLD := 0.5

@onready var player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var anim_player: AnimationPlayer = (
	player.get_node("Model/WarriorModel/AnimationPlayer") as AnimationPlayer
)
@onready var combat: PlayerCombat = player.get_node("Combat") as PlayerCombat
@onready var health: Health = player.get_node("Health") as Health

var _action_playing: bool = false


func _ready() -> void:
	combat.combo_step_changed.connect(_on_combo_step_changed)
	combat.power_used.connect(_on_power_used)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	anim_player.animation_finished.connect(_on_animation_finished)

	# Garante que golpes/poder/dano/morte tocam uma vez só, independente
	# de como a animação foi marcada no arquivo original.
	for anim_name in COMBO_ANIMATIONS + [POWER_ANIMATION, HIT_ANIMATION, DEATH_ANIMATION]:
		var anim := anim_player.get_animation(anim_name)
		if anim:
			anim.loop_mode = Animation.LOOP_NONE

	anim_player.play(IDLE_ANIMATION)


func _process(_delta: float) -> void:
	if _action_playing:
		return

	var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
	var target := MOVE_ANIMATION if horizontal_speed > MOVE_SPEED_THRESHOLD else IDLE_ANIMATION
	if anim_player.current_animation != target or not anim_player.is_playing():
		anim_player.play(target)


func _on_combo_step_changed(step: int) -> void:
	if step <= 0:
		return
	var index: int = clampi(step - 1, 0, COMBO_ANIMATIONS.size() - 1)
	_play_action(COMBO_ANIMATIONS[index])


func _on_power_used() -> void:
	_play_action(POWER_ANIMATION)


func _on_damaged(_amount: float, current: float) -> void:
	if current <= 0.0:
		return
	_play_action(HIT_ANIMATION)


func _on_died() -> void:
	_play_action(DEATH_ANIMATION)


func _play_action(animation_name: String) -> void:
	_action_playing = true
	anim_player.play(animation_name)


func _on_animation_finished(_anim_name: StringName) -> void:
	_action_playing = false
