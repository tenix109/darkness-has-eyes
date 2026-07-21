extends State

func physics_update(_delta):
  if actor.is_in_light():
    request_state("Idle")
    return
  
  if not actor.visible_on_screen_notifier.is_on_screen() and actor.start_room != GameManager.player.current_room:
    actor.set_collision_mask_value(1, false)
    actor.set_collision_mask_value(4, false)
    actor.global_position = actor.start_point
    request_state("Idle")
    return

  actor.nav_agent.target_position = actor.start_point
  
  if actor.nav_agent.is_navigation_finished():
    request_state("Idle")
    return

  var next_path_pos = actor.nav_agent.get_next_path_position()
  var direction = actor.global_position.direction_to(next_path_pos)
  
  
  actor.velocity = direction * actor.max_speed * 1.8
