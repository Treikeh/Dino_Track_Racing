extends Control


signal menu_closed(menu: Control)

const TWEEN_DURATION: float = 0.5

@export var _title: Label
@export var _settings_panel: PanelContainer
@export var _button_display: Control

var _title_start_pos: Vector2
var _panel_start_pos: Vector2
var _button_dispaly_start_pos: Vector2


func _ready() -> void:
	_setup_audio_settings()
	_setup_video_settings()
	_setup_gameplay_settings()
	_setup_confirm_pop_up()
	
	_title_start_pos = _title.position
	_panel_start_pos = _settings_panel.position
	_button_dispaly_start_pos = _button_display.position
	
	_title.position.y = -_title.size.y
	_settings_panel.position.x = size.x
	_button_display.position.y = size.y


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
	
	if event.is_action_pressed("ui_defaults"):
		_on_defaults_button_pressed()


func _on_back_button_pressed() -> void:
	if !_are_new_and_old_settings_matching():
		_show_confirm_pop_up()
		return
	else:
		_close_settings_menu()


func _close_settings_menu() -> void:
	# Actually apply the settings when closing the menu. If the new settings aren't applied with ->
	# <- the apply button then the new settings are discarded
	SettingsManager.apply_audio_settings()
	SettingsManager.apply_video_settings()
	SettingsManager.apply_gameplay_settings()
	close_menu()


func open_menu() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()
	
	await get_tree().create_timer(TWEEN_DURATION / 2.0).timeout
	
	var title_tween: Tween = create_tween()
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.set_ease(Tween.EASE_OUT)
	title_tween.tween_property(_title, "position", _title_start_pos, TWEEN_DURATION)
	
	var panel_tween: Tween = create_tween()
	panel_tween.set_trans(Tween.TRANS_BACK)
	panel_tween.set_ease(Tween.EASE_OUT)
	panel_tween.tween_property(_settings_panel, "position", _panel_start_pos, TWEEN_DURATION)
	
	var button_dispaly_tween: Tween = create_tween()
	button_dispaly_tween.set_trans(Tween.TRANS_BACK)
	button_dispaly_tween.set_ease(Tween.EASE_OUT)
	button_dispaly_tween.tween_property(
			_button_display,
			"position",
			_button_dispaly_start_pos,
			TWEEN_DURATION
	)
	
	_confirm_pop_up.hide()
	_cpu_amount_slider.grab_focus()
	
	_update_audio_settings()
	_update_video_settings()
	_update_gameplay_settings()


func close_menu() -> void:
	var title_tween: Tween = create_tween()
	title_tween.set_trans(Tween.TRANS_BACK)
	title_tween.set_ease(Tween.EASE_IN)
	title_tween.tween_property(_title, "position:y", -_title.size.y, TWEEN_DURATION)
	
	var panel_tween: Tween = create_tween()
	panel_tween.set_trans(Tween.TRANS_BACK)
	panel_tween.set_ease(Tween.EASE_IN)
	panel_tween.tween_property(_settings_panel, "position:x", size.x, TWEEN_DURATION)
	
	var button_dispaly_tween: Tween = create_tween()
	button_dispaly_tween.set_trans(Tween.TRANS_BACK)
	button_dispaly_tween.tween_property(_button_display, "position:y", size.y, TWEEN_DURATION)
	
	await get_tree().create_timer(TWEEN_DURATION / 2.0).timeout
	
	menu_closed.emit(self)
	
	await get_tree().create_timer(TWEEN_DURATION).timeout
	
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_defaults_button_pressed() -> void:
	var defaults: Dictionary = SettingsManager.DEFAULTS
	_on_master_volume_changed(defaults.AUDIO.MASTER_VOLUME)
	_on_effects_volume_changed(defaults.AUDIO.EFFECTS_VOLUME)
	_on_music_volume_changed(defaults.AUDIO.MUSIC_VOLUME)
	_on_display_mode_changed(defaults.VIDEO.DISPLAY_MODE)
	_on_vsync_mode_changed(defaults.VIDEO.VSYNC_MODE)
	_on_fps_changed(defaults.VIDEO.MAX_FPS)
	_on_cpu_amount_changed(defaults.GAMEPLAY.CPU_AMOUNT)


