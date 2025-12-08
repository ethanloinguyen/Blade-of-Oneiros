extends DialogueScriptBase

func run(orchestrator: DialogueOrchestrator) -> void:
	orchestrator.clear_steps()

	# Declare who stands where:
	# left = swordsman.png, right = shadowman.png
	orchestrator.set_speakers("swordsman_lvl2", "oldmansmiles")

	orchestrator.action("swordsman", "move", Vector2(264, 564), 140.0, "right")
	orchestrator.speak("swordsman_lvl2", "To the left", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	orchestrator.action("swordsman", "move", Vector2(284, 564), 140.0, "right")
	orchestrator.speak("swordsman_lvl2", "To the right now yall", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	orchestrator.action("swordsman", "move", Vector2(264, 564), 140.0, "down")
	orchestrator.speak("oldmansmiles", "What are you doing?", {
		"color": Color(0.827, 0.0, 0.298, 1.0),
		"size": 15,
	})

	orchestrator.speak("swordsman_lvl2", "...", {
		"color": Color(0.0, 0.538, 0.158, 1.0),
		"size": 15,
	})

	orchestrator.speak("oldmansmiles", "Wierdo.", {
		"color": Color(0.827, 0.0, 0.298, 1.0),
		"size": 13,
	})
