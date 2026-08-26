class_name PushHandle
extends Interactable

@export var side: Vector2
@export var side_margin: float = 4.0

func can_interact(player: Player) -> bool:
  var cart: Pushable = get_parent() as Pushable
  var to_player: Vector2 = player.global_position - cart.global_position
  
  if to_player.dot(side) <= side_margin:
    return false

  if player.facing != -side:
    return false
    
  return true
  
func interact(player: Player) -> void:
  if not can_interact(player):
    return
  player.start_pushing(get_parent() as Pushable, side)
