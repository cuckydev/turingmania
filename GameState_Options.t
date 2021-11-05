% Options state
var options_select : int
var options_y : real

% Map select functions
body procedure GameState_Options_Init()
	% Initialize map select
	options_select := 1
	options_y := SCREEN_HEIGHT
	
	% Set state
	game_state := GameState.Options
end GameState_Options_Init

procedure GameState_Options_Update()
	% Change selection
	if key_menu_up.press then
		options_select -= 1
		if options_select < 1 then
			options_select := 5
		end if
	end if
	if key_menu_down.press then
		options_select += 1
		if options_select > 5 then
			options_select := 1
		end if
	end if
	
	% Draw menu
	Draw.FillBox(0, 0, maxx, maxy, 1)
	
	options_y += ((maxy - 90 - (options_select * 24) - midy)- floor(options_y)) / 100.0
	
	if options_select = 1 then
		if key_enter.press then
			GameState_MapSelect_Init()
		end if
		Font.Draw("MAP SELECT", 30, maxy - 90 - (1 * 24)- floor(options_y), font_regular, 52)
	else
		Font.Draw("MAP SELECT", 30, maxy - 90 - (1 * 24)- floor(options_y), font_regular, 54)
	end if
	
	if options_select = 2 then
		if key_game_left.press then
			opt_offset -= 1
		end if
		if key_menu_left.press then
			opt_offset -= 10
		end if
		if key_menu_right.press then
			opt_offset += 10
		end if
		if key_game_right.press then
			opt_offset += 1
		end if
		Font.Draw("OFFSET: " + intstr(opt_offset) + "ms", 30, maxy - 90 - (2 * 24)- floor(options_y), font_regular, 52)
	else
		Font.Draw("OFFSET: " + intstr(opt_offset) + "ms", 30, maxy - 90 - (2 * 24)- floor(options_y), font_regular, 54)
	end if
	
	if options_select = 3 then
		if key_menu_left.press or key_menu_right.press or key_enter.press then
			opt_downscroll := not opt_downscroll
		end if
		if opt_downscroll then
			Font.Draw("DOWNSCROLL", 30, maxy - 90 - (3 * 24)- floor(options_y), font_regular, 52)
		else
			Font.Draw("UPSCROLL", 30, maxy - 90 - (3 * 24)- floor(options_y), font_regular, 52)
		end if
	else
		if opt_downscroll then
			Font.Draw("DOWNSCROLL", 30, maxy - 90 - (3 * 24)- floor(options_y), font_regular, 54)
		else
			Font.Draw("UPSCROLL", 30, maxy - 90 - (3 * 24)- floor(options_y), font_regular, 54)
		end if
	end if
	
	if options_select = 4 then
		if key_menu_left.press or key_menu_right.press or key_enter.press then
			opt_botplay := not opt_botplay
		end if
		if opt_botplay then
			Font.Draw("BOTPLAY: ON", 30, maxy - 90 - (4 * 24)- floor(options_y), font_regular, 52)
		else
			Font.Draw("BOTPLAY: OFF", 30, maxy - 90 - (4 * 24)- floor(options_y), font_regular, 52)
		end if
	else
		if opt_botplay then
			Font.Draw("BOTPLAY: ON", 30, maxy - 90 - (4 * 24)- floor(options_y), font_regular, 54)
		else
			Font.Draw("BOTPLAY: OFF", 30, maxy - 90 - (4 * 24)- floor(options_y), font_regular, 54)
		end if
	end if
	
	if options_select = 5 then
		if key_game_left.press then
			opt_scrollspeed -= 0.5
		end if
		if key_menu_left.press then
			opt_scrollspeed -= 0.1
		end if
		if key_menu_right.press then
			opt_scrollspeed += 0.1
		end if
		if key_game_right.press then
			opt_scrollspeed += 0.5
		end if
		if opt_scrollspeed < 0.5 then
			opt_scrollspeed := 0.5
		end if
		if opt_scrollspeed > 5.0 then
			opt_scrollspeed := 5.0
		end if
		Font.Draw("SCROLL SPEED: " + realstr(opt_scrollspeed, 0), 30, maxy - 90 - (5 * 24)- floor(options_y), font_regular, 52)
	else
		Font.Draw("SCROLL SPEED: " + realstr(opt_scrollspeed, 0), 30, maxy - 90 - (5 * 24)- floor(options_y), font_regular, 54)
	end if
	
	Font.Draw("turingmania", 50, maxy - 80, font_title, 53)
	
end GameState_Options_Update
