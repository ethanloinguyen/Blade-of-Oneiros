extends CanvasLayer

# --- Node refs -------------------------------------------------------------

@onready var _label: Label = $Control/DialogueBG/MarginContainer/DialogueLabel
@onready var _bg: NinePatchRect = $Control/DialogueBG
@onready var _portrait_left: TextureRect = $Control/SpeakerPortraitLeft
@onready var _portrait_right: TextureRect = $Control/SpeakerPortraitRight
@onready var _dimmer: ColorRect = $Control/Dimmer

# Base positions (captured in _ready)
var _bg_base_pos: Vector2
var _portrait_left_base_pos: Vector2
var _portrait_right_base_pos: Vector2

# Label styling
var _settings: LabelSettings = LabelSettings.new()

# --- Highlight / focus controls --------------------------------------

@export var active_scale: Vector2 = Vector2(1.0, 1.0)
@export var inactive_scale: Vector2 = Vector2(0.9, 0.9)

@export var active_brightness: float = 1.0
@export var inactive_brightness: float = 0.5

# How far the inactive portrait nudges outward (in pixels)
@export var inactive_offset: float = 80.0

@export var highlight_duration: float = 0.2


# --- Exported style controls ----------------------------------------------

@export var font: Font
@export var font_size: int = 40
@export var font_color: Color = Color(0.13, 0.10, 0.07)
@export var outline_size: int = 0
@export var outline_color: Color = Color.BLACK
#@export var shadow_enabled: bool = true
#@export var shadow_color: Color = Color(0.0, 0.0, 0.0, 0.6)
#@export var shadow_offset: Vector2 = Vector2(2.0, 2.0)

# --- Animation controls ---------------------------------------------------

@export var dimmer_rise_duration: float = 0.25
@export var portrait_slide_duration: float = 0.30
@export var bg_fade_duration: float = 0.25
@export var anim_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var anim_ease: Tween.EaseType = Tween.EASE_OUT
@export var dialogue_shift_amount: float = 0.0

# Gradient shader target values (for version 1 shader)
@export var gradient_height_target: float = 0.4
@export var gradient_max_alpha_target: float = 0.6

# --- Conversation state ---------------------------------------------------
var _can_advance: bool = false
var _is_open: bool = false
var _lines: Array = []      # each element: { "text": String, "speaker": String, "overrides": Dictionary }
var _tweens: Array[Tween] = []
var _current_index: int = -1
var _current_speaker: String = ""
var _left_has_entered: bool = false
var _right_has_entered: bool = false
var _portrait_left_base_modulate: Color
var _portrait_right_base_modulate: Color

# --- Typing effect ---------------------------------------------------

@export var chars_per_second: float = 30.0

var _is_typing: bool = false
var _full_text: String = ""
var _visible_chars: int = 0
var _typing_accum: float = 0.0
var _intro_text: String = ""



