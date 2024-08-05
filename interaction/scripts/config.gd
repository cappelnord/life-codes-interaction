extends Object
class_name Config

static var _config: ConfigFile

static var osc_receiver_host := "127.0.0.1"
static var osc_receiver_port := 57150
static var osc_listen_port := 57140
static var osc_enable_cursor_controller := true
static var osc_send_head_position := true

static var code_blocks_font_size := 28
static var code_blocks_padding_x := 18
static var code_blocks_padding_y := 8
static var code_blocks_oscillation_hz := 1.5
static var code_blocks_flash_intensity := 0.4
static var code_blocks_flash_ramp_speed := 4
static var code_blocks_quantize_position := true


static var mouse_enable := true
static var mouse_speed := 2.0
static var mouse_viewport_modifier := 2.0

static var spout_enable := true
static var spout_name := "LifeCodes"

static var websocket_base_url := "http://localhost:8000"
static var websocket_installation_path := "/ws/installation"
static var websocket_ms_until_long_disconnect := 10000

static var app_render_width := 5380
static var app_render_height := 1200
static var app_window_width := app_render_width/2
static var app_window_height := app_render_height/2


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
	_config.set_value("code_blocks", "oscillation_hz", code_blocks_oscillation_hz)
	_config.set_value("code_blocks", "flash_intensity", code_blocks_flash_intensity)
	_config.set_value("code_blocks", "flash_ramp_speed", code_blocks_flash_ramp_speed)
	_config.set_value("code_blocks", "quantize_position", code_blocks_quantize_position)
	
	_config.set_value("mouse", "enable", mouse_enable)
	_config.set_value("mouse", "speed", mouse_speed)
	_config.set_value("mouse", "viewport_modifier", mouse_viewport_modifier)
	
	_config.set_value("spout", "enable", spout_enable)
	_config.set_value("spout", "name", spout_name)
	
	_config.set_value("websocket", "base_url", websocket_base_url)
	_config.set_value("websocket", "installation_path", websocket_installation_path)
	_config.set_value("websocket", "ms_until_long_disconnect", websocket_ms_until_long_disconnect)
	
	_config.set_value("app", "render_width", app_render_width)
	_config.set_value("app", "render_height", app_render_height)
	_config.set_value("app", "window_width", app_window_width)
	_config.set_value("app", "window_height", app_window_height)
	
	
		
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
	code_blocks_oscillation_hz = _config.get_value("code_blocks", "oscillation_hz") as float
	code_blocks_flash_intensity = _config.get_value("code_blocks", "flash_intensity") as float
	code_blocks_flash_ramp_speed = _config.get_value("code_blocks", "flash_ramp_speed") as float
	code_blocks_quantize_position = _config.get_value("code_blocks", "quantize_position") as bool
	
	mouse_enable = _config.get_value("mouse", "enable") as bool
	mouse_speed = _config.get_value("mouse", "speed") as float
	mouse_viewport_modifier = _config.get_value("mouse", "viewport_modifier") as float
	
	spout_enable = _config.get_value("spout", "enable") as bool
	spout_name = _config.get_value("spout", "name") as String
	
	websocket_base_url = _config.get_value("websocket", "base_url") as String
	websocket_installation_path = _config.get_value("websocket", "installation_path") as String
	websocket_ms_until_long_disconnect = _config.get_value("websocket", "ms_until_long_disconnect") as int
	
	app_render_width = _config.get_value("app", "render_width") as int
	app_render_height = _config.get_value("app", "render_height") as int	
	app_window_width = _config.get_value("app", "window_width") as int
	app_window_height = _config.get_value("app", "window_height") as int		


# real constants for things that should not be user-configurable

const Z_INDEX_CODE_BLOCK: int = 2000
const Z_INDEX_HOVERED_CODE_BLOCK: int = 2010
const Z_INDEX_QR_CODE: int = 1900
const Z_INDEX_GRABBED_OR_SNAPPED_CODE_BLOCK: int = 2400
const Z_INDEX_MOUSE_CURSOR: int = 2500

const COLLISION_LAYER_BLOCK: int = 25
const COLLISION_LAYER_TOP_CONNECTION: int = 26
const COLLISION_LAYER_BOTTOM_CONNECTION: int = 27
