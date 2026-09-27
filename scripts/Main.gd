extends Node3D
## Cena de teste: conecta a HUD ao jogador. A área em si (chão, props,
## inimigos) fica montada direto na cena Main.tscn.

@onready var player: CharacterBody3D = $Player as CharacterBody3D
@onready var hud: HUD = $HUD as HUD


func _ready() -> void:
	hud.setup(player)
