extends DialogueScriptBase

func run(orchestrator) -> void:
	# Clear previous conversation and configure speakers
	orchestrator.clear_lines()
	orchestrator.set_speakers("swordsman", "shadowman")

	# Move the player into position before he talks
	# Move swordsman to global position (400, 200) at speed 140 (optional)
	orchestrator.action("swordsman", "move", Vector2(400, 200), 140.0)

	# Make him face right
	orchestrator.action("swordsman", "face", "right")

	# First line
	orchestrator.speak("swordsman", "I finally found you...")

	# NPC responds
	orchestrator.speak("shadowman", "You are too late.")

	# Trigger an attack animation
	orchestrator.action("swordsman", "attack")
	orchestrator.speak("swordsman", "We'll see about that!")
