extends RefCounted
class_name Config

static var osc_receiver_host := "127.0.0.1"
static var osc_receiver_port := 57150
static var osc_listen_port := 57140
static var osc_enable_cursor_controller := true
static var osc_send_head_position := true

static var code_blocks_font_size := 32
static var code_blocks_padding_x := 18
static var code_blocks_padding_y := 10
static var code_blocks_oscillation_frequency := 1.5
static var code_blocks_flash_intensity := 0.4
static var code_blocks_flash_ramp_speed := 4
static var code_blocks_quantize_position := true


static var mouse_enable := true
static var mouse_speed := 2.0
static var mouse_viewport_modifier := 2.0

static var spout_enable := true
static var spout_name := "LifeCodes"

static var websocket_enable := true
static var websocket_base_url := "https://lc.alexandracardenas.com"
static var websocket_installation_path := "/ws/installation"
static var websocket_time_until_long_disconnect := 12
static var websocket_time_until_code_refresh := 60
static var websocket_time_until_loading_timeout := 15
static var websocket_time_until_lifebeat_timeout := 12
static var websocket_lifebeat_interval := 2
static var websocket_cursor_speed_modifier = 1.2

static var app_render_width := 5760
static var app_render_height := 1200
static var app_window_width := app_render_width/2
static var app_window_height := app_render_height/2
static var app_inactivity_time := 15.0
static var app_long_inactivity_time := 300.0
static var app_interaction_boundary_topleft := Vector2i(0, 0)
static var app_interaction_boundary_bottomright := Vector2i(app_render_width, app_render_height)
static var app_enable_displacers = true
static var app_displacement_speed := 20.0

static var debug_test_interaction_integrity := false
static var debug_verbose := false

static var grid_divisions_x = 40
static var grid_divisions_y = 10

# I hate, that there is so much manual stuff here, but I'd rather have things as
# members here and not have a look-up structure ... this is very finicky unfortunately!

