class_name Possessor
extends Node

@export var min_dist = 16.0
@export var max_dist = 128.0
@export var ovani_player: OvaniPlayer

var possessables: Array[Possessable]
@export var max_possessed: int = 1
var possessed_count: int = 0

var check_timer: float = 0.0
var check_interval: float = 1.0

# Used for multiple possessables
var possess_cooldown: float = 3.0
var possess_cooldown_timer: float = 0.0

var current_possessable: Possessable

func _ready() -> void:
  GameManager.possessor = self
  possessed_count = 0

func _process(delta):
  check_timer += delta
  possess_cooldown_timer += delta

  _update_music_intensity()
  
  if possess_cooldown_timer < possess_cooldown:
    return
    
  possess_cooldown_timer = 0.0
  
  if check_timer < check_interval:
      return

  check_timer = 0.0
  
  _evaluate_threat()

func register_possessable(possessable: Possessable):
  possessables.append(possessable)

func _update_music_intensity():
  var target_intensity: float = 0.0
  if possessed_count > 0:
    target_intensity = 1.0
  else:
    target_intensity = (GameManager.player.threat_meter.threat / 100.0) * 0.8
    target_intensity = clamp(target_intensity, 0.0, 0.88)

  if abs(ovani_player.Intensity - target_intensity) > 0.01:
    ovani_player.Intensity = target_intensity

@export var dist_increase_at_high_threat: float = 32.0
func _evaluate_threat():
  var threat = GameManager.player.threat_meter.threat
  if threat < 30.0 or possessed_count >= max_possessed:
    return
  
  var effective_max_dist = max_dist
  
  if threat >= 70.0:
    var steps = int((threat - 60.0) / 10.0) + 1
    effective_max_dist += steps * dist_increase_at_high_threat
  
  var player_pos = GameManager.player.global_position
  var nearby_props := []
    
  for prop in possessables:
    if prop.can_awaken():
      var dist = player_pos.distance_to(prop.global_position)
      if dist >= min_dist and dist <= effective_max_dist:
        nearby_props.append(prop)
  
  if nearby_props.is_empty():
    return

  var selected = nearby_props.pick_random()
  current_possessable = selected
  selected.awaken()

func remove_current_possessable():
  current_possessable = null
  possessed_count -= 1

func repel_current_possessable():
  if current_possessable:
    current_possessable.state_machine.request_state("Repelled", true)
