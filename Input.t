% Input state
type Input_Key:
	record
		held : boolean
		press : boolean
		release : boolean
	end record

var key_game_left  : Input_Key
var key_game_down  : Input_Key
var key_game_up    : Input_Key
var key_game_right : Input_Key

var key_menu_left  : Input_Key
var key_menu_down  : Input_Key
var key_menu_up    : Input_Key
var key_menu_right : Input_Key

var key_enter : Input_Key
var key_quit : Input_Key

key_game_left.held := false
key_game_down.held := false
key_game_up.held := false
key_game_right.held := false

key_menu_left.held := false
key_menu_down.held := false
key_menu_up.held := false
key_menu_right.held := false

key_enter.held := false
key_quit.held := false

% Input functions
procedure Input_UpdateKey(var key : Input_Key, held : boolean)
	if held and not key.held then
		key.press := true
	else
		key.press := false
	end if
	if key.held and not held then
		key.release := true
	else
		key.release := false
	end if
	key.held := held
end Input_UpdateKey

procedure Input_Update()
	% Get held keys
	var chars : array char of boolean
	Input.KeyDown(chars)
	
	% Update keys
	Input_UpdateKey(key_game_left,  chars('d'))
	Input_UpdateKey(key_game_down,  chars('f'))
	Input_UpdateKey(key_game_up,    chars('j'))
	Input_UpdateKey(key_game_right, chars('k'))
	
	Input_UpdateKey(key_menu_left,  chars(KEY_LEFT_ARROW))
	Input_UpdateKey(key_menu_down,  chars(KEY_DOWN_ARROW))
	Input_UpdateKey(key_menu_up,    chars(KEY_UP_ARROW))
	Input_UpdateKey(key_menu_right, chars(KEY_RIGHT_ARROW))
	
	Input_UpdateKey(key_enter, chars(KEY_ENTER))
	Input_UpdateKey(key_quit, chars(KEY_ESC))
end Input_Update
