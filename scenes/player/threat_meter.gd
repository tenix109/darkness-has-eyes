extends Node

@export var player: Player

@export var threat_decay_rate: float = 8.0
@export var threat_dark_rate: float = 4.0
@export var threat_run_bonus: float = 6.0
@export var threat_search_penalty: float = 6.0

var threat: float = 0.0

func _process(delta):
    _update_threat(delta)

func _update_threat(delta: float) -> void:
  var threat_change: float = 0.0

  if player.is_in_light():
    threat_change -= threat_decay_rate
    if player.is_searching:
      threat_change += threat_search_penalty
  else:
    threat_change += threat_dark_rate
    
    if player.is_running:
      threat_change += threat_run_bonus

  threat += threat_change * delta
  threat = clamp(threat, 0.0, 100.0)

func event_increase():
  threat += randf_range(10, 40)
  threat = clamp(threat, 0.0, 100.0)
