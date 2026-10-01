extends Node

const SAVE_PATH = "user://save_data.cfg"
const SECURITY_KEY: String = "WalkInDarknessToSeeAGreatLight"

var music_volume: float = 0.5
var sfx_volume: float = 0.5
var is_fullscreen: bool = true

var memories_unlocked: bool = false
var unlocked_memories_counts: Array[int] = [-1, -1, -1, -1]
var collected_fragment_ids: Array[String] = []

var highest_cleared_index: int = -1

var searches_completed: int = 0
var uninterrupted_searches_completed: int = 0
var interrupted_searches_completed: int = 0

var repel_count: int = 0

const MEMORY_SETS: Array = [
  {
    "title": "Chapter 1",
    "entries": [
      "I woke up frightened. I can't get the images out of my head. Why is the hallway darker than usual?",
      "I didn't want to be alone. I needed someone to tell me everything would be alright. It was only a bad dream, right?",
      "I bumped into the desk. A loud piercing crash followed. My heart started pounding.",
      "Suddenly, a light burst into the room. An angry figure shadowed over me. Am I still dreaming?",
      "She yelled. I tried to explain, but fear froze me. I didn't mean to knock the lamp over.",
      "In a rush I was carried off. Back in my room again. Still in the dark. Is it darker in here now? This is worse.",
      "I felt more alone and no one was around to tell me everything would be alright. Will it be? I cried myself to sleep.",
      "The sunlight woke me. My head hurt and I was afraid to face her after last night. I still wanted comfort.",
      "Maybe she was just tired. Maybe she didn't mean to scare me. Maybe I scared her.",   
      "My bedroom door slowly swung open and her face filled the void. I forgot she smiled. I don't think she was mad. She was just my mom.\nNow that I remember, now that I understand, I can face this."
    ],
  },
  {
    "title": "Chapter 2",
    "entries": [
      "We packed up all our things to move far away. I hugged my best friend for the last time. Everything felt different; somewhat exciting, but mostly terrifying.",
      "The drive lasted long into the night. I slept some, but the car was full of boxes! I felt trapped in the backseat.",
      "My new bedroom was cluttered. Boxes full of all my favorite things were spread out across the room. I had my favorite Dolly in the car, but where did she run off to?",
      "There she was! On the high shelf next to my closet door. I tried to reach her, but it was too high for me. I went to find something sturdy to climb on.",
      "As I turned to look for something to climb on, I felt something bonk me on the head. It was Dolly! She hit me... and it wasn't funny.",
      "First, I left my best friend and hated every moment of it. And now my Dolly was angry with me, too.",
      "She laid there on the floor with her smile. It really wasn't funny what she did. I kicked her into the closet so I didn't have to see her smiling at me.",
      "In every room of the new house, I would find her again. I don't know what she was doing, but I didn't like it. I tried to get rid of her.",
      '"Hey, kiddo, found her in the garage," I heard my dad\'s voice. I turned to see him carrying Dolly. I ran and hid in my room.',
      "Dad said she missed me, he said he was sure she didn't mean to hurt me. I missed her, too, and I wanted to forget it all ever happened.",
    ]
  },
  {
    "title": "Chapter 3",
    "entries": [
      "Coming Holiday 2026",
    ]
  },
]

const searches_required = 30
const uninterrupted_searches_required = 10
const interrupted_searches_required = 15

const repels_required = 30

func _ready() -> void:
  load_game()
  #dump_save_plaintext()
  #encrypt_save_plaintext()
  
  
func save_game() -> void:
  var config = ConfigFile.new()
  
  config.set_value("Settings", "music_volume", music_volume)
  config.set_value("Settings", "sfx_volume", sfx_volume)
  config.set_value("Settings", "is_fullscreen", is_fullscreen)
  
  config.set_value("Progression", "highest_cleared_index", highest_cleared_index)
  config.set_value("Progression", "memories_unlocked", memories_unlocked)
  config.set_value("Progression", "unlocked_memories_counts", unlocked_memories_counts)
  config.set_value("Progression", "collected_fragment_ids", collected_fragment_ids)
  
  config.set_value("Progression", "uninterrupted_searches_completed", uninterrupted_searches_completed)
  config.set_value("Progression", "interrupted_searches_completed", interrupted_searches_completed)
  config.set_value("Progression", "searches_completed", searches_completed)
  config.set_value("Progression", "repel_count", repel_count)
  
  # config.save(SAVE_PATH)
  config.save_encrypted_pass(SAVE_PATH, SECURITY_KEY)

func dump_save_plaintext(from_path: String = "user://save_data_backup.cfg", to_path: String = "user://save_data_dump.cfg") -> void:
  var config = ConfigFile.new()
  var error = config.load_encrypted_pass(from_path, SECURITY_KEY)
  if error != OK:
    push_error("Dump failed: %s" % error)
    return
  config.save(to_path)
  print("Wrote plaintext to ", to_path)
  
func encrypt_save_plaintext(from_path: String = "user://save_data_dump.cfg", to_path: String = "user://save_data_reencrypted.cfg") -> void:
  var config = ConfigFile.new()
  var error = config.load(from_path)
  if error != OK:
    push_error("Encrypt failed: %s" % error)
    return
  config.save_encrypted_pass(to_path, SECURITY_KEY)
  print("Wrote encrypted to ", to_path)

