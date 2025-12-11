extends Resource

func run(orchestrator):
	orchestrator.narrate(
		"Blocked. What am I missing?",
		{
			"color": Color(0.0, 0.0, 0.0, 1.0),
			"size": 15,
		}
	)
