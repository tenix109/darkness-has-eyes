class_name Actor
extends CharacterBody2D

@export var footstep_sounds: Array[AudioStream]

var entered_lit_room: bool = false
var overlapping_rooms: Array[Room]
var current_room: Room:
  set(value):
    current_room = value
    if current_room:
      entered_lit_room = current_room.is_lit

func is_in_light() -> bool:
  if current_room == null: return false
  return current_room.is_lit
    
func play_footstep():
  if footstep_sounds.is_empty():
    return
  var sound: AudioStream = footstep_sounds.pick_random()
  AudioManager.play_sfx(sound, -20.0)