func load_game() -> void:
  var config = ConfigFile.new()
  var error = config.load_encrypted_pass(SAVE_PATH, SECURITY_KEY)
    
  if error != OK:
    save_game()
    return
  
  music_volume = config.get_value("Settings", "music_volume", 1.0)
  sfx_volume = config.get_value("Settings", "sfx_volume", 1.0)
  is_fullscreen = config.get_value("Settings", "is_fullscreen", false)
  

  highest_cleared_index = config.get_value("Progression", "highest_cleared_index", -1)
  memories_unlocked = config.get_value("Progression", "memories_unlocked", false)
  var loaded_levels: Array = config.get_value("Progression", "unlocked_levels", [])
  var highest_unlocked := -1
  for i in loaded_levels.size():
    if loaded_levels[i]:
      highest_unlocked = i
  highest_cleared_index = maxi(highest_cleared_index, highest_unlocked - 1)
  var loaded_counts = config.get_value("Progression", "unlocked_memories_counts", [])
  if loaded_counts.is_empty():
    var old_count: int = config.get_value("Progression", "unlocked_memories_count", -1)
    # Alpha used 0 as "none collected", not "chapter unlocked".
    if old_count <= 0 and not memories_unlocked:
      old_count = -1
    unlocked_memories_counts[0] = old_count
  else:
    while loaded_counts.size() < unlocked_memories_counts.size():
      loaded_counts.append(-1)
    unlocked_memories_counts.assign(loaded_counts)

  collected_fragment_ids.assign(config.get_value("Progression", "collected_fragment_ids", []))

  var needs_save = heal_legacy_memory_unlock()
  
  searches_completed = config.get_value("Progression", "searches_completed", 0)
  uninterrupted_searches_completed = config.get_value("Progression", "uninterrupted_searches_completed", 0)
  interrupted_searches_completed = config.get_value("Progression", "interrupted_searches_completed", 0)
  
  repel_count = config.get_value("Progression", "repel_count", 0)
  
  apply_audio_settings()
  
  if needs_save:
    save_game()

func heal_legacy_memory_unlock() -> bool:
  var changed := false

  if highest_cleared_index >= 2:
    if not memories_unlocked:
      memories_unlocked = true
      changed = true
    if unlocked_memories_counts[0] < 0:
      unlocked_memories_counts[0] = 0
      changed = true

  if memories_unlocked and highest_cleared_index < 2:
    highest_cleared_index = 2
    changed = true

  var has_progress := not collected_fragment_ids.is_empty()
  for count in unlocked_memories_counts:
    if count > 0:
      has_progress = true
      break

  if has_progress and not memories_unlocked:
    memories_unlocked = true
    changed = true

  if not memories_unlocked:
    for i in unlocked_memories_counts.size():
      if unlocked_memories_counts[i] == 0:
        unlocked_memories_counts[i] = -1
        changed = true

  return changed

func apply_audio_settings() -> void:
  set_bus_volume("Music", music_volume)
  set_bus_volume("SFX", sfx_volume)
  set_bus_volume("SFX2", sfx_volume)

func set_bus_volume(bus_name: String, value: float) -> void:
  var bus_index = AudioServer.get_bus_index(bus_name)
  if bus_index != -1:
    AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
    AudioServer.set_bus_mute(bus_index, value <= 0.0)

func mark_cleared(index: int) -> void:
  highest_cleared_index = maxi(highest_cleared_index, index)
  save_game()

func unlock_chapter_memories(chapter_index: int):
  memories_unlocked = true
  unlocked_memories_counts[chapter_index] = 0
  save_game()

func collect_memory(index: int) -> void:
  if unlocked_memories_counts[index] < MEMORY_SETS[index].entries.size():
    unlocked_memories_counts[index] += 1
    save_game()
  GameManager.hud.update_memory_count(unlocked_memories_counts[index])

  if unlocked_memories_counts[index] >= 1:
    GameManager.unlock_achievement("ACH_FIRST_MEMORY")
  if unlocked_memories_counts[0] >= 10:
    GameManager.unlock_achievement("ACH_ALL_MEMORIES")
  if unlocked_memories_counts[1] >= 10:
    GameManager.unlock_achievement("ACH_CH2_MEMORIES")

func interrupted_Search_completed():
  interrupted_searches_completed += 1
  search_completed()
  
  if interrupted_searches_completed >= interrupted_searches_required:
    GameManager.unlock_achievement("ACH_INTERRUPTED")

func uninterrupted_Search_completed():
  uninterrupted_searches_completed += 1
  search_completed()
  
  if uninterrupted_searches_completed >= uninterrupted_searches_required:
    GameManager.unlock_achievement("ACH_UNITERRUPTED")
  
func search_completed():
  searches_completed += 1
  save_game()
  
  if searches_completed >= searches_required:
    GameManager.unlock_achievement("ACH_SEARCHES")


func handle_repel():
  repel_count += 1
  save_game()
  
  if repel_count >= repels_required:
    GameManager.unlock_achievement("ACH_REPEL")
