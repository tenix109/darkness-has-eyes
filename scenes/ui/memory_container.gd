extends HBoxContainer

@export var index: int = 0

@onready var title_label: RichTextLabel = $TitleLabel
@onready var content_label: RichTextLabel = $ContentLabel

func _ready() -> void:
  title_label.text = "Memory %s" % (index + 1)
  if SaveManager.collected_fragment_ids.size() >= index + 1:
    content_label.text = SaveManager.memories_database[index]
