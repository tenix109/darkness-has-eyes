class_name Room
extends Node2D

@export var is_start_room: bool = false
@export var is_hallway: bool = false
@export var has_no_light: bool = false

@onready var area: Area2D = $RoomArea
  
var is_lit: bool = false

func _ready() -> void:
  if is_start_room: is_lit = true
  area.body_entered.connect(_on_room_body_entered)
  area.body_exited.connect(_on_room_body_exited)

func _on_room_body_entered(body):
  if self not in body.overlapping_rooms:
    body.overlapping_rooms.append(self)

  body.current_room = self
  
  if "start_room" in body:
    if body.start_room == null:
      body.start_room = self

func _on_room_body_exited(body):
    body.overlapping_rooms.erase(self)

    if body.current_room == self:
      if body.overlapping_rooms.is_empty():
        body.current_room = null
      else:
        body.current_room = body.overlapping_rooms.back()
