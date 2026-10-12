class_name PressurePlate extends Area2D

var current_pushable_weight: Pushable = null
var overlapping_areas: Array[Node2D]
var is_pressed: bool = false

signal weight_changed(is_pressed: bool)

func _ready() -> void:
  area_entered.connect(_on_area_entered)
  area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
  if area not in overlapping_areas:
    overlapping_areas.append(area)
    var p = area.get_parent()
    if p is Pushable:
      current_pushable_weight = p as Pushable
  check_is_pressed()
  
func _on_area_exited(area: Area2D):
  if area in overlapping_areas:
    overlapping_areas.erase(area)
    if current_pushable_weight == area.get_parent():
      current_pushable_weight = null
  check_is_pressed()
    
func check_is_pressed():
  var pressed: bool = overlapping_areas.size() > 0
  if pressed == is_pressed:
    return
  is_pressed = pressed
  weight_changed.emit(is_pressed)
  
func lock_current_weight(locked: bool):
  if current_pushable_weight:
    current_pushable_weight.locked = locked
