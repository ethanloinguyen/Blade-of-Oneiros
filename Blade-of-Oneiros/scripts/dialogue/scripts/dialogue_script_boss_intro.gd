extends Resource
class_name DialogueScriptBossIntro

## Boss intro cutscene script
## Used by DialogueOrchestrator with dialogue_id = "boss_fight"

func run(orchestrator) -> void:
	# Clear any leftover steps from previous dialogues / cutscenes
	orchestrator.clear_steps()
	orchestrator.set_speakers("swordsman_lvl2", "oldmansmiles")

	orchestrator.camera_switch_to("BossCutsceneCam")
	orchestrator.npc_appear("oldmansmiles", 0.0)

	orchestrator.fade_in(1.0)
	orchestrator.action("swordsman", "move", Vector2(8,309), 80.0, "up")
	orchestrator.speak("oldmansmiles", "You've finally made your way to the end of my dungeon, good job getting this far.", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
		"dimmer": 100})
	orchestrator.speak("oldmansmiles", "Unfortunately for you, there is one more challenge that awaits you...", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
		"dimmer": 100})
		
	orchestrator.npc_face("oldmansmiles", "down")
	orchestrator.npc_and_player_move(
		Vector2(8,260),  # NPC target
		Vector2(8,319),  # Player step back
		"down",
		"up",
		50
	)
	orchestrator.action("swordsman", "move", Vector2(8,320), 140.0, "up")
	orchestrator.npc_moveto("movethis", Vector2(-330.0,-18))
	orchestrator.speak("oldmansmiles", "Me.", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 22,
		"dimmer": 100})
		
	orchestrator.action("swordsman", "move", Vector2(8,325), 140.0, "up")

	orchestrator.speak("swordsman_lvl2", "I'm not afraid of you, old man!", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	
	
	orchestrator.speak("oldmansmiles", "Hahahaha, just you wait! I've got one more surprise up my sleeve!", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
		"dimmer": 100})
		
	orchestrator.speak("oldmansmiles", "You see, I'm not just any old man...", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
		"dimmer": 100})
	orchestrator.fade_out(1.0)
	orchestrator.set_speakers("swordsman_lvl2", "threeslimes")
	orchestrator.npc_disappear("oldmansmiles",0.0)
	orchestrator.npc_appear("threeslimes",0.0)
	orchestrator.speak("threeslimes", "In fact, I'm...", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
	})
	orchestrator.speak("swordsman_lvl2", "Wait why are youTAKINGOFFYOURCLOTH-", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	orchestrator.fade_in(1.0)
	var chorus_voices = [
		{
			"text": "THREE SLIMES...",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "...IN A...",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "...TRENCHCOAT! :D",
			"color": Color(0.0, 0.345, 0.744, 1.0)  
		},
	]
	
	orchestrator.multi_voice_speak(
		"threeslimes",
		chorus_voices,
		{
			"size": 15
		}
	)
	orchestrator.wait(1.0)
	orchestrator.speak("swordsman_lvl2", "Oh.", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	chorus_voices = [
		{
			"text": "...",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "uh....",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "whats the matter? :c",
			"color": Color(0.0, 0.345, 0.744, 1.0)  
		},
	]
	orchestrator.multi_voice_speak(
		"threeslimes",
		chorus_voices,
		{
			"size": 15
		}
	)
	orchestrator.speak("swordsman_lvl2", "Oh- uh- nothing, I just", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	orchestrator.speak("swordsman_lvl2", "Like, is that it?", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	chorus_voices = [
		{
			"text": "What do you MEAN is that it???",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "WE WORKED SO HARD ON THIS DISGUISE",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "wtf(rick) man :<",
			"color": Color(0.0, 0.345, 0.744, 1.0)  
		},
	]
	orchestrator.multi_voice_speak(
		"threeslimes",
		chorus_voices,
		{
			"size": 17
		}
	)
	orchestrator.speak("swordsman_lvl2", "No offense, but, is there really just 2 puzzles, an armory, and, like, a few slimes in this dungeon? Its kinda, idunno...", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 15,
	})
	orchestrator.speak("swordsman_lvl2", "Basic...?", {
		"color": Color(0.0, 0.741, 0.346, 1.0),
		"size": 12,
	})
	orchestrator.npc_moveto("movethis", Vector2(-280.0,514.0))
	chorus_voices = [
		{
			"text": "Yeah, you're going down.",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "LET ME AT HIM LET ME AT HIM LET ME AT HIM LET ME-",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": ";~; We pulled off 3 all nighters on this...",
			"color": Color(0.0, 0.345, 0.744, 1.0)  
		},
	]
	orchestrator.multi_voice_speak(
		"threeslimes",
		chorus_voices,
		{
			"size": 15
		}
	)
	orchestrator.fade_out(1.0)
	orchestrator.speak("threeslimes", "If you want a challenge, boy, we'll GIVE you a challenge. Prepare yourself!", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
		"dimmer": 100})
	orchestrator.camera_restore()
