class_name MemoryContainer extends HBoxContainer

@export var number: int = 1

@onready var title_label: RichTextLabel = $TitleLabel
@onready var content_label: RichTextLabel = $ContentLabel

var memory_set_index: int = 0

func _ready() -> void:
  title_label.text = "Memory %s" % (number)
  # refresh(memory_set_index)

func refresh(memory_set: int) -> void:
  memory_set_index = memory_set
  var count: int = SaveManager.unlocked_memories_counts[memory_set_index]
  var index: int = number - 1
  var entries: Array = SaveManager.MEMORY_SETS[memory_set_index].entries
  if index < count and index < entries.size():
    content_label.text = entries[index]
  else:
    content_label.text = "???"
