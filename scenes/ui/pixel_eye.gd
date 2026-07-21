extends Node2D

@export var color_list: Array[Color]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var eyeball: Sprite2D = $Eyeball
@onready var pupil: Sprite2D = $Eyeball/Pupil

var anim_list: PackedStringArray

func _ready() -> void:
  anim_list = animation_player.get_animation_list()
  animation_player.animation_finished.connect(_on_animation_complete)
  blink()
  random_animation()
  
  
func _on_animation_complete(_anim_name: String):
  await get_tree().create_timer(randf_range(0.1, 0.66)).timeout
  random_animation()

func random_animation():
  if anim_list.size() > 0:
    animation_player.speed_scale = randf_range(0.4, 1.2)
    animation_player.play(anim_list[randi() % anim_list.size()])  

func blink():
  await get_tree().create_timer(randf_range(2.5, 6.5)).timeout
  eyeball.visible = false
  pupil.modulate = color_list.pick_random()
  await get_tree().create_timer(randf_range(0.25, 0.66)).timeout
  eyeball.visible = true
  blink()
  
