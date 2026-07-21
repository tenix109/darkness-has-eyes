class_name Searchable
extends Interactable

# signal search_started
# signal search_completed(found_item: bool)

@export var search_time_range: Vector2 = Vector2(3.0, 7.0)

var elapsed_time: float = 0.0
var is_complete: bool = false
var search_time: float = 5.0

var was_interrupted: bool = false

const SEARCH_FAIL = preload("uid://cjxqo0riuqmkd")
const SEARCH_SUCCESS = preload("uid://ci3tl2neh5pdr")

func _ready():
  GameManager.register_searchable()
  search_time = randf_range(search_time_range.x, search_time_range.y)

func can_interact(player: Player) -> bool:
  if is_complete:
    GameManager.show_toast_message("Nothing useful here.")
    return false
  if not player.is_in_light():
    GameManager.show_toast_message("It's too dark to see.")
    return false
  return true

func interact(player: Player):
  if not can_interact(player): return
  player.start_searching(self)

func interrupt_search(time_saved: float, is_lit: bool) -> void:
  was_interrupted = true
  elapsed_time = time_saved
  if not is_lit:
    GameManager.show_toast_message("It's too dark to see.")

func complete_search() -> void:
  if was_interrupted:
    SaveManager.interrupted_Search_completed()
  else:
    SaveManager.uninterrupted_Search_completed()
  
  is_complete = true
  var success = GameManager.handle_search_completion()
  if success:
    AudioManager.play_sfx(SEARCH_SUCCESS, -8.0)
    GameManager.show_key_item_acquired_toast()
  else:
    AudioManager.play_sfx(SEARCH_FAIL)
    GameManager.show_toast_message("Nothing useful here.")
