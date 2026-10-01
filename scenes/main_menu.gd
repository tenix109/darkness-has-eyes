extends Node2D

@onready var breadcrumbs_label: Label = $MainLayer/BreadcrumbsLabel
@onready var main_buttons: VBoxContainer = $MainLayer/MainButtons
@onready var chapter_select: VBoxContainer = $MainLayer/ChapterSelect
@onready var level_select: VBoxContainer = $MainLayer/LevelSelect
@onready var memories_screen: TextureRect = $MainLayer/MemoriesScreen
@onready var settings_menu: SettingsMenu = $MainLayer/SettingsMenu

@onready var play_button: Button = $MainLayer/MainButtons/PlayButton
@onready var memories_button: Button = $MainLayer/MainButtons/MemoriesButton
@onready var settings_button: Button = $MainLayer/MainButtons/SettingsButton
@onready var quit_button: Button = $MainLayer/MainButtons/QuitButton

@onready var chapter_heading: ChapterHeading = $MainLayer/MemoriesScreen/MarginContainer/VBoxContainer/HBoxChapter

@onready var chapter_buttons: Array[Button] = [
  $MainLayer/ChapterSelect/Chapter1Button,
  $MainLayer/ChapterSelect/Chapter2Button,
  $MainLayer/ChapterSelect/Chapter3Button,
  $MainLayer/ChapterSelect/Chapter4Button,
]
@onready var chapter_select_back_button: Button = $MainLayer/ChapterSelect/ChapterSelectBackButton

@onready var floor_buttons: Array[Button] = [
  $MainLayer/LevelSelect/Floor1Button,
  $MainLayer/LevelSelect/Floor2Button,
  $MainLayer/LevelSelect/Floor3Button,
]
@onready var level_select_back_button: Button = $MainLayer/LevelSelect/LevelSelectBackButton

@onready var splash_screen: ColorRect = $MainLayer/SplashScreen
@onready var ovani_player: OvaniPlayer = $OvaniPlayer

var splash_timer: SceneTreeTimer
var splash_tween: Tween
var is_skipping: bool = false
var level_buttons_connected: bool = false
var _bound_pressed: Dictionary = {}
var current_chapter_title: String = ""

const CHAPTERS := [
  {
    "title": "Chapter 1",
    "levels": [
      {"title": "Floor 1", "path": "res://scenes/levels/floor_1.tscn", "index": 0},
      {"title": "Floor 2", "path": "res://scenes/levels/floor_2.tscn", "index": 1},
      {"title": "Floor 3", "path": "res://scenes/levels/floor_3.tscn", "index": 2},
    ],
  },
  {
    "title": "Chapter 2",
    "levels": [
      {"title": "Floor 4", "path": "res://scenes/levels/floor_4.tscn", "index": 3},
      {"title": "Floor 5", "path": "res://scenes/levels/floor_5.tscn", "index": 4},
      {"title": "Floor 6", "path": "res://scenes/levels/floor_6.tscn", "index": 5},
    ],
  },
]

const GONG = preload("uid://iyw5breqiatr")

func _ready() -> void:
  settings_menu.toggle_fullscreen(SaveManager.is_fullscreen)
  
  play_button.pressed.connect(_on_play_button_pressed)
  memories_button.visible = SaveManager.memories_unlocked
  memories_button.pressed.connect(_on_memories_button_pressed)
  settings_button.pressed.connect(_on_settings_button_pressed)
  quit_button.pressed.connect(_on_quit_button_pressed)
  
  settings_menu.back_button.pressed.connect(_on_settings_back_button_pressed)
  chapter_select_back_button.pressed.connect(_on_chapter_select_back_button_pressed)
  level_select_back_button.pressed.connect(_on_level_select_back_button_pressed)
  
  Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
  AudioManager.hook_up_buttons(self)
  start_splash_timer()

func start_splash_timer() -> void:
  splash_screen.show()
  splash_timer = get_tree().create_timer(2.5)
  splash_timer.timeout.connect(_on_splash_timeout)
  ovani_player.FadeIntensity(0.5, 3.0)

func _on_splash_timeout() -> void:
  fade_out_splash()

func skip_splash() -> void:
  is_skipping = true
  if splash_timer:
    splash_timer.timeout.disconnect(_on_splash_timeout)
  fade_out_splash()
  ovani_player.FadeIntensity(0.5, 0.5)

