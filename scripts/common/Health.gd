extends Node
class_name Health
## Componente reutilizável de vida. Anexado como filho de qualquer
## personagem (jogador ou inimigo) que precise poder tomar dano e morrer.

signal damaged(amount: float, current: float)
signal died

@export var max_health: float = 100.0

var current_health: float


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	current_health = max(current_health - amount, 0.0)
	damaged.emit(amount, current_health)
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)


func is_dead() -> bool:
	return current_health <= 0.0


func reset() -> void:
	current_health = max_health
