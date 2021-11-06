% Map select state
var map_select_select : int
var map_select_y : real
var map_select_song := ""

% Map select functions
body procedure GameState_MapSelect_Init()
	% Initialize map select
	map_select_select := 0
	map_select_y := SCREEN_HEIGHT
	
	% Set state
	game_state := GameState.MapSelect
end GameState_MapSelect_Init

procedure GameState_MapSelect_Update()
	% Change selection
	if key_menu_up.press then
		map_select_select -= 1
		if map_select_select < 0 then
			map_select_select := upper(map_index)
		end if
		if map_select_select > 0 and map_index(map_select_select).song ~= map_select_song then
			Music.PlayFileReturn(map_index(map_select_select).song)
			map_select_song := map_index(map_select_select).song
		end if
	end if
	if key_menu_down.press then
		map_select_select += 1
		if map_select_select > upper(map_index) then
			map_select_select := 0
		end if
		if map_select_select > 0 and map_index(map_select_select).song ~= map_select_song then
			Music.PlayFileReturn(map_index(map_select_select).song)
			map_select_song := map_index(map_select_select).song
		end if
	end if
	
	% Draw menu
	Draw.FillBox(0, 0, maxx, maxy, 1)
	
	map_select_y += ((maxy - 120 - (map_select_select * 24) - midy) - map_select_y) / 100.0
	
	var col : int
	if 0 = map_select_select then
		col := 52
	else
		col := 54
	end if
	Font.Draw("OPTIONS", 30, maxy - 120 - floor(map_select_y), font_regular, col)
	
	for i : 1 .. upper(map_index)
		if i = map_select_select then
			col := 52
		else
			col := 54
		end if
		var y := maxy - 120 - (i * 24) - floor(map_select_y)
		if y > -20 and y < maxy + 20 then
			var dwidth := Font.Width(map_index(i).name, font_regular) + 32
			var lscroll := -floor((Time.Elapsed() / 10) mod dwidth)
			for j : lscroll .. SCREEN_WIDTH by dwidth
				Font.Draw(map_index(i).name, j, y, font_regular, col)
			end for
		end if
	end for
	
	Font.Draw("turingmania", 50, maxy - 80, font_title, 53)
	
	% Select map
	if key_enter.press then
		if map_select_select > 0 then
			GameState_Play_Init(map_index(map_select_select).path, map_index(map_select_select).song)
		else
			GameState_Options_Init()
		end if
	end if
end GameState_MapSelect_Update
