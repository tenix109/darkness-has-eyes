class_name MessageSign
extends Interactable

@export var message: String

func interact(_player: Player) -> void:
  GameManager.show_toast_message(message)
