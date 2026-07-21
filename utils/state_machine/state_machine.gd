class_name StateMachine
extends Node

var current_state: State
var states := {}

func _ready():
  for child in get_children():
    if child is State:
      states[child.name] = child
      child.state_machine = self
      child.actor = get_parent()


func request_state(state_name: String, _immediate := false):
  if current_state != null and state_name == current_state.name:
    return

  if not states.has(state_name):
    push_warning("State %s does not exist" % state_name)
    return

  var new_state = states[state_name]

  if current_state:
    current_state.exit(state_name)

  var prev = current_state
  current_state = new_state
  current_state.enter(prev.name if prev != null else null)


func _process(delta):
  if current_state:
    current_state.update(delta)

func _physics_process(delta):
  if current_state:
    current_state.physics_update(delta)

func get_current_state_name() -> String:
  return states.find_key(current_state)
