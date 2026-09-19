extends Node


var max_find_chance: float = 0.9

var search_count: int = 0
var total_search_count: int = 0
var total_searchables_on_floor: int = 0

var key_items_held: int = 0

var hud: HUD
var player: Player
var current_floor: Floor
var possessor: Possessor

var battery_img_path: String = "res://art/images/props/battery_25x50px1.png"

var transition_layer: CanvasLayer
var transition_rect: ColorRect

var pause_count: int = 0

signal device_changed(device_type: String)

enum DeviceType { KEYBOARD, XBOX, PLAYSTATION }
var current_device: DeviceType = DeviceType.KEYBOARD

func _ready() -> void:
  Steam.steamInitEx()
  
  process_mode = Node.PROCESS_MODE_ALWAYS
  setup_transistion_layer()

func pause():
  get_tree().paused = true
  pause_count += 1
  
func unpause():
  pause_count -= 1
  if pause_count <= 0:
    pause_count = 0
    get_tree().paused = false

func fully_unpause():
  pause_count = 0
  get_tree().paused = false

func setup_transistion_layer():
  transition_layer = CanvasLayer.new()
  transition_layer.layer = 100
  
  transition_rect = ColorRect.new()
  transition_rect.color = Color.BLACK
  transition_rect.modulate.a = 0.0
  transition_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
  
  transition_layer.add_child(transition_rect)
  add_child(transition_layer)

func register_searchable():
  total_searchables_on_floor += 1

func show_context_message(text: String):
  hud.show_context_message(text)

func hide_context_message():
  hud.hide_context_message()

func show_toast_message(text: String):
  hud.show_toast_message(text)

func show_required_item_toast():
  var message: String = "[img=32]%s[/img] x%d required" % [battery_img_path, current_floor.items_required_for_exit]
  show_toast_message(message)

func show_key_item_acquired_toast():
  var message: String = "[img=32]%s[/img] x1 acquired" % battery_img_path
  show_toast_message(message)

func get_find_chance() -> float:
  return minf(current_floor.base_find_chance + (current_floor.chance_increase * search_count), max_find_chance)

func handle_search_completion() -> bool: 
  var items_missing = current_floor.items_required_for_exit - key_items_held
  var searchables_remaining = total_searchables_on_floor - total_search_count
  
  search_count += 1
  total_search_count += 1
  
  if items_missing > 0 and searchables_remaining <= items_missing:
    grant_item_to_player()
    return true
  
  var current_chance = get_find_chance()
  var roll = randf()
  if roll <= current_chance:
    grant_item_to_player()
    return true
  
  return false

func grant_item_to_player():
  key_items_held += 1
  hud.update_fuse_count(key_items_held)
  search_count = 0

func use_items_on_exit() -> bool:
  if key_items_held >= current_floor.items_required_for_exit:
    player.is_winning = true
    key_items_held = 0
    hud.update_fuse_count(key_items_held)
    current_floor.fade_darkness()
    await get_tree().create_timer(0.5, false).timeout
    possessor.repel_current_possessable()
    await get_tree().create_timer(1.5, false).timeout
    if current_floor.is_chapter_finale:
      print("Is Chapter Finale")
      hud.chapter_complete(current_floor.chapter_index)
      return true
    next_level()
    return true
  return false

func has_all_required_items() -> bool:
  return key_items_held >= current_floor.items_required_for_exit

func can_pause() -> bool:
  return not (player.is_dead or player.is_winning)

func reset_floor():
  search_count = 0
  total_search_count = 0
  key_items_held = 0
  total_searchables_on_floor = 0

func game_over():
  unlock_achievement("ACH_DEATH")
  hud.game_over_screen.trigger_game_over()
  
func retry_level():
  reset_floor()
  get_tree().reload_current_scene()
  
func load_title_screen():
  change_scene("res://scenes/main_menu.tscn")

func next_level():
  reset_floor()
  
  match current_floor.level_index:
    0: unlock_achievement("ACH_FIRST_FLOOR")
    1: unlock_achievement("ACH_SECOND_FLOOR")
    2: unlock_achievement("ACH_THIRD_FLOOR")
  
  SaveManager.mark_cleared(current_floor.level_index)
  change_scene(current_floor.next_scene_path)

