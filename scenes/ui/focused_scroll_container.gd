extends ScrollContainer

@export var scroll_speed: float = 400.0

func _ready() -> void:
  focus_mode = Control.FOCUS_NONE
  visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
  if is_visible_in_tree():
    focus_mode = Control.FOCUS_ALL
    scroll_vertical = 0
    grab_focus.call_deferred()
  else:
    focus_mode = Control.FOCUS_NONE

func _process(delta: float) -> void:
  if not has_focus():
    return
    
  var max_scroll = get_v_scroll_bar().max_value - get_rect().size.y
  
  # Sample the current input state directly once per frame
  if Input.is_action_pressed("ui_down"):
    if scroll_vertical < max_scroll:
      scroll_vertical += int(scroll_speed * delta)
      
  elif Input.is_action_pressed("ui_up"):
    if scroll_vertical > 0:
      scroll_vertical -= int(scroll_speed * delta)
