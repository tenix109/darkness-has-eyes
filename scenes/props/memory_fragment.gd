extends Interactable

@onready var unique_id: String = owner.name + "_" + name

func _ready() -> void:
  if SaveManager.collected_fragment_ids.has(unique_id) or not SaveManager.memories_unlocked:
    queue_free()

func interact(_player: Player) -> void:
  SaveManager.collected_fragment_ids.append(unique_id)
  
  var current_count = SaveManager.unlocked_memories_count
  if current_count < SaveManager.memories_database.size():
    var current_lore = SaveManager.memories_database[current_count]
    GameManager.hud.show_memory(current_lore)
    
    SaveManager.collect_memory()
  
  queue_free()