# ======================================================================
# LIFECYCLE
# ======================================================================

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_process(true)

	_bg_base_pos = _bg.position
	_portrait_left_base_pos = _portrait_left.position
	_portrait_right_base_pos = _portrait_right.position

	_portrait_left_base_modulate = _portrait_left.modulate
	_portrait_right_base_modulate = _portrait_right.modulate



	_portrait_left.visible = false
	_portrait_right.visible = false
	_dimmer.visible = false

	# Label styling
	if font != null:
		_settings.font = font
	_settings.font_size = font_size
	_settings.font_color = font_color
	_settings.outline_size = outline_size
	_settings.outline_color = outline_color
	#_settings.shadow_color = shadow_color
	#if shadow_enabled:
		#_settings.shadow_offset = shadow_offset
	#else:
		#_settings.shadow_offset = Vector2.ZERO

	_label.label_settings = _settings
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.clip_text = false

	# Reset gradient shader parameters if present
	if _dimmer.material is ShaderMaterial:
		var sm: ShaderMaterial = _dimmer.material
		sm.set_shader_parameter("height_fraction", 0.0)
		sm.set_shader_parameter("max_alpha", 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if _is_open and _can_advance and event.is_action_pressed("advance"):
		if _is_typing:
			_finish_typing()
		else:
			_advance_or_close()
		get_viewport().set_input_as_handled()



func _make_tween() -> Tween:
	var t: Tween = create_tween()
	t.set_trans(anim_trans)
	t.set_ease(anim_ease)
	_tweens.append(t)
	return t

func _kill_all_tweens() -> void:
	for t in _tweens:
		if is_instance_valid(t):
			t.kill()
	_tweens.clear()



# ======================================================================
# PUBLIC API
# ======================================================================

# You can still use this for a single line if you want,
# but for multi-line back-and-forth, use start_conversation().
func open(text: String, overrides: Dictionary = {}) -> void:
	_apply_overrides(overrides)

	# Store the text for the intro line, but don't start typing yet.
	_intro_text = text
	_label.text = ""
	_is_typing = false
	_typing_accum = 0.0
	_visible_chars = 0
	_full_text = ""

	var speaker: String = ""
	if overrides.has("speaker"):
		speaker = String(overrides["speaker"])
	_current_speaker = speaker
	_show_speaker(speaker, overrides)

	visible = true
	_is_open = true

	_play_open_animation(speaker)
	get_tree().paused = true



# Preferred entry point for multi-line conversations.
# Each line: { "text": String, "speaker": String, "overrides": Dictionary }
func start_conversation(lines: Array) -> void:
	_can_advance = false  # block advance during intro
	_left_has_entered = false
	_right_has_entered = false
	if lines.is_empty():
		return

	_lines = lines
	_current_index = 0
	_open_first_line()


func close() -> void:
	_kill_all_tweens()

	visible = false
	_is_open = false
	get_tree().paused = false
	_dimmer.visible = false

	_lines.clear()
	_current_index = -1
	_current_speaker = ""
	_intro_text = ""

	_is_typing = false
	_typing_accum = 0.0
	_full_text = ""
	_visible_chars = 0
	_label.text = ""
	_can_advance = false

	# 🔽 add this
	DialogueOrchestrator.on_dialogue_finished()




func is_open() -> bool:
	return _is_open


# ======================================================================
# CONVERSATION FLOW
# ======================================================================

func _open_first_line() -> void:
	var line: Dictionary = _lines[_current_index]

	var text: String = line.get("text", "")
	var overrides: Dictionary = line.get("overrides", {})

	if line.has("speaker") and !overrides.has("speaker"):
		overrides["speaker"] = line["speaker"]

	var speaker: String = overrides.get("speaker", "")
	_current_speaker = speaker

	open(text, overrides)


func _advance_or_close() -> void:
	if _current_index >= 0 and _current_index < _lines.size() - 1:
		_current_index += 1
		var line: Dictionary = _lines[_current_index]
		_show_next_line(line)
	else:
		close()


func _show_next_line(line: Dictionary) -> void:
	var text: String = line.get("text", "")
	var overrides: Dictionary = line.get("overrides", {})

	if line.has("speaker") and !overrides.has("speaker"):
		overrides["speaker"] = line["speaker"]

	var new_speaker: String = overrides.get("speaker", "")

	_apply_overrides(overrides)
	_start_typing(text)

	_play_line_change_animation(_current_speaker, new_speaker, overrides)
	_current_speaker = new_speaker

	_can_advance = true


func _start_typing(text: String) -> void:
	_full_text = text
	_visible_chars = 0
	_typing_accum = 0.0
	_is_typing = true
	_label.text = ""


func _finish_typing() -> void:
	_is_typing = false
	_typing_accum = 0.0
	_visible_chars = _full_text.length()
	_label.text = _full_text



# ======================================================================
# SPEAKER / PORTRAIT HANDLING
# ======================================================================

func _show_speaker(speaker: String, overrides: Dictionary) -> void:
	var ph: int = -1
	if overrides.has("portrait_height"):
		ph = int(overrides["portrait_height"])

	var portrait_name: String = ""
	if overrides.has("portrait_name"):
		portrait_name = String(overrides["portrait_name"])

	if speaker == "player1":
		if portrait_name != "":
			_set_portrait(_portrait_left, portrait_name, ph)
		_portrait_left.visible = true
		if _portrait_right.texture != null:
			_portrait_right.visible = true

	elif speaker == "player2":
		if portrait_name != "":
			_set_portrait(_portrait_right, portrait_name, ph)
		_portrait_right.visible = true
		if _portrait_left.texture != null:
			_portrait_left.visible = true

	else:
		# No known side; hide both
		_portrait_left.visible = false
		_portrait_right.visible = false



func _set_portraits_initial_inactive_state() -> void:
	# Base inactive transforms for both portraits:
	# shrink, darken, step outward.
	var left_pos: Vector2 = _portrait_left_base_pos - Vector2(inactive_offset, 0.0)
	var right_pos: Vector2 = _portrait_right_base_pos + Vector2(inactive_offset, 0.0)

	_portrait_left.position = left_pos
	_portrait_right.position = right_pos

	_portrait_left.scale = inactive_scale
	_portrait_right.scale = inactive_scale

	var left_color: Color = _portrait_left_base_modulate
	left_color.r = clamp(left_color.r * inactive_brightness, 0.0, 1.0)
	left_color.g = clamp(left_color.g * inactive_brightness, 0.0, 1.0)
	left_color.b = clamp(left_color.b * inactive_brightness, 0.0, 1.0)
	_portrait_left.modulate = left_color

	var right_color: Color = _portrait_right_base_modulate
	right_color.r = clamp(right_color.r * inactive_brightness, 0.0, 1.0)
	right_color.g = clamp(right_color.g * inactive_brightness, 0.0, 1.0)
	right_color.b = clamp(right_color.b * inactive_brightness, 0.0, 1.0)
	_portrait_right.modulate = right_color



func _set_portrait(portrait: TextureRect, portrait_name: String, ph: int) -> void:
	if portrait_name == "":
		return

	var path: String = "res://assets/portraits/%s.png" % portrait_name
	var tex: Texture2D = load(path)
	if tex == null:
		push_warning("DialogUI: Could not load portrait at %s" % path)
		return

	portrait.texture = tex

	if ph > 0:
		portrait.custom_minimum_size.y = ph



# ======================================================================
# ANIMATION HELPERS
# ======================================================================

func _apply_highlight(active_speaker: String, tween: Tween, delay: float = 0.0) -> void:
	# Decide target scale / position / brightness for each side
	var left_target_scale: Vector2 = inactive_scale
	var right_target_scale: Vector2 = inactive_scale

	# Start at base positions
	var left_target_pos: Vector2 = _portrait_left_base_pos
	var right_target_pos: Vector2 = _portrait_right_base_pos

	var left_brightness: float = inactive_brightness
	var right_brightness: float = inactive_brightness

	# Inactive "step back" offset goes outward from center:
	# left speaker: outward = more to the left
	# right speaker: outward = more to the right
	left_target_pos.x = _portrait_left_base_pos.x - inactive_offset
	right_target_pos.x = _portrait_right_base_pos.x + inactive_offset

	# Active speaker overrides: full scale, full brightness, no offset
	if active_speaker == "player1":
		left_target_scale = active_scale
		left_target_pos = _portrait_left_base_pos
		left_brightness = active_brightness
	elif active_speaker == "player2":
		right_target_scale = active_scale
		right_target_pos = _portrait_right_base_pos
		right_brightness = active_brightness

	# Compute target colors from base modulate * brightness
	var left_color: Color = _portrait_left_base_modulate
	left_color.r = clamp(left_color.r * left_brightness, 0.0, 1.0)
	left_color.g = clamp(left_color.g * left_brightness, 0.0, 1.0)
	left_color.b = clamp(left_color.b * left_brightness, 0.0, 1.0)

	var right_color: Color = _portrait_right_base_modulate
	right_color.r = clamp(right_color.r * right_brightness, 0.0, 1.0)
	right_color.g = clamp(right_color.g * right_brightness, 0.0, 1.0)
	right_color.b = clamp(right_color.b * right_brightness, 0.0, 1.0)

	# Left portrait animation (if visible)
	if _portrait_left.visible:
		var lt_scale: PropertyTweener = tween.tween_property(
			_portrait_left,
			"scale",
			left_target_scale,
			highlight_duration
		)
		lt_scale.set_delay(delay)

		var lt_pos: PropertyTweener = tween.tween_property(
			_portrait_left,
			"position",
			left_target_pos,
			highlight_duration
		)
		lt_pos.set_delay(delay)

		var lt_color: PropertyTweener = tween.tween_property(
			_portrait_left,
			"modulate",
			left_color,
			highlight_duration
		)
		lt_color.set_delay(delay)

	# Right portrait animation (if visible)
	if _portrait_right.visible:
		var rt_scale: PropertyTweener = tween.tween_property(
			_portrait_right,
			"scale",
			right_target_scale,
			highlight_duration
		)
		rt_scale.set_delay(delay)

		var rt_pos: PropertyTweener = tween.tween_property(
			_portrait_right,
			"position",
			right_target_pos,
			highlight_duration
		)
		rt_pos.set_delay(delay)

		var rt_color: PropertyTweener = tween.tween_property(
			_portrait_right,
			"modulate",
			right_color,
			highlight_duration
		)
		rt_color.set_delay(delay)



func _play_open_animation(first_speaker: String) -> void:
	var tween: Tween = _make_tween()
	tween.set_parallel(true)


	# 1) Gradient rises
	_play_dimmer_open(tween)

	# 2) Put both portraits into their "inactive" pose immediately
	_set_portraits_initial_inactive_state()

	# --- Timing setup ---
	var left_delay: float = dimmer_rise_duration
	var right_delay: float = left_delay + portrait_slide_duration * 0.8

	# We want the box AFTER the second (right) portrait has fully finished sliding.
	var right_finish: float = right_delay + portrait_slide_duration
	var box_delay: float = right_finish + 0.05  # small extra pause so it feels intentional

	# 3) Both slide in from off-screen to their inactive pose
	_play_portrait_intro_both(tween, left_delay, right_delay)

	# 4) Dialogue box appears on the first speaker
	_play_dialogue_box_open(tween, first_speaker, box_delay)

	# 5) Active speaker steps up
	_apply_highlight(first_speaker, tween, box_delay)

	# 6) Start typing AND allow advancing only once box is visible
	var cb: CallbackTweener = tween.tween_callback(Callable(self, "_on_intro_box_ready"))
	cb.set_delay(box_delay)



func _on_intro_box_ready() -> void:
	if _intro_text != "":
		_start_typing(_intro_text)
	_can_advance = true


func _play_dimmer_open(tween: Tween) -> void:
	_dimmer.visible = true

	if _dimmer.material is ShaderMaterial:
		var sm: ShaderMaterial = _dimmer.material
		sm.set_shader_parameter("height_fraction", 0.0)
		sm.set_shader_parameter("max_alpha", 0.0)

		tween.tween_method(
			func(v: float) -> void:
				sm.set_shader_parameter("height_fraction", v),
			0.0,
			gradient_height_target,
			dimmer_rise_duration
		)

		tween.tween_method(
			func(v: float) -> void:
				sm.set_shader_parameter("max_alpha", v),
			0.0,
			gradient_max_alpha_target,
			dimmer_rise_duration
		)


func _play_portrait_intro_both(tween: Tween, left_delay: float, right_delay: float) -> void:
	# Left side (player1)
	if _portrait_left.visible and _portrait_left.texture != null:
		var end_left: Vector2 = _portrait_left.position   # current inactive position
		var start_left: Vector2 = end_left - Vector2(_portrait_left.size.x + 32.0, 0.0)
		_portrait_left.position = start_left

		var lt_pos: PropertyTweener = tween.tween_property(
			_portrait_left,
			"position",
			end_left,
			portrait_slide_duration
		)
		lt_pos.set_delay(left_delay)

	# Right side (player2)
	if _portrait_right.visible and _portrait_right.texture != null:
		var end_right: Vector2 = _portrait_right.position # current inactive position
		var start_right: Vector2 = end_right + Vector2(_portrait_right.size.x + 32.0, 0.0)
		_portrait_right.position = start_right

		var rt_pos: PropertyTweener = tween.tween_property(
			_portrait_right,
			"position",
			end_right,
			portrait_slide_duration
		)
		rt_pos.set_delay(right_delay)



func _play_dialogue_box_open(tween: Tween, speaker: String, delay: float = 0.0) -> void:
	var end_pos: Vector2 = _bg_base_pos
	if speaker == "player1":
		end_pos.x = 129   # your left-side position
	elif speaker == "player2":
		end_pos.x = 269   # your right-side position

	var start_pos: Vector2 = end_pos + Vector2(0.0, 8.0)
	_bg.position = start_pos

	var mod: Color = _bg.modulate
	mod.a = 0.0
	_bg.modulate = mod

	var pos_tweener = tween.tween_property(_bg, "position", end_pos, bg_fade_duration)
	pos_tweener.set_delay(delay)

	var alpha_tweener = tween.tween_property(_bg, "modulate:a", 1.0, bg_fade_duration)
	alpha_tweener.set_delay(delay)


# --- For advancing between lines (no gradient changes) ---------------------

func _play_line_change_animation(prev_speaker: String, new_speaker: String, overrides: Dictionary) -> void:
	var tween: Tween = _make_tween()
	tween.set_parallel(true)


	# Move the dialogue box to the new speaker
	_play_dialogue_box_shift_only(tween, new_speaker)

	# Update active vs inactive portraits
	_apply_highlight(new_speaker, tween)



func _play_portrait_line_change(tween: Tween, speaker: String) -> void:
	# Slide in the active speaker from their side ONLY the first time.
	if speaker == "player1" and !_left_has_entered and _portrait_left.visible and _portrait_left.texture != null:
		var start_left: Vector2 = _portrait_left_base_pos - Vector2(_portrait_left.size.x + 32.0, 0.0)
		_portrait_left.position = start_left
		tween.tween_property(_portrait_left, "position", _portrait_left_base_pos, portrait_slide_duration)
		_left_has_entered = true

	elif speaker == "player2" and !_right_has_entered and _portrait_right.visible and _portrait_right.texture != null:
		var start_right: Vector2 = _portrait_right_base_pos + Vector2(_portrait_right.size.x + 32.0, 0.0)
		_portrait_right.position = start_right
		tween.tween_property(_portrait_right, "position", _portrait_right_base_pos, portrait_slide_duration)
		_right_has_entered = true





func _play_dialogue_box_shift_only(tween: Tween, speaker: String) -> void:
	var target: Vector2 = _bg_base_pos

	if speaker == "player1":
		target.x = 129
	elif speaker == "player2":
		target.x = 369

	tween.tween_property(_bg, "position", target, bg_fade_duration)


# ======================================================================
# LABEL STYLE OVERRIDES
# ======================================================================

func _apply_overrides(o: Dictionary) -> void:
	if o.has("font"):
		_settings.font = o["font"]
	if o.has("size"):
		_settings.font_size = int(o["size"])
	if o.has("color"):
		_settings.font_color = o["color"]
	if o.has("outline_size"):
		_settings.outline_size = int(o["outline_size"])
	if o.has("outline_color"):
		_settings.outline_color = o["outline_color"]
	#if o.has("shadow"):
		#var s : Dictionary = o["shadow"]
		#if s is Dictionary:
			#if s.has("color"):
				#_settings.shadow_color = s["color"]
			#if s.has("offset"):
				#_settings.shadow_offset = s["offset"]
		#elif !s:
			#_settings.shadow_offset = Vector2.ZERO

	_label.label_settings = _settings

func _process(delta: float) -> void:
	if _is_typing:
		# how many chars we should see now
		_typing_accum += delta * chars_per_second
		var target_visible: int = int(_typing_accum)

		if target_visible > _visible_chars:
			_visible_chars = min(target_visible, _full_text.length())
			_label.text = _full_text.substr(0, _visible_chars)

			if _visible_chars >= _full_text.length():
				_is_typing = false
				_typing_accum = 0.0
