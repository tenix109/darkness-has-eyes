extends Interactable
## Chapter 1 = 0, Chapter 2 = 1, etc.
@export var memory_set_index: int = 0

@onready var unique_id: String = owner.name + "_" + name

func _ready() -> void:
  if SaveManager.collected_fragment_ids.has(unique_id) or not SaveManager.memories_unlocked:
    queue_free()

func interact(_player: Player) -> void:
  SaveManager.collected_fragment_ids.append(unique_id)
  
  var current_count = SaveManager.unlocked_memories_counts[memory_set_index]
  var entries: Array = SaveManager.MEMORY_SETS[memory_set_index].entries
  if current_count < entries.size():
    GameManager.hud.show_memory(entries[current_count])
    SaveManager.collect_memory(memory_set_index)
  
  queue_free()
