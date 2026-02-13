extends Control


signal menu_closed(menu: Control)


#@onready var _apply_button: Button = %ApplyButton


func _ready() -> void:
	_setup_audio_settings()
	_setup_video_settings()
	_setup_gameplay_settings()
	_setup_confirm_pop_up()
	
	## Connect signals
	#_apply_button.pressed.connect(_on_apply_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
	
	if event.is_action_pressed("ui_defaults"):
		_on_defaults_button_pressed()


func _on_back_button_pressed() -> void:
	if !_are_new_and_old_settings_matching():
		_confirm_pop_up.show()
		_save_button.grab_focus()
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
	show()
	_confirm_pop_up.hide()
	process_mode = Node.PROCESS_MODE_INHERIT
	_display_mode_options_button.grab_focus()


func close_menu() -> void:
	hide()
	menu_closed.emit(self)
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_defaults_button_pressed() -> void:
	var defaults: Dictionary = SettingsManager.DEFAULTS
	_on_master_volume_changed(defaults.AUDIO.MASTER_VOLUME)
	_on_display_mode_changed(defaults.VIDEO.DISPLAY_MODE)
	_on_vsync_mode_changed(defaults.VIDEO.VSYNC_MODE)
	_on_fps_changed(defaults.VIDEO.MAX_FPS)


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
	#_apply_button.disabled = true


func _are_new_and_old_settings_matching() -> bool:
	var audio: bool = _new_audio_settings == _old_audio_settings
	var video: bool = _new_video_settings == _old_video_settings
	var gameplay: bool = _new_gameplay_settings == _old_gameplay_settings
	var total: bool = video and audio and gameplay
	print("Audio: %s, Video: %s, Gameplay: %s, Total: %s" % [audio, video, gameplay, total])
	return total



#region Confirm pop up

@export_group("Confirm pop up")
@export var _confirm_pop_up: PanelContainer
@export var _save_button: Button
@export var _discard_button: Button


func _setup_confirm_pop_up() -> void:
	_confirm_pop_up.hide()
	_save_button.pressed.connect(_on_save_button_pressed)
	_discard_button.pressed.connect(_on_discard_button_pressed)


func _on_save_button_pressed() -> void:
	_on_apply_button_pressed()
	_close_settings_menu()


func _on_discard_button_pressed() -> void:
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
	var audio_settings: Dictionary = SettingsManager.load_audio_settings()
	_old_audio_settings = audio_settings.duplicate()
	_new_audio_settings = audio_settings.duplicate()
	
	# Master volume
	_master_volume_slider.value = audio_settings.master_volume
	_master_volume_slider.value_changed.connect(_on_master_volume_changed)
	_master_volume_value.text = str(audio_settings.master_volume)
	
	# Effects volume
	_effects_volume_slider.value = audio_settings.effects_volume
	#_effects_volume_slider.value_changed.connect(_on_effects_volume_changed)
	_effects_volume_value.text = str(audio_settings.effects_volume)
	
	# Music
	_music_volume_slider.value = audio_settings.music_volume
	#_music_volume_slider.value_changed.connect(_on_music_volume_changed)
	_music_volume_value.text = str(audio_settings.music_volume)


func _on_master_volume_changed(value: float) -> void:
	_new_audio_settings.master_volume = value
	_master_volume_slider.value = value
	_master_volume_value.text = str(value)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
	
	# Disable the apply button if the new and old values aren't matching
	#_apply_button.disabled = _are_new_and_old_settings_matching()

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
	var video_settings: Dictionary = SettingsManager.load_video_settings()
	_old_video_settings = video_settings.duplicate()
	_new_video_settings = video_settings.duplicate()
	
	# Display mode
	_display_mode_options_button.selected = video_settings.display_mode
	_display_mode_options_button.item_selected.connect(_on_display_mode_changed)
	
	#VSync
	_vsync_mode_options_button.selected = video_settings.vsync_mode
	_vsync_mode_options_button.item_selected.connect(_on_vsync_mode_changed)
	
	# Frame rate
	var vsync_enabled: bool = _vsync_mode_options_button.selected == DisplayServer.VSYNC_ENABLED
	_fps_slider.editable = not vsync_enabled
	_fps_slider.value = video_settings.max_fps
	_fps_slider.value_changed.connect(_on_fps_changed)
	
	_fps_value.text = str(int(video_settings.max_fps))


func _on_display_mode_changed(index: int) -> void:
	_new_video_settings.display_mode = index
	SettingsManager.set_display_mode(index)
	
	# Disable the apply button if the new and old values aren't matching
	#_apply_button.disabled = _are_new_and_old_settings_matching()


func _on_vsync_mode_changed(index: int) -> void:
	_new_video_settings.vsync_mode = index
	SettingsManager.set_vsync_mode(index as DisplayServer.VSyncMode)
	# Disable/Enable fps options if vsync is enabled
	if index == DisplayServer.VSYNC_ENABLED:
		_on_fps_changed(DisplayServer.screen_get_refresh_rate())
		_fps_slider.editable = false
	else:
		_fps_slider.editable = true
	
	# Disable the apply button if the new and old values aren't matching
	#_apply_button.disabled = _are_new_and_old_settings_matching()


func _on_fps_changed(value: float) -> void:
	_new_video_settings.max_fps = value
	_fps_slider.value = value
	_fps_value.text = str(int(value))
	
	# Disable the apply button if the new and old values aren't matching
	#_apply_button.disabled = _are_new_and_old_settings_matching()

#endregion


@export_group("Gameplay")
@export var _allow_cpu_check_button: CheckButton
@export var _cpu_amount_slider: HSlider
@export var _cpu_amount_value: Label


var _old_gameplay_settings: Dictionary
# The settigns that are changed in the menu
# Is compared with the old settings to enable/disable the apply button or discard changes
var _new_gameplay_settings: Dictionary


func _setup_gameplay_settings() -> void:
	var gameplay_settings: Dictionary = SettingsManager.load_gameplay_settings()
	_old_gameplay_settings = gameplay_settings.duplicate()
	_new_gameplay_settings = gameplay_settings.duplicate()
	
	# Allow cpus
	var allow_cpus: bool = gameplay_settings.allow_cpus
	_allow_cpu_check_button.button_pressed = allow_cpus
	_allow_cpu_check_button.toggled.connect(_on_allow_cpus_check_button_toggled)
	
	# Cpu amount
	_cpu_amount_slider.value = gameplay_settings.min_car_amount
	_cpu_amount_value.text = str(gameplay_settings.min_car_amount)
	_cpu_amount_slider.value_changed.connect(_on_cpu_amount_slider_value_changed)
	
	_cpu_amount_slider.editable = allow_cpus


func _on_allow_cpus_check_button_toggled(toggled_on: bool) -> void:
	_new_gameplay_settings.allow_cpus = toggled_on
	_allow_cpu_check_button.button_pressed = toggled_on
	_cpu_amount_slider.editable = toggled_on


func _on_cpu_amount_slider_value_changed(value: float) -> void:
	_new_gameplay_settings.min_car_amount = int(value)
	_cpu_amount_slider.value = value
	_cpu_amount_value.text = str(int(value))
