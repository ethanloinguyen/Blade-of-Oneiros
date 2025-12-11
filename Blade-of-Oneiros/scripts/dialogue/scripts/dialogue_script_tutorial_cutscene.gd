extends DialogueScriptBase

func run(orchestrator: DialogueOrchestrator) -> void:
	orchestrator.clear_steps()
	#orchestrator.set_speakers("swordsman_lvl1", "oldmansmiles")
#
	#orchestrator.fade_out(0.0) 
	#
	#orchestrator.narrate("...", {
		#"color": Color(0.0, 0.741, 0.346, 1.0),
		#"size": 15,
	#})
#
	##orchestrator.action("swordsman", "move", Vector2(pos.x - 60,pos.y), 140.0, "down")
	#orchestrator.action("swordsman", "move", Vector2(349.0,1228.0), 140.0, "down")
	#orchestrator.narrate("..?", {
		#"color": Color(0.0, 0.741, 0.346, 1.0),
		#"size": 15,
	#})
	#
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.narrate("Jeez it's cold, gotta close that stupid windo- AAAAA", {
		#"color": Color(0.0, 0.741, 0.346, 1.0),
		#"size": 15,
	#})
#
	#orchestrator.fade_in(1.0)
	#orchestrator.speak("swordsman_lvl1", "Owch..What the hell?? Where am I?!?", {
		#"color": Color(0.0, 0.741, 0.346, 1.0),
		#"size": 15,
	#})
	##orchestrator.wait(1.0)
	#orchestrator.action("swordsman", "move", Vector2(407.0,1228.0), 110.0, "right")
	#orchestrator.action("swordsman", "move", Vector2(407.0,1228.0), 110.0, "down")
	#var chorus_voices := [
		#{
			#"text": "Silly little creature...",
			#"color": Color(0.0, 0.286, 0.127, 1.0)  # soft blue
		#},
		#{
			#"text": "Ha! Look at how scared it is!",
			#"color": Color(0.527, 0.0, 0.14, 1.0)  # pink-ish
		#},
		#{
			#"text": "Ya! So scared! c:<",
			#"color": Color(0.0, 0.345, 0.744, 1.0)  # green-ish
		#},
	#]
#
	#orchestrator.multi_voice_narrate(
		#chorus_voices,
		#{
			#"size": 15
		#}
	#)
	#orchestrator.speak("swordsman_lvl1", "Who's there??? Show yourself, coward!!", {
		#"color": Color(0.0, 0.741, 0.346, 1.0),
		#"size": 15,
		#"dimmer": 100
	#})
	#
	#orchestrator.npc_moveto("oldmansmiles", Vector2(427.0,1218.0))
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.npc_appear("oldmansmiles", 0.8)
	#
	#orchestrator.speak("oldmansmiles", "My my my, what temperment!", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15,
		#"dimmer": 100})
	#
	#orchestrator.action("swordsman", "move", Vector2(395.0,1228.0), 110.0, "right")
	#orchestrator.speak("swordsman_lvl1", "Woah!", {
		#"color": Color(0.0, 0.741, 0.346, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "down")
	#chorus_voices = [
		#{
			#"text": "Fear not, traveler! I'm not here to hurt you",
			#"color": Color(0.617, 0.556, 0.0, 1.0)  
		#},
		#{
			#"text": "Yet.",
			#"color": Color(0.527, 0.0, 0.14, 1.0) 
		#},
		#{
			#"text": "",
			#"color": Color(0.0, 0.345, 0.744, 1.0)  
		#},
	#]
	#
	#orchestrator.multi_voice_speak(
		#"oldmansmiles",
		#chorus_voices,
		#{
			#"size": 15
		#}
	#)
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.speak("oldmansmiles", "I'm simply here to introduce to you my world, that's all!", {
		#"color": Color(0.617, 0.556, 0.0, 1.0) ,
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "down")
	#orchestrator.speak("swordsman_lvl1", "Wait...I've seen you somewhere before, but where-", {
		#"color": Color(0.0, 0.538, 0.158, 1.0),
		#"size": 15,
	#})
	#
#
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.speak("oldmansmiles", "DO NOT SPEAK UNLESS YOU ARE SPOKEN TO.", {
		#"color": Color(0.73, 0.491, 0.211, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "down")
	#orchestrator.speak("oldmansmiles", "*ahem* I am this world's dungeon master, and I have a task for you!", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "up")
	#orchestrator.speak("oldmansmiles", "You must explore my dungeon and I will let you free. If you fail, then I will turn you into a slime!", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.speak("oldmansmiles", "Do you accept?", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15,
	#})
	#orchestrator.speak("swordsman_lvl1", "Ok sure.", {
		#"color": Color(0.0, 0.538, 0.158, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "up")
	#orchestrator.speak("oldmansmiles", "Oh what a pit-", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.speak("oldmansmiles", "Wait really?", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15
	#})
	#orchestrator.speak("swordsman_lvl1", "Yeah, why not?", {
		#"color": Color(0.0, 0.538, 0.158, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_face("oldmansmiles", "up")
	#orchestrator.wait(0.50)
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.wait(0.50)
	#orchestrator.npc_face("oldmansmiles", "up")
	#orchestrator.wait(0.50)
	#orchestrator.npc_face("oldmansmiles", "right")
	#orchestrator.speak("oldmansmiles", "Ah okay cool.", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15,
	#})
	#orchestrator.speak("oldmansmiles", "Anyway. Look around and find a way out! I will see you soon!", {
		#"color": Color(0.617, 0.556, 0.0, 1.0),
		#"size": 15,
	#})
	#orchestrator.npc_moveto("oldmansmiles", Vector2(727.0,1218.0))