func _on_apply_button_pressed() -> void:
	for setting: String in _new_audio_settings:
		SettingsManager.set_audio_setting(setting, _new_audio_settings[setting])
		
	for setting: String in _new_video_settings:
		SettingsManager.set_video_setting(setting, _new_video_settings[setting])
	
	for setting: String in _new_gameplay_settings:
		SettingsManager.set_gameplay_setting(setting, _new_gameplay_settings[setting])
	
	SettingsManager.save_settings()
	
	# Reset apply button
	_old_audio_settings = _new_audio_settings.duplicate()
	_old_video_settings = _new_video_settings.duplicate()
	_old_gameplay_settings = _new_gameplay_settings.duplicate()


func _are_new_and_old_settings_matching() -> bool:
	var audio: bool = _new_audio_settings == _old_audio_settings
	var video: bool = _new_video_settings == _old_video_settings
	var gameplay: bool = _new_gameplay_settings == _old_gameplay_settings
	var total: bool = video and audio and gameplay
	return total



#region Confirm pop up

@export_group("Confirm pop up")
@export var _confirm_pop_up: PanelContainer
@export var _save_button: Button
@export var _discard_button: Button

var _confirm_tween: Tween


func _setup_confirm_pop_up() -> void:
	_confirm_pop_up.hide()
	_save_button.pressed.connect(_on_save_button_pressed)
	_discard_button.pressed.connect(_on_discard_button_pressed)


func _show_confirm_pop_up() -> void:
	_confirm_pop_up.show()
	_save_button.grab_focus()
	
	if _confirm_tween:
		_confirm_tween.kill()
	
	_confirm_pop_up.pivot_offset = _confirm_pop_up.size / 2.0
	_confirm_pop_up.scale = Vector2.ZERO
	
	_confirm_tween = create_tween()
	_confirm_tween.set_ease(Tween.EASE_OUT)
	_confirm_tween.set_trans(Tween.TRANS_BACK)
	_confirm_tween.tween_property(_confirm_pop_up, "scale", Vector2.ONE, TWEEN_DURATION)


func _hide_confirm_pop_up() -> void:
	if _confirm_tween:
		_confirm_tween.kill()
	
	_confirm_pop_up.scale = Vector2.ONE
	
	_confirm_tween = create_tween()
	_confirm_tween.set_ease(Tween.EASE_IN)
	_confirm_tween.set_trans(Tween.TRANS_BACK)
	_confirm_tween.tween_property(_confirm_pop_up, "scale", Vector2.ZERO, TWEEN_DURATION)
	_confirm_tween.tween_callback(_confirm_pop_up.hide)


func _on_save_button_pressed() -> void:
	_on_apply_button_pressed()
	_hide_confirm_pop_up()
	_close_settings_menu()


func _on_discard_button_pressed() -> void:
	_hide_confirm_pop_up()
	_close_settings_menu()

#endregion



#region Audio settings

@export_group("Audio")
@export var _master_volume_slider: HSlider
@export var _master_volume_value: Label
@export var _effects_volume_slider: HSlider
@export var _effects_volume_value: Label
@export var _music_volume_slider: HSlider
@export var _music_volume_value: Label


# The settings when the menu is opened
var _old_audio_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var _new_audio_settings: Dictionary


func _setup_audio_settings() -> void:
	_update_audio_settings()
	
	# Master volume
	_master_volume_slider.value_changed.connect(_on_master_volume_changed)
	
	# Effects volume
	_effects_volume_slider.value_changed.connect(_on_effects_volume_changed)
	
	# Music
	_music_volume_slider.value_changed.connect(_on_music_volume_changed)


