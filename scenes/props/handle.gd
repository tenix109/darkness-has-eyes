class_name PushHandle
extends Interactable

@export var side: Vector2
@export var side_margin: float = 2.0

@export var locked_prompt: String = "The doorway is blocked."

@export var pushable: Pushable

var default_interaction_prompt: String = ""

func _ready() -> void:
  if not pushable:
    pushable = owner

func can_interact(player: Player) -> bool:
  var to_player: Vector2 = player.global_position - pushable.global_position

  if to_player.dot(side) <= side_margin:
    return false

  if player.facing != -side:
    return false

  return true
  
func interact(player: Player) -> void:
  if pushable.locked:
    return
  if not can_interact(player):
    return
  player.start_pushing(pushable, side)
