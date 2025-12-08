extends Resource
class_name DialogueScriptBossIntro

## Boss intro cutscene script
## Used by DialogueOrchestrator with dialogue_id = "boss_fight"

func run(orchestrator) -> void:
	# Clear any leftover steps from previous dialogues / cutscenes
	orchestrator.clear_steps()

	# Left = player, Right = OldManSmiles (3 slimes in a trenchcoat)
	orchestrator.set_speakers("player", "oldmansmiles")

	# --- Phase 1: Camera + fade in ---
	# Trigger is played while the screen is black from the level transition.
	# We switch to the boss arena cutscene camera, then fade into the scene.
	orchestrator.camera_switch_to("BossCutsceneCam")
	orchestrator.fade_in(1.0)

	# If you want OldManSmiles to fade into view as well, uncomment this:
	# orchestrator.npc_appear(0.6)

	# --- Phase 2: OldManSmiles praise + setup ---
	orchestrator.speak("oldmansmiles", "You've made it this far. Good job.")

	# Turn toward the player; adjust direction as needed ("up", "down", "left", "right")
	orchestrator.npc_face("left")

	orchestrator.speak("oldmansmiles", "Now I have something to show you.")

	# --- Phase 3: Trenchcoat reveal (3 slimes) ---
	# Reuse the generic "attack" action as a hook for the reveal animation.
	# In OldManSmiles.gd, implement play_attack_from_dialogue()/attack() to play the
	# 'three slimes in a trenchcoat' reveal.
	orchestrator.action("oldmansmiles", "attack")

	# Player reaction
	orchestrator.speak("player", "...")

	# Slimes confused that the player is not surprised
	orchestrator.speak("oldmansmiles", "Huh? You're... not surprised?")

	orchestrator.speak("player", "After everything I've seen, this barely cracks the top ten.")

	orchestrator.speak("oldmansmiles", "We spent so long perfecting this trenchcoat...")

	# --- Phase 4: “Real surprise” line + fade to black ---
	orchestrator.speak("oldmansmiles", "Fine. You know what? Here's the real surprise.")

	# Fade the whole screen to black
	orchestrator.fade_out(0.8)

	# Line over a fully black screen – ominous final warning before the fight
	orchestrator.narrate("We're the last obstacle in your way.")

	# --- Phase 5: Return to gameplay ---
	# While still black, restore the original gameplay camera.
	# If you want a dedicated gameplay camera here, make sure that was the active camera
	# before this cutscene started so camera_restore() has something to go back to.
	orchestrator.camera_restore()

	# Fade back into the arena with the normal gameplay camera active.
	orchestrator.fade_in(0.8)

	# At this point, DialogueOrchestrator will run out of steps and call _finish_dialogue(),
	# which closes the DialogUI and restores the original camera.
	# Hook your boss activation / player control restore in your boss/player scripts:
	#  - e.g. in a signal listener for DialogueOrchestrator.on_dialogue_finished()