func fade_out_splash() -> void:
  is_skipping = true
  splash_tween = create_tween()
  splash_tween.tween_property(splash_screen, "modulate:a", 0.0, 0.5)
  splash_tween.tween_callback(splash_screen.queue_free)
  ovani_player.FadeIntensity(1.0, 5.0)
  show_screen(main_buttons)
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
  if splash_screen and splash_screen.visible and not is_skipping:
    if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
      if event.is_pressed():
        skip_splash()
        get_viewport().set_input_as_handled()
        return
  if memories_screen.visible:
    if event.is_action_pressed("ui_left") and chapter_heading.can_go_to_chapter(-1):
      chapter_heading.next_chapter(-1)
      get_viewport().set_input_as_handled()
    if event.is_action_pressed("ui_right") and chapter_heading.can_go_to_chapter(1):
      chapter_heading.next_chapter(1)
      get_viewport().set_input_as_handled()
      
  if event.is_action_pressed("ui_cancel") and not main_buttons.visible:
    if settings_menu.visible:
      SaveManager.save_game()
      show_screen(main_buttons)
    elif level_select.visible:
      _on_level_select_back_button_pressed()
    else:
      show_screen(main_buttons)

func show_screen(screen_to_show: Control) -> void:
  main_buttons.visible = false
  chapter_select.visible = false
  level_select.visible = false
  settings_menu.visible = false
  memories_screen.visible = false
  
  screen_to_show.visible = true
  
  if screen_to_show == chapter_select:
    set_breadcrumb("Play")
  elif screen_to_show == level_select:
    set_breadcrumb("Play › " + current_chapter_title)
  elif screen_to_show == settings_menu:
    set_breadcrumb("Settings")
  else:
    set_breadcrumb("")
  
  for child in screen_to_show.get_children():
    if child is Control and not child.visible:
      continue
    if GameManager.find_and_grab_focus(child):
      break

func _on_play_button_pressed() -> void:
  var chapters := get_unlocked_chapters()
  if chapters.size() <= 1:
    open_chapter(chapters[0])
  else:
    AudioManager.play_sfx(AudioManager.ui_press_sound, 2.0, "SFX2")
    populate_select(chapter_buttons, chapters, open_chapter)
    show_screen(chapter_select)

func open_chapter(chapter: Dictionary) -> void:
  current_chapter_title = chapter.title
  var levels := get_unlocked_levels(chapter)
  if levels.size() <= 1:
    _on_level_button_pressed(levels[0].path)
  else:
    AudioManager.play_sfx(AudioManager.ui_press_sound, 2.0, "SFX2")
    populate_select(floor_buttons, levels, _on_level_entry_pressed)
    show_screen(level_select)

func populate_select(buttons: Array[Button], entries: Array, on_pressed: Callable) -> void:
  for i in buttons.size():
    var btn := buttons[i]
    if _bound_pressed.has(btn):
      btn.pressed.disconnect(_bound_pressed[btn])
      _bound_pressed.erase(btn)
    
    if i < entries.size():
      var bound := on_pressed.bind(entries[i])
      btn.text = entries[i].title
      btn.visible = true
      btn.pressed.connect(bound)
      _bound_pressed[btn] = bound
    else:
      btn.visible = false

func _on_level_entry_pressed(level: Dictionary) -> void:
  _on_level_button_pressed(level.path)

func _on_level_button_pressed(level_path: String) -> void:
  var active_screen: Control = main_buttons
  if chapter_select.visible:
    active_screen = chapter_select
  elif level_select.visible:
    active_screen = level_select
  
  for btn in active_screen.get_children():
    btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
  get_viewport().gui_release_focus()
  
  AudioManager.play_sfx(GONG, 4.0, "SFX2")
  GameManager.change_scene(level_path)

func _on_memories_button_pressed():
  chapter_heading.memory_set_index = 0
  chapter_heading.refresh_memories_screen()
  show_screen(memories_screen)
  
func _on_settings_button_pressed() -> void:
  show_screen(settings_menu)

func _on_quit_button_pressed() -> void:
  get_tree().quit()

func _on_chapter_select_back_button_pressed() -> void:
  show_screen(main_buttons)

func _on_level_select_back_button_pressed() -> void:
  var chapters := get_unlocked_chapters()
  if chapters.size() > 1:
    populate_select(chapter_buttons, chapters, open_chapter)
    show_screen(chapter_select)
  else:
    show_screen(main_buttons)

func _on_settings_back_button_pressed() -> void:
  SaveManager.save_game()
  show_screen(main_buttons)

func get_unlocked_chapters() -> Array:
  var unlocked: Array = []
  for chapter in CHAPTERS:
    if is_chapter_unlocked(chapter):
      unlocked.append(chapter)
  return unlocked

func is_chapter_unlocked(chapter: Dictionary) -> bool:
  return is_level_unlocked(chapter.levels[0].index)

func get_unlocked_levels(chapter: Dictionary) -> Array:
  var unlocked: Array = []
  for level in chapter.levels:
    if is_level_unlocked(level.index):
      unlocked.append(level)
  return unlocked

func is_level_unlocked(index: int) -> bool:
  return index <= SaveManager.highest_cleared_index + 1

func set_breadcrumb(text: String) -> void:
  breadcrumbs_label.text = text
  breadcrumbs_label.visible = not text.is_empty()
  
