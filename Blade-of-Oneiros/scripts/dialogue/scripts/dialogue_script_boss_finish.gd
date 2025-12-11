extends Resource

## Boss finish cutscene script

func run(orchestrator) -> void:
	orchestrator.clear_steps()
	orchestrator.set_speakers("swordsman_lvl2", "threeslimes")
	orchestrator.camera_switch_to("PostBossCutsceneCam")
	orchestrator.action("swordsman", "move", Vector2(8,336), 80.0, "up")
	orchestrator.fade_in(1.0)
	var chorus_voices = [
		{
			"text": "...",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "You hit hard...",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "Owie...",
			"color": Color(0.0, 0.345, 0.744, 1.0)  
		},
	]
	
	orchestrator.multi_voice_narrate(
		chorus_voices,
		{
			"size": 15
		}
	)
	orchestrator.speak("swordsman_lvl2", "Had enough?", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
	chorus_voices = [
		{
			"text": "...yeah...",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "You win for now....",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "I think I have a bone sticking out...",
			"color": Color(0.0, 0.345, 0.744, 1.0)  
		},
	]
	orchestrator.multi_voice_narrate(
		chorus_voices,
		{
			"size": 15
		}
	)
	orchestrator.fade_out(1.0)
	chorus_voices = [
		{
			"text": "Hold on, give us a second",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "Alright, up you go",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "Careful please ;~;",
			"color": Color(0.0, 0.345, 0.744, 1.0)  
		},
	]
	orchestrator.multi_voice_narrate(
		chorus_voices,
		{
			"size": 15
		}
	)
	orchestrator.npc_disappear("redslime", 0.0)
	orchestrator.npc_disappear("greenslime", 0.0)
	orchestrator.npc_disappear("blueslime", 0.0)
	orchestrator.npc_appear("threeslimes", 0.0)
	orchestrator.fade_in(1.0)
	orchestrator.speak("threeslimes", "Alright much better.", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
		"dimmer": 100})
	orchestrator.speak("threeslimes", "Well, congratulations! You beat our dungeon!", {
		"color": Color(0.617, 0.556, 0.0, 1.0),
		"size": 15,
		"dimmer": 100})
	orchestrator.speak("threeslimes", "Sorry if it isn't as long, we're still learning how to build them...", {
		"color": Color(0.538, 0.566, 0.445, 1.0),
		"size": 15,
		"dimmer": 100})
	orchestrator.speak("swordsman_lvl2", "No, don't worry about it! Honestly, that fight was pretty fun.", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
	orchestrator.speak("threeslimes", "Really...? You think so...?", {
		"color": Color(0.538, 0.566, 0.445, 1.0),
		"size": 15,
		"dimmer": 100})
	orchestrator.speak("swordsman_lvl2", "Yeah! It reminds me alot of my own dungeon game that I'm....making...", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
	orchestrator.speak("swordsman_lvl2", "...", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
	chorus_voices = [
		{
			"text": "What's the matter?",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "Are you alright? You're looking a bit pale.",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "BEEP BEEP BEEP BEEP BEEP BEEP BEEP",
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
	orchestrator.speak("swordsman_lvl2", "No I'm fine...I just realized something I think...", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
	chorus_voices = [
		{
			"text": "Oh? And whats that?",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "BEEP BEEP BEEP BEEP BEEP BEEP BEEP",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "BEEP BEEP BEEP BEEP BEEP BEEP BEEP",
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
	orchestrator.speak("swordsman_lvl2", "I think...I have something that I was supposed to do but...", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
	chorus_voices = [
		{
			"text": "BEEP BEEP BEEP BEEP BEEP BEEP BEEP",
			"color": Color(0.0, 0.286, 0.127, 1.0)  
		},
		{
			"text": "BEEP BEEP BEEP BEEP BEEP BEEP BEEP",
			"color": Color(0.527, 0.0, 0.14, 1.0) 
		},
		{
			"text": "BEEP BEEP BEEP BEEP BEEP BEEP BEEP",
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
	orchestrator.speak("swordsman_lvl2", "I just can't...remember...", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
	orchestrator.speak("swordsman_lvl2", "And can you guys PLEASE shut up for 5 seconds??? I'm trying to thi-", {
		"color": Color(0.0, 0.538, 0.158, 1.0) ,
		"size": 15,
	})
