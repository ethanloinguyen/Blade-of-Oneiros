extends DialogueScriptBase


func run(orchestrator):
	orchestrator.clear_steps()
	orchestrator.camera_switch_to("BossCutsceneCam")
	orchestrator.narrate("Boss camera active now...", {})
	orchestrator.camera_restore()
