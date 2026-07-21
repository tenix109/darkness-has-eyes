extends Node2D

@export var visible_on_runtime: bool = true

func _ready():
    if visible_on_runtime:
      visible = true
    else:
      queue_free()
