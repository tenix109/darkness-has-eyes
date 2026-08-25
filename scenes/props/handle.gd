class_name PushHandle
extends Interactable

@export var side: Vector2

func interact(player: Player) -> void:
  player.start_pushing(get_parent() as Pushable, side)
