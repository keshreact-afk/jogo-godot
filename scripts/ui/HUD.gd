extends CanvasLayer
class_name HUD
## HUD mínima de depuração: mostra vida, estado do combo e cooldown do
## poder do jogador. Só texto, pra testar os sistemas — vira UI de
## verdade (barras, ícones) numa próxima passada de arte/UX.

@onready var health_label: Label = $Margin/VBox/HealthLabel as Label
@onready var combo_label: Label = $Margin/VBox/ComboLabel as Label
@onready var power_label: Label = $Margin/VBox/PowerLabel as Label

var _player_health: Health
var _player_combat: PlayerCombat


func setup(player: Node3D) -> void:
	_player_health = player.get_node("Health") as Health
	_player_combat = player.get_node("Combat") as PlayerCombat

	_player_health.damaged.connect(_on_player_damaged)
	_player_health.died.connect(_on_player_died)
	_player_combat.combo_step_changed.connect(_on_combo_step_changed)
	_player_combat.power_used.connect(_on_power_used)
	_player_combat.power_cooldown_changed.connect(_on_power_cooldown_changed)

	_update_health_label()


func _update_health_label() -> void:
	health_label.text = "HP: %d / %d" % [
		int(_player_health.current_health),
		int(_player_health.max_health),
	]


func _on_player_damaged(_amount: float, _current: float) -> void:
	_update_health_label()


func _on_player_died() -> void:
	_update_health_label()


func _on_combo_step_changed(step: int) -> void:
	combo_label.text = "Combo: -" if step == 0 else "Combo: %d" % step


func _on_power_used() -> void:
	power_label.text = "Poder: recarregando"


func _on_power_cooldown_changed(remaining: float, _total: float) -> void:
	power_label.text = "Poder: pronto" if remaining <= 0.0 else "Poder: %.1fs" % remaining
