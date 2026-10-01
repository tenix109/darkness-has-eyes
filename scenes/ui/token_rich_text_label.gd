class_name TokenRichTextLabel
extends RichTextLabel

var current_raw_text: String = ""



func _ready():
  GameManager.device_changed.connect(_on_device_changed)
  current_raw_text = text
  _update_text_display()

func set_raw_text(raw_text: String) -> void:
  current_raw_text = raw_text
  _update_text_display()
  
  if not GameManager.device_changed.is_connected(_on_device_changed):
    GameManager.device_changed.connect(_on_device_changed)

func _update_text_display() -> void:
  text = GameManager.parse_text_tokens(current_raw_text)

func _on_device_changed(_new_device: String) -> void:
  _update_text_display()
