class_name BlockingDoor extends StaticBody2D

@export var pressure_plate: PressurePlate
@export var room: Room

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var occupancy_area: Area2D = $OccupancyArea

var held_open: bool = false
var pending_close: bool = false

var overlapping_occupants: Array[Node2D] = []
var spill_light: PointLight2D

signal closing_blocked(blacked: bool)

func _ready() -> void:  
  animation_player.animation_finished.connect(_on_animation_finished)
    
  occupancy_area.body_entered.connect(_on_occupancy_body_entered)
  occupancy_area.body_exited.connect(_on_occupancy_body_exited)
  
  if pressure_plate:
    closing_blocked.connect(pressure_plate.lock_current_weight)
    pressure_plate.weight_changed.connect(set_held_open)
  
  spill_light = find_spill_light()
  if spill_light:
    toggle_spill_light(false)
    
  set_blocked(true)

func set_held_open(should_open: bool):
  if should_open:
    pending_close = false
    if held_open:
      return
    held_open = true
    set_moving(should_open)
    return
    
  if not held_open:
    return
  pending_close = true
  try_close()
  
func try_close() -> void:
  if not pending_close:
    return
  if overlapping_occupants.size() > 0:
    return
  pending_close = false
  held_open = false
  set_moving(false)
  set_blocked(true)

func set_moving(opening: bool) -> void:
  var l: float = animation_player.get_animation("open").length
  var t: float = 0.0
  var cur := animation_player.current_animation
  if cur == "open" or cur == "close":
    t = animation_player.current_animation_position
    if (opening and cur == "close") or (not opening and cur == "open"):
      t = l - t
  animation_player.play("open" if opening else "close")
  animation_player.seek(t, true)

func _on_animation_finished(anim_name: StringName) -> void:
  if anim_name == "open":
    animation_player.play("opened")
    set_blocked(false)
  elif anim_name == "close":
    animation_player.play("closed")
  
func set_blocked(blocked: bool) -> void:
  collision_shape.set_deferred("disabled", not blocked)

func _on_occupancy_body_entered(body: Node2D):
  if body not in overlapping_occupants:
    overlapping_occupants.append(body)
  closing_blocked.emit(overlapping_occupants.size() > 0)

func _on_occupancy_body_exited(body: Node2D):
  if body in overlapping_occupants:
    overlapping_occupants.erase(body)
  
  closing_blocked.emit(overlapping_occupants.size() > 0)
    
  if pending_close and overlapping_occupants.size() <= 0:
    try_close()

func toggle_spill_light(turn_on: bool):
  if spill_light:
    spill_light.visible = turn_on
  
func find_spill_light() -> PointLight2D:
  if not room:
    print("Room not assigned: ", room)
    return
  var best: PointLight2D = null
  var best_d := 128.0
  for node in room.find_children("*", "PointLight2D", true, false):
    if node.is_in_group("spill_light"):
      print(node)
      var d: float = global_position.distance_to(node.global_position)
      if d < best_d:
        best_d = d
        best = node
  print(best)
  return best
