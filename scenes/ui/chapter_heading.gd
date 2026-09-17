class_name ChapterHeading extends HBoxContainer

@export var memory_containers: Array[MemoryContainer]
@export var focused_scroll: FocusedScrollContainer

@onready var chapter_label: RichTextLabel = $ChapterLabel
@onready var left_label: RichTextLabel = $LeftLabel
@onready var right_label: RichTextLabel = $RightLabel

var memory_set_index: int = 0

func _ready() -> void:
  SaveManager.unlocked_memories_counts[0] = 1
  SaveManager.unlocked_memories_counts[1] = 3
  SaveManager.unlocked_memories_counts[2] = -1
  left_label.text = ""
  right_label.text = ""

func refresh_memories_screen():
  var title: String = SaveManager.MEMORY_SETS[memory_set_index].title
  chapter_label.text = title
  
  if memory_set_index > 0:
    left_label.text = "<"
  else:
    left_label.text = ""
  if ia_next_chapter_available(memory_set_index + 1):
    right_label.text = ">"
  else:
    right_label.text = ""
  
  focused_scroll.hide()
  focused_scroll.show()
  
  for row in memory_containers:
    row.refresh(memory_set_index)

func ia_next_chapter_available(next_index: int) -> bool:
  return next_index >= 0 and next_index < SaveManager.unlocked_memories_counts.size() and SaveManager.unlocked_memories_counts[next_index] > -1
  
func can_go_to_chapter(direction: int) -> bool:
  return ia_next_chapter_available(memory_set_index + direction)

func next_chapter(direction: int) -> void:
  memory_set_index += direction
  refresh_memories_screen()
