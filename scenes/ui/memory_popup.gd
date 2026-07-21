class_name MemoryPopup
extends CanvasLayer

@onready var background_rect: TextureRect = $BackgroundRect
@onready var blur_rect: ColorRect = $BackgroundRect/BackBufferCopy/BlurRect
@onready var content_label: RichTextLabel = $BackgroundRect/BackBufferCopy/BlurRect/ContentLabel
@onready var input_label: TokenRichTextLabel = $BackgroundRect/BackBufferCopy/BlurRect/InputLabel



var is_active: bool = false

func _ready() -> void:
  background_rect.modulate.a = 0.0
  content_label.modulate.a = 0.0
  input_label.modulate.a = 0.0
  visible = false
  

func display_memory(text: String) -> void:
  content_label.text = text
  visible = true
  
  GameManager.pause()
  
  var tween = create_tween()
  tween.tween_property(background_rect, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
  tween.parallel().tween_property(blur_rect.material, "shader_parameter/blur_amount", 2.5, 0.6).set_trans(Tween.TRANS_SINE).set_delay(0.5)
  tween.parallel().tween_property(content_label, "modulate:a", 1.0, 0.6).set_delay(0.5)
  tween.parallel().tween_property(input_label, "modulate:a", 1.0, 0.3)
  tween.tween_callback(func():
    is_active = true
  )

func _input(event: InputEvent) -> void:
  if not is_active:
    return
    
  if event.is_action_pressed("interact"):
    close_memory()

func close_memory() -> void:
  is_active = false
  var tween = create_tween()
  tween.tween_property(background_rect, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
  await tween.finished
  blur_rect.material.set_shader_parameter("blur_amount", 0.0)
  visible = false
  GameManager.unpause()
