extends HBoxContainer

@export var index: int = 0

@onready var title_label: RichTextLabel = $TitleLabel
@onready var content_label: RichTextLabel = $ContentLabel

var memory_set_index: int = 0

func _ready() -> void:
  title_label.text = "Memory %s" % (index + 1)
  if SaveManager.collected_fragment_ids.size() >= index + 1:
    content_label.text = SaveManager.MEMORY_SETS[memory_set_index].entries[index]
