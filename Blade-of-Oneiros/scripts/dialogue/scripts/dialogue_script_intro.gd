extends DialogueScriptBase

func run(orchestrator: DialogueOrchestrator) -> void:
	orchestrator.clear_lines()

	# Declare who stands where:
	# left = swordsman.png, right = shadowman.png
	orchestrator.set_speakers("swordsman_lvl2", "shadowman")

	orchestrator.speak("swordsman_lvl2", "Yo check this out, the dialogue is in the debug map now!", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})

	orchestrator.speak("shadowman", "That's awesome! So surely this project is almost done, right?", {
		"color": Color(0.827, 0.0, 0.298, 1.0),
		"size": 15,
	})

	orchestrator.speak("swordsman_lvl2", "...", {
		"color": Color(0.0, 0.538, 0.158, 1.0),
		"size": 15,
	})

	orchestrator.speak("shadowman", "...right?", {
		"color": Color(0.827, 0.0, 0.298, 1.0),
		"size": 13,
	})
