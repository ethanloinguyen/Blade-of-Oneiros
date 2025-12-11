extends Resource

func run(orchestrator):
	# narrate once – tooltip flag is auto-added by orchestrator
	orchestrator.narrate(
		"Press [E] to interact.",
		{
			"color": Color(0.0, 0.0, 0.0, 1.0),
			"size": 15,
		}
	)
