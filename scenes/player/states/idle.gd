extends State

func enter(_prev):
  actor.velocity = Vector2.ZERO
  actor.play_directional_anim("idle")

func update(_delta):
  #if GM.scene_transition.transitioning o r actor.input_disabled:
    #return
  
  if actor.is_searching or actor.is_dead: return
  
  var input_vec = get_input_vector()

  if input_vec != Vector2.ZERO:
    request_state("Walk")
    return

  #if actor.can_interact():
    #actor.interaction_allowed = falses
    #request_state("Interact")
    #
  #if Input.is_action_just_pressed("switch_weapon"):
    #actor.switch_weapon()
  #
  #if Input.is_action_just_pressed("heal") and actor.can_heal():
    #request_state("Heal")

func dir_to_string(v: Vector2) -> String:
  if v == Vector2.RIGHT: return "right"
  if v == Vector2.LEFT: return "left"
  if v == Vector2.UP: return "up"
  return "down"

func get_input_vector():
  return Vector2(
    Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
    Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
  )
