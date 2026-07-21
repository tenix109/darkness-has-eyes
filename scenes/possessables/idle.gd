class_name PropIdle
extends State

func enter(_prev):
  actor.set_physics_process(false)
  actor.set_process(false)
  actor.outline_sprite.visible = false
  actor.sprite.position = Vector2.ZERO
  actor.sprite.rotation = 0.0
  actor.velocity = Vector2.ZERO