func _update_audio_settings() -> void:
	var audio_settings: Dictionary = SettingsManager.load_audio_settings()
	_old_audio_settings = audio_settings.duplicate()
	_new_audio_settings = audio_settings.duplicate()
	
	_master_volume_slider.value = audio_settings.master_volume
	_master_volume_value.text = str(audio_settings.master_volume)
	
	_effects_volume_slider.value = audio_settings.effects_volume
	_effects_volume_value.text = str(audio_settings.effects_volume)
	
	_music_volume_slider.value = audio_settings.music_volume
	_music_volume_value.text = str(audio_settings.music_volume)


func _on_master_volume_changed(value: float) -> void:
	_new_audio_settings.master_volume = value
	_master_volume_slider.value = value
	_master_volume_value.text = str(value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_effects_volume_changed(value: float) -> void:
	_new_audio_settings.effects_volume = value
	_effects_volume_slider.value = value
	_effects_volume_value.text = str(value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Effects"), value)


func _on_music_volume_changed(value: float) -> void:
	_new_audio_settings.music_volume = value
	_music_volume_slider.value = value
	_music_volume_value.text = str(value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)

#endregion



#region Video settings

@export_group("Video")
@export var _display_mode_options_button: OptionButton
@export var _vsync_mode_options_button: OptionButton
@export var _fps_slider: HSlider
@export var _fps_value: Label

# The settings when the menu is opened
var _old_video_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var _new_video_settings: Dictionary


func _setup_video_settings() -> void:
	_update_video_settings()
	# Display mode
	_display_mode_options_button.item_selected.connect(_on_display_mode_changed)
	#VSync
	_vsync_mode_options_button.item_selected.connect(_on_vsync_mode_changed)
	# Frame rate
	_fps_slider.value_changed.connect(_on_fps_changed)


func _update_video_settings() -> void:
	var video_settings: Dictionary = SettingsManager.load_video_settings()
	_old_video_settings = video_settings.duplicate()
	_new_video_settings = video_settings.duplicate()
	
	# Display mode
	_display_mode_options_button.selected = video_settings.display_mode
	
	#VSync
	_vsync_mode_options_button.selected = video_settings.vsync_mode
	
	# Frame rate
	var vsync_enabled: bool = _vsync_mode_options_button.selected == DisplayServer.VSYNC_ENABLED
	_fps_slider.editable = not vsync_enabled
	_fps_slider.value = video_settings.max_fps
	
	_fps_value.text = str(int(video_settings.max_fps))


func _on_display_mode_changed(index: int) -> void:
	_new_video_settings.display_mode = index
	SettingsManager.set_display_mode(index)


func _on_vsync_mode_changed(index: int) -> void:
	_new_video_settings.vsync_mode = index
	SettingsManager.set_vsync_mode(index as DisplayServer.VSyncMode)
	# Disable/Enable fps options if vsync is enabled
	if index == DisplayServer.VSYNC_ENABLED:
		_on_fps_changed(DisplayServer.screen_get_refresh_rate())
		_fps_slider.editable = false
	else:
		_fps_slider.editable = true


func _on_fps_changed(value: float) -> void:
	_new_video_settings.max_fps = value
	_fps_slider.value = value
	_fps_value.text = str(int(value))

#endregion


#region Gameplay

@export_group("Gameplay")
@export var _cpu_amount_slider: HSlider
@export var _cpu_amount_value: Label


var _old_gameplay_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var _new_gameplay_settings: Dictionary


func _setup_gameplay_settings() -> void:
	_update_gameplay_settings()
	# Cpu amount
	_cpu_amount_slider.value_changed.connect(_on_cpu_amount_changed)


func _update_gameplay_settings() -> void:
	var gameplay_settings: Dictionary = SettingsManager.load_gameplay_settings()
	_old_gameplay_settings = gameplay_settings.duplicate()
	_new_gameplay_settings = gameplay_settings.duplicate()
	
	# Cpu amount
	_cpu_amount_slider.value = gameplay_settings.cpu_amount
	_cpu_amount_value.text = str(gameplay_settings.cpu_amount)


func _on_cpu_amount_changed(value: float) -> void:
	_new_gameplay_settings.cpu_amount = int(value)
	_cpu_amount_slider.value = value
	_cpu_amount_value.text = str(int(value))

#endregion
