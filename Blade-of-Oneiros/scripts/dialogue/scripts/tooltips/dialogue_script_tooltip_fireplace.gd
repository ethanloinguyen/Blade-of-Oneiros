extends Resource

func run(orchestrator):
	orchestrator.narrate(
		"I think I see a button in here...",
		{
			"color": Color(0.0, 0.0, 0.0, 1.0),
			"size": 15,
		}
	)
