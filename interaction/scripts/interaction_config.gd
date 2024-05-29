extends Object
class_name InteractionConfig

# Constants controlling the look
const CODE_BLOCK_FONT_SIZE: int = 34
const CODE_BLOCK_PADDING_X: int = 24
const CODE_BLOCK_PADDING_Y: int = 8

const CODE_BLOCK_OSCILLATON_PHI: float = 1.5 * TAU
const CODE_BLOCK_FLASH_RAMP_SPEED: float = 4
const CODE_BLOCK_FLASH_STRENGTH: float = 0.4

# Constants controling functionality
const Z_INDEX_CODE_BLOCK: int = 2000
const Z_INDEX_HOVERED_CODE_BLOCK: int = 2010
const Z_INDEX_QR_CODE: int = 1900
const Z_INDEX_GRABBED_OR_SNAPPED_CODE_BLOCK: int = 2400
const Z_INDEX_MOUSE_CURSOR: int = 2500

const COLLISION_LAYER_BLOCK: int = 25
const COLLISION_LAYER_TOP_CONNECTION: int = 26
const COLLISION_LAYER_BOTTOM_CONNECTION: int = 27

# Mouse Cursor Controller
const MOUSE_CURSOR_CONTROLLER_ENABLED: bool = true
const MOUSE_CURSOR_CONTROLLER_VIEWPORT_POSITION_MODIFIER: float = 2

# OSC
const OSC_SENDER_HOST = "127.0.0.1"
const OSC_SENDER_PORT = 57120
const OSC_RECEIVER_PORT = 57140

# OSC Cursor Contgroller
const OSC_CURSOR_CONTROLLER_ENABLED: bool = true

# Websockts

const WEBSOCKETS_MSEC_UNTIL_LONG_DISCONNECT = 10000
