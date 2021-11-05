% Window constants
const SCREEN_WIDTH := 960
const SCREEN_HEIGHT := 720
const midx := SCREEN_WIDTH div 2
const midy := SCREEN_HEIGHT div 2

% Open game fonts
var font_regular := Font.New("sans serif:16")
var font_header := Font.New("sans serif:26:bold")
var font_title := Font.New("sans serif:40:bold")

% Game modules
include "Render.t"
include "Input.t"
include "Map.t"

% Initialize game
Render_Init()

% Load game and maps
procedure DisplayLoad(act : string)
	Draw.FillBox(0, 0, maxx, maxy, 1)
	Font.Draw("turingmania", 50, midy, font_title, 53)
	Font.Draw(act, 50, midy - 38, font_header, 54)
	View.Update()
end DisplayLoad

% Index maps
DisplayLoad("Indexing maps")
Map_Index()

% Game options
const OPT_VER := 0
var opt_fp : int

var opt_offset := 0
var opt_botplay := false
var opt_downscroll := false
var opt_scrollspeed := 1.0

% Load options
open : opt_fp, "options.txt", get
if opt_fp >= 0 then
	var ver : int
	get : opt_fp, ver
	if ver = OPT_VER then
		get : opt_fp, opt_offset
		get : opt_fp, opt_botplay
		get : opt_fp, opt_downscroll
		get : opt_fp, opt_scrollspeed
	end if
	close : opt_fp
end if

% Game states
type GameState : enum(MapSelect, Options, Play)
var game_state : GameState

forward procedure GameState_MapSelect_Init()
forward procedure GameState_Options_Init()
forward procedure GameState_Play_Init(path : string, song : string)

include "GameState_MapSelect.t"
include "GameState_Options.t"
include "GameState_Play.t"

% Start game loop
var fps_tick := Time.Elapsed()
var fps_ticks := 0
var fps_ticksa := 0

GameState_MapSelect_Init()
game_state := GameState.MapSelect

loop
	% Update input
	Input_Update()
	exit when key_quit.press
	
	% Run game
	case game_state of
		label GameState.MapSelect:
			GameState_MapSelect_Update()
		label GameState.Options:
			GameState_Options_Update()
		label GameState.Play:
			GameState_Play_Update()
	end case
	
	% Draw FPS
	fps_ticks += 1
	if Time.Elapsed() >= fps_tick then
		fps_ticksa := fps_ticks * 10
		fps_ticks := 0
		fps_tick := Time.Elapsed() + 100
	end if
	Font.Draw("FPS: " + intstr(fps_ticksa), 30, 30, font_regular, white)
	
	% Update screen
	View.Update()
end loop

% Save options
open : opt_fp, "options.txt", put
if opt_fp >= 0 then
	put : opt_fp, OPT_VER
	put : opt_fp, opt_offset
	put : opt_fp, opt_botplay
	put : opt_fp, opt_downscroll
	put : opt_fp, opt_scrollspeed
	close : opt_fp
end if

% Deinitialize game
Music.PlayFileStop()
Music.SoundOff()
Render_Quit()
