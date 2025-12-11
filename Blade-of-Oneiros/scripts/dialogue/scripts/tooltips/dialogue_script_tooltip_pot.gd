extends Resource

func run(orchestrator):
	orchestrator.narrate(
		"These pots look breakable...",
		{
			"color": Color(0.0, 0.0, 0.0, 1.0),
			"size": 15,
		}
	)
