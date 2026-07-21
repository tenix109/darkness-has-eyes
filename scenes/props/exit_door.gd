class_name ExitDoor
extends Interactable

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func can_interact(_player) -> bool:
  if not GameManager.has_all_required_items():
    GameManager.show_required_item_toast()
    return false
  return true
  
func interact(player):
  if not can_interact(player): return
  animation_player.play("opening")
  GameManager.use_items_on_exit()
  
