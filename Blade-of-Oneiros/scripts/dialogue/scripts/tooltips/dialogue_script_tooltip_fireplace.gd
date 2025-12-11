extends Resource

func run(orchestrator):
	orchestrator.narrate(
		"This fire is cozy, maybe I should reset here...",
		{
			"color": Color(0.0, 0.0, 0.0, 1.0),
			"size": 15,
		}
	)
