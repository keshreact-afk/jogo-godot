# Jogo Godot

Protótipo de um jogo de ação-aventura 3D para PC, em Godot 4, jogado em
terceira pessoa, com combate corpo a corpo em combo, um poder especial,
progressão por XP/árvore de habilidades e um mundo aberto conectado.

## Decisões de design (fechadas com o Kesh)

- **Gênero:** ação-aventura com elementos de RPG (poderes, chefes, XP)
- **Câmera:** terceira pessoa, com mouse look e colisão de câmera (`SpringArm3D`)
- **Arte:** cartoon / toon shading
- **Combate:** combo corpo a corpo de 3 golpes + 1 poder de apoio com cooldown
- **Mundo:** aberto e conectado
- **Progressão:** XP com pontos de habilidade (árvore de skills — ainda não implementada)
- **Escopo deste protótipo:** uma área pequena de teste, personagem com
  combo de 3 golpes, 1 poder, 1 tipo de inimigo comum, sem chefe ainda

## Como abrir

1. Instale o [Godot Engine 4.x](https://godotengine.org/download) (o projeto foi
   testado na 4.3 e é compatível com a 4.7).
2. No Gerenciador de Projetos do Godot, clique em **Importar** (não em
   "Criar Novo Projeto") e selecione o arquivo `project.godot` desta pasta.
3. Rode a cena principal (`scenes/Main.tscn`) com F5 ou o botão de play.

## Controles (protótipo)

| Ação | Tecla |
|---|---|
| Mover | W A S D |
| Pular | Espaço |
| Golpe (combo) | Clique esquerdo do mouse |
| Poder (investida) | Clique direito do mouse |
| Câmera | Mover o mouse |
| Soltar/prender o mouse | Esc |

## Estrutura do projeto

```
scenes/
  Main.tscn          # área de teste: chão, props, jogador, inimigos, HUD
  player/Player.tscn  # personagem: corpo, câmera, hitbox de ataque
  enemies/Enemy.tscn  # inimigo comum: detecção, perseguição, ataque
  ui/HUD.tscn         # HUD de depuração (vida, combo, cooldown do poder)
scripts/
  autoload/InputSetup.gd  # registra as ações de input em código
  common/Health.gd         # componente de vida reutilizável (jogador e inimigos)
  player/Player.gd         # movimento, câmera, input
  player/PlayerCombat.gd   # combo, poder, hitbox de ataque
  enemies/Enemy.gd         # IA simples: parado → persegue → ataca → respawna
  ui/HUD.gd
  Main.gd
```

## Estado atual

O personagem e o inimigo ainda usam formas simples (cápsulas/caixas) com
material toon como placeholder visual — a lógica de movimento, câmera,
combo e IA já está funcional e pronta pra receber os modelos/animações
definitivos sem precisar reescrever o código.

## Próximos passos

- Trocar as formas placeholder por assets de personagem/cenário definitivos
  (licença livre, com créditos documentados aqui quando adicionados)
- Sistema de XP e árvore de habilidades
- Primeiro chefe
- Expandir a área de teste rumo ao mundo aberto
