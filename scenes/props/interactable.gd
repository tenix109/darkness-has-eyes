class_name Interactable
extends Area2D

@export var interaction_prompt: String = "Interact"

func interact(_player: Player) -> void:
    pass

func can_interact(_player: Player) -> bool:
  return true
