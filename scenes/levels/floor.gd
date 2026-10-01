class_name Floor
extends Node2D

@export var items_required_for_exit: int = 1
@export var next_scene_path: String
@export var base_find_chance: float = -0.2
@export var chance_increase: float = 0.1
@export var floor_name: String = "Floor 1"
@export var level_title: String = "The Beginning"
## used for unlocked_levels array in SaveManager
@export var level_index: int = 0
@export var chapter_index: int = 0
@export var is_chapter_finale: bool = false


@onready var darkness: CanvasModulate = $Darkness

func _ready() -> void:
  GameManager.current_floor = self
  GameManager.hud.display_level_title(floor_name.to_upper(), level_title)

func fade_darkness():
  var tween = create_tween()
  
  tween.tween_property(darkness, "color", Color.WHITE, 0.5).set_delay((0.5))
