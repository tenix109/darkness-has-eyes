extends State

@export var repel_force: float = 500.0
@export var friction: float = 10.0
@export var repel_duration: float = 0.4

var timer: float = 0.0
var repel_dir: Vector2 = Vector2.ZERO
var is_colliding: bool = false

const REPEL_SFX = preload("uid://nblemsw7h4kj")

func enter(_prev):
  SaveManager.handle_repel()
  AudioManager.play_sfx_positional(REPEL_SFX, actor.global_position)
  
  is_colliding = false
  
  actor.outline_sprite.visible = false
  timer = repel_duration
  
  if not actor.entered_lit_room:
    repel_dir = actor.last_move_direction * -1.0
  else:
    var player = GameManager.player
    if player:
      repel_dir = actor.global_position.direction_to(player.global_position) * -1

func physics_update(delta):
  timer -= delta
  
  if timer < repel_duration - 0.1 and not is_colliding:
    actor.set_collision_mask_value(1, true)
    actor.set_collision_mask_value(4, true)
   
  if timer <= 0:
    if not actor.current_room or actor.overlapping_rooms.size() > 1 or actor.current_room.is_hallway:
      state_machine.request_state("Flee")
      return
    elif not actor.current_room.is_lit:
      state_machine.request_state("Flee")
      return
    else:
      state_machine.request_state("Idle", true)
      return
  
  var current_velocity = repel_dir * repel_force * (timer / repel_duration)
  actor.velocity = current_velocity

func exit(_next):
  actor.set_collision_mask_value(1, false)
  actor.set_collision_mask_value(4, false)
  actor.cooldown()