func change_scene(target_scene_path: String) -> void:
  Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
  var fade_tween = create_tween()
  fade_tween.tween_property(transition_rect, "modulate:a", 1.0, 1.0)
  
  fade_tween.tween_callback(func():
    get_tree().change_scene_to_file(target_scene_path)
    if pause_count > 0:
      fully_unpause()
  )
  fade_tween.chain().tween_property(transition_rect, "modulate:a", 0.0, 0.5)
  
func find_and_grab_focus(node: Node) -> bool:
  if node is Control and node.focus_mode != Control.FOCUS_NONE:
    node.grab_focus()
    return true
  
  for child in node.get_children():
    if find_and_grab_focus(child):
      return true
      
  return false

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_end"):
    grant_item_to_player()
  
  if event is InputEventMouseMotion or event.is_echo():
    return
    
  var new_device = current_device
  
  if event is InputEventKey:
    if not event.pressed: 
      return
    new_device = DeviceType.KEYBOARD
  elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
    if event is InputEventJoypadButton and not event.pressed:
      return # Ignore button releases
    if event is InputEventJoypadMotion and abs(event.axis_value) < 0.3:
      return # Ignore joystick deadzones/centering
      
    var device_name = Input.get_joy_name(event.device).to_lower()
    if "playstation" in device_name or "ps" in device_name or "dualshock" in device_name or "dualsense" in device_name:
      new_device = DeviceType.PLAYSTATION
    else:
      new_device = DeviceType.XBOX

  if new_device != current_device:
    current_device = new_device
    device_changed.emit(get_device_string())

  if new_device != current_device:
    current_device = new_device
    device_changed.emit(get_device_string())

func get_device_string() -> String:
  match current_device:
    DeviceType.KEYBOARD: return "keyboard"
    DeviceType.XBOX: return "xbox"
    DeviceType.PLAYSTATION: return "playstation"
  return "keyboard"
  
func get_action_bbcode(action_name: String) -> String:
  var events = InputMap.action_get_events(action_name)
  var device_str = get_device_string()

  for event in events:
    # Match keyboard keys
    if current_device == DeviceType.KEYBOARD and event is InputEventKey:
      var key_string = OS.get_keycode_string(event.physical_keycode).to_lower()
      return "[img=48 color=#cccccc]res://art/ui/input_icons/keyboard/" + key_string + ".png[/img]"
      
    # Match controller buttons
    elif current_device != DeviceType.KEYBOARD and event is InputEventJoypadButton:
      var button_index = event.button_index
      var button_name = _get_joypad_button_name(button_index)
      return "[img=48x48  ]res://art/ui/input_icons/" + device_str + "/" + button_name + ".png[/img]"
      
  return "[E]" # Hardcoded string fallback just in case

func _get_joypad_button_name(index: int) -> String:
  match current_device:
    DeviceType.PLAYSTATION:
      match index:
        JOY_BUTTON_A: return "cross"
        JOY_BUTTON_B: return "circle"
        JOY_BUTTON_X: return "square"
        JOY_BUTTON_Y: return "triangle"
    
    #DeviceType.NINTENDO:
      #match index:
        #JOY_BUTTON_A: return "b"
        #JOY_BUTTON_B: return "a"
        #JOY_BUTTON_X: return "y"
        #JOY_BUTTON_Y: return "x"
        
    _:
      match index:
        JOY_BUTTON_A: return "a"
        JOY_BUTTON_B: return "b"
        JOY_BUTTON_X: return "x"
        JOY_BUTTON_Y: return "y"
        
  return "unknown"

func parse_text_tokens(raw_text: String) -> String:
  var final_text = raw_text
  
  if "{interact}" in final_text:
    final_text = final_text.replace("{interact}", get_action_bbcode("interact"))
    
  if "{run}" in final_text:
    final_text = final_text.replace("{run}", get_action_bbcode("run"))
  
  if "{cancel}" in final_text:
    final_text = final_text.replace("{cancel}", get_action_bbcode("cancel"))
    
  return final_text

func unlock_achievement(api_name: String) -> void:
  if not Steam.isSteamRunning():
    return
    
  var is_unlocked: Dictionary = Steam.getAchievement(api_name)
  
  if is_unlocked.has("achieved") and not is_unlocked["achieved"]:
    var success: bool = Steam.setAchievement(api_name)
    if success:
      Steam.storeStats()
      
    
