class_name HUD
extends CanvasLayer

## Chapter 1 = 0, Chapter 2 = 1, etc.
@export var memory_set_index: int = 0

@onready var fuse_ui: Control = $VBoxContainer/FuseUI
@onready var fuse_count_label: Label = $VBoxContainer/FuseUI/FuseCountLabel
@onready var context_label: TokenRichTextLabel = $ContextLabel
@onready var toast_label: TokenRichTextLabel = $ToastLabel
@onready var intro_label: RichTextLabel = $IntroLabel
@onready var game_over_screen: GameOverScreen = $GameOverLayer/GameOverScreen
@onready var memory_popup: MemoryPopup = $MemoryPopup
@onready var memory_count_ui: Control = $VBoxContainer/MemoryCountUI
@onready var memeory_count_label: Label = $VBoxContainer/MemoryCountUI/MemeoryCountLabel

@onready var chapter_complete_layer: CanvasLayer = $ChapterCompleteLayer
@onready var chapter_complete_bg: ColorRect = $ChapterCompleteLayer/ChapterCompleteBG
@onready var chapter_complete_label: RichTextLabel = $ChapterCompleteLayer/ChapterCompleteBG/ChapterCompleteLabel
@onready var memory_fragments_label: RichTextLabel = $ChapterCompleteLayer/ChapterCompleteBG/MemoryFragmentsLabel
@onready var continue_label: TokenRichTextLabel = $ChapterCompleteLayer/ChapterCompleteBG/ContinueLabel

var in_chapter_complete: bool = false

func _ready() -> void:
  GameManager.hud = self
  fuse_ui.hide()
  update_memory_count(SaveManager.unlocked_memories_counts[memory_set_index])
  chapter_complete_layer.hide()
  context_label.hide()
  toast_label.hide()
  chapter_complete_label.hide()

func show_context_message(text: String):
  context_label.set_raw_text(text)
  context_label.show()

func hide_context_message():
    context_label.hide()

var toast_tween: Tween
func show_toast_message(text: String):
  if toast_tween and toast_tween.is_valid():
    toast_tween.kill()
  
  toast_label.set_raw_text(text)
  toast_label.show()
  toast_label.modulate.a = 1.0
  
  toast_tween = create_tween()
  
  toast_tween.tween_property(toast_label, "modulate:a", 0.0, 1.0).set_delay(2.0)
  toast_tween.tween_callback(func(): toast_label.hide())

func update_fuse_count(count: int):
  fuse_count_label.text = str(count)
  fuse_ui.visible = count > 0

func update_memory_count(count: int):
  memeory_count_label.text = "%d/%d" % [count, SaveManager.MEMORY_SETS[memory_set_index].entries.size()]
  memory_count_ui.visible = (count > 0 and count <= 9)

func display_level_title(floor_name: String, subtitle: String) -> void:
  intro_label.text = "[center][fade start=30 length=0]" + floor_name + "\n[font_size=36 ]" + subtitle + "[/font_size][/fade][/center]"
  intro_label.modulate.a = 1.0
  intro_label.visible = true

  await get_tree().create_timer(3.0, false).timeout

  var fade_tween = create_tween()
  
  fade_tween.tween_method(
    func(progress: float):
      var total_chars = intro_label.get_total_character_count()
      var current_start = int(total_chars * (1.0 - progress))
      var current_length = int(total_chars * progress)
      intro_label.text = "[center][fade start=" + str(current_start) + " length=" + str(current_length) + "]" + floor_name + "\n[font_size=36]" + subtitle + "[/font_size][/fade][/center]",
    0.0, 1.0, 1.5
  )
  
  fade_tween.parallel().tween_property(intro_label, "modulate:a", 0.0, 1.5)
  fade_tween.tween_callback(func(): intro_label.visible = false)

func show_memory(text: String):
  memory_popup.display_memory(text)

func chapter_complete(chapter_index: int):
  chapter_complete_layer.show()
  chapter_complete_bg.modulate.a = 0.0
  chapter_complete_label.show()
  
  chapter_complete_label.modulate.a = 0.0
  chapter_complete_label.show()
  
  var fade_tween = create_tween()
  await fade_tween.tween_property(chapter_complete_bg, "modulate:a", 1.0, 1.0).finished
      
  fade_tween = create_tween()
  await fade_tween.tween_property(chapter_complete_label, "modulate:a", 1.0, 1.0).finished
  
  if SaveManager.unlocked_memories_counts[chapter_index] < 0:
    SaveManager.unlock_chapter_memories(chapter_index)
    memory_fragments_label.modulate.a = 0.0
    memory_fragments_label.show()    
    fade_tween = create_tween()
    await fade_tween.tween_property(memory_fragments_label, "modulate:a", 1.0, 1.0).finished
    
  continue_label.show()
  in_chapter_complete = true
  
func _input(event: InputEvent) -> void:
  if in_chapter_complete and event.is_action_pressed("interact"):
    in_chapter_complete = false
    GameManager.next_level()
    get_viewport().set_input_as_handled()
    return
    