static func _static_init():
	# let's have all the default values here
	var _config := ConfigFile.new()
	
	# we populate with defaults
	_config.set_value("osc", "receiver_host", osc_receiver_host)
	_config.set_value("osc", "receiver_port", osc_receiver_port)
	_config.set_value("osc", "listen_port", osc_listen_port)
	_config.set_value("osc", "enable_cursor_controller", osc_enable_cursor_controller)
	_config.set_value("osc", "send_head_position", osc_send_head_position)
	
	_config.set_value("code_blocks", "font_size", code_blocks_font_size)
	_config.set_value("code_blocks", "padding_x", code_blocks_padding_x)
	_config.set_value("code_blocks", "padding_y", code_blocks_padding_y)
	_config.set_value("code_blocks", "oscillation_frequency", code_blocks_oscillation_frequency)
	_config.set_value("code_blocks", "flash_intensity", code_blocks_flash_intensity)
	_config.set_value("code_blocks", "flash_ramp_speed", code_blocks_flash_ramp_speed)
	_config.set_value("code_blocks", "quantize_position", code_blocks_quantize_position)
	
	_config.set_value("mouse", "enable", mouse_enable)
	_config.set_value("mouse", "speed", mouse_speed)
	_config.set_value("mouse", "viewport_modifier", mouse_viewport_modifier)
	
	_config.set_value("spout", "enable", spout_enable)
	_config.set_value("spout", "name", spout_name)
	
	_config.set_value("websocket", "enable", websocket_enable)
	_config.set_value("websocket", "base_url", websocket_base_url)
	_config.set_value("websocket", "installation_path", websocket_installation_path)
	_config.set_value("websocket", "time_until_long_disconnect", websocket_time_until_long_disconnect)
	_config.set_value("websocket", "time_until_code_refresh", websocket_time_until_code_refresh)
	_config.set_value("websocket", "time_until_loading_timeout", websocket_time_until_loading_timeout)
	_config.set_value("websocket", "time_until_lifebeat_timeout", websocket_time_until_lifebeat_timeout)
	_config.set_value("websocket", "lifebeat_interval", websocket_lifebeat_interval)
	
	_config.set_value("websocket", "cursor_speed_modifier", websocket_cursor_speed_modifier)
	
	_config.set_value("app", "render_width", app_render_width)
	_config.set_value("app", "render_height", app_render_height)
	_config.set_value("app", "window_width", app_window_width)
	_config.set_value("app", "window_height", app_window_height)
	
	_config.set_value("app", "inactivity_time", app_inactivity_time)
	_config.set_value("app", "long_inactivity_time", app_long_inactivity_time)
		
	_config.set_value("app", "interaction_boundary_top", app_interaction_boundary_topleft.y)
	_config.set_value("app", "interaction_boundary_left", app_interaction_boundary_topleft.x)
	_config.set_value("app", "interaction_boundary_bottom", app_interaction_boundary_bottomright.y)
	_config.set_value("app", "interaction_boundary_right", app_interaction_boundary_bottomright.x)
	
	_config.set_value("app", "enable_displacers", app_enable_displacers)
	_config.set_value("app", "displacement_speed", app_displacement_speed)
	
	_config.set_value("debug", "test_interaction_integrity", debug_test_interaction_integrity)
	_config.set_value("debug", "verbose", debug_verbose)
	
	_config.set_value("grid", "divisions_x", grid_divisions_x)
	_config.set_value("grid", "divisions_y", grid_divisions_y)
	
		
	# load values on top
	_config.load("./lifecodes.ini")
	
	# save everything
	_config.save("./lifecodes.ini")
	
	# we apply all the values to the class
	osc_receiver_host = _config.get_value("osc", "receiver_host") as String
	osc_receiver_port = _config.get_value("osc", "receiver_port") as int
	osc_listen_port = _config.get_value("osc", "listen_port") as int
	osc_enable_cursor_controller = _config.get_value("osc", "enable_cursor_controller") as bool
	osc_send_head_position = _config.get_value("osc", "send_head_position") as bool
	
	code_blocks_font_size = _config.get_value("code_blocks", "font_size") as int
	code_blocks_padding_x = _config.get_value("code_blocks", "padding_x") as int
	code_blocks_padding_y = _config.get_value("code_blocks", "padding_y") as int
	code_blocks_oscillation_frequency = _config.get_value("code_blocks", "oscillation_frequency") as float
	code_blocks_flash_intensity = _config.get_value("code_blocks", "flash_intensity") as float
	code_blocks_flash_ramp_speed = _config.get_value("code_blocks", "flash_ramp_speed") as float
	code_blocks_quantize_position = _config.get_value("code_blocks", "quantize_position") as bool
	
	mouse_enable = _config.get_value("mouse", "enable") as bool
	mouse_speed = _config.get_value("mouse", "speed") as float
	mouse_viewport_modifier = _config.get_value("mouse", "viewport_modifier") as float
	
	spout_enable = _config.get_value("spout", "enable") as bool
	spout_name = _config.get_value("spout", "name") as String
	
	websocket_enable = _config.get_value("websocket", "enable") as bool
	websocket_base_url = _config.get_value("websocket", "base_url") as String
	websocket_installation_path = _config.get_value("websocket", "installation_path") as String
	websocket_time_until_long_disconnect = _config.get_value("websocket", "time_until_long_disconnect") as int
	websocket_time_until_code_refresh = _config.get_value("websocket", "time_until_code_refresh") as int
	websocket_time_until_loading_timeout = _config.get_value("websocket", "time_until_loading_timeout") as int
	websocket_time_until_lifebeat_timeout = _config.get_value("websocket", "time_until_lifebeat_timeout") as int
	websocket_lifebeat_interval = _config.get_value("websocket", "lifebeat_interval") as int
	websocket_cursor_speed_modifier = _config.get_value("websocket", "cursor_speed_modifier") as float
	
	app_render_width = _config.get_value("app", "render_width") as int
	app_render_height = _config.get_value("app", "render_height") as int	
	app_window_width = _config.get_value("app", "window_width") as int
	app_window_height = _config.get_value("app", "window_height") as int		
	app_inactivity_time = _config.get_value("app", "inactivity_time") as float
	app_long_inactivity_time = _config.get_value("app", "long_inactivity_time") as float
	app_enable_displacers = _config.get_value("app", "enable_displacers") as bool
	app_displacement_speed = _config.get_value("app", "displacement_speed") as float
	
	app_interaction_boundary_topleft = Vector2(
		_config.get_value("app", "interaction_boundary_left") as int,
		_config.get_value("app", "interaction_boundary_top") as int,
	)
	
	app_interaction_boundary_bottomright = Vector2(
		_config.get_value("app", "interaction_boundary_right") as int,
		_config.get_value("app", "interaction_boundary_bottom") as int,
	)
	
	debug_test_interaction_integrity = _config.get_value("debug", "test_interaction_integrity") as bool
	debug_verbose = _config.get_value("debug", "verbose") as bool
	
	grid_divisions_x = _config.get_value("grid", "divisions_x")	as int
	grid_divisions_y = _config.get_value("grid", "divisions_y") as int

# real constants for things that should not be user-configurable

const Z_INDEX_CODE_BLOCK: int = 2000
const Z_INDEX_HOVERED_CODE_BLOCK: int = 2010
const Z_INDEX_QR_CODE: int = 1900
const Z_INDEX_GRABBED_OR_SNAPPED_CODE_BLOCK: int = 2400
const Z_INDEX_MOUSE_CURSOR: int = 2500

const COLLISION_LAYER_BLOCK: int = 25
const COLLISION_LAYER_TOP_CONNECTION: int = 26
const COLLISION_LAYER_BOTTOM_CONNECTION: int = 27
const COLLISION_LAYER_DISPLACEMENT: int = 30
