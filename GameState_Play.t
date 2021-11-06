% Play state
type Play_Note:
	record
		x : nat1
		time : int4
		timeend : int4
		hold : boolean
		hit : boolean
		miss : boolean
	end record
type Play_NoteDraw:
	record
		x : int
		sy : int
		ey : int
		hold : boolean
		miss : boolean
	end record
type Play_NoteSplash:
	record
		x : int
		y : int
		time : int
	end record

var play_note : flexible array 1 .. 0 of Play_Note
var play_notes : int
var play_note_i : int

var play_notedraw : flexible array 1 .. 0 of Play_NoteDraw
var play_notedraws : int

var play_notesplash : flexible array 1 .. 0 of Play_NoteSplash

var play_start : int
var play_time : int

var play_hold_left : int
var play_hold_down : int
var play_hold_up : int
var play_hold_right : int

var play_judge_time : int
var play_judge_str : string
var play_judge_col : int

var play_combo : int

var play_marvs : int
var play_perfs : int
var play_greas : int
var play_goods : int
var play_boos : int
var play_miss : int

var play_acc_hits : real
var play_acc_chks : int

const PLAY_SPLASH_T := 300

const PLAY_WIN_MARV := 25
const PLAY_WIN_PERF := 45
const PLAY_WIN_GREA := 80
const PLAY_WIN_GOOD := 120
const PLAY_WIN := 180

const PLAY_NOTERAD := floor(40 * SCREEN_HEIGHT / 720)
const PLAY_JUDGERAD := floor(90 * SCREEN_HEIGHT / 720)

const PLAY_NOTESPD := 0.5 * SCREEN_HEIGHT / 720

% Play functions
body procedure GameState_Play_Init(path : string, song : string)
	Music.PlayFileStop()
	
	% Open map file
	var fp : int
	open : fp, path, read
	assert(fp > 0)
	
	% Read notes
	play_notes := 0
	loop
		exit when eof(fp)
		play_notes += 1
		new play_note, play_notes
		read : fp, play_note(play_notes).x
		read : fp, play_note(play_notes).time
		read : fp, play_note(play_notes).timeend
		play_note(play_notes).hold := false
		play_note(play_notes).hit := false
		play_note(play_notes).miss := false
	end loop
	play_note_i := 1
	
	% Close map file
	close : fp
	
	% Initialize play state
	play_hold_left := -1
	play_hold_down := -1
	play_hold_up := -1
	play_hold_right := -1
	
	play_judge_time := 0
	play_judge_str := ""
	play_judge_col := 0
	
	play_combo := 0
	
	play_marvs := 0
	play_perfs := 0
	play_greas := 0
	play_goods := 0
	play_boos := 0
	play_miss := 0
	
	play_acc_hits := 0.0
	play_acc_chks := 0
	
	for i : 1 .. upper(play_notesplash)
		play_notesplash(i).time := Time.Elapsed() - PLAY_SPLASH_T
	end for
	
	% Start song
	var a := Time.Elapsed()
	Music.PlayFileReturn(song)
	var b := Time.Elapsed()
	
	play_start := Time.Elapsed() + opt_offset + (b - a)
	
	% Set game state
	game_state := GameState.Play
end GameState_Play_Init

procedure GameState_Play_Splash(x : nat1)
	if not opt_splashes then
		return
	end if
	
	% Get position
	var sx := midx + floor((x - 1.5) * PLAY_JUDGERAD)
	var sy := SCREEN_HEIGHT2 - PLAY_JUDGERAD
	
	% Allocate splash
	var j := upper(play_notesplash) + 1
	for decreasing i : upper(play_notesplash) .. 0
		if i = 0 then
			j := 1
			exit
		end if
		if Time.Elapsed() < (play_notesplash(i).time + PLAY_SPLASH_T) then
			exit
		else
			j := i
		end if
	end for
	
	new play_notesplash, j
	play_notesplash(j).x := sx
	play_notesplash(j).y := sy
	play_notesplash(j).time := Time.Elapsed()
end GameState_Play_Splash

function GameState_Play_Judge(x : nat1, time : int) : boolean
	% Get absolute time offset
	var ctime := time - play_time
	if ctime < 0 then
		ctime := -ctime
	end if
	
	% Set judgement
	if ctime > PLAY_WIN then
		play_judge_time := Time.Elapsed()
		play_judge_str := "MISS.."
		play_judge_col := gray
		play_combo := 0
		play_miss += 1
		play_acc_hits += 0.0
		play_acc_chks += 3
		result true
	elsif ctime > PLAY_WIN_GOOD then
		play_judge_time := Time.Elapsed()
		play_judge_str := "BOO"
		play_judge_col := blue
		play_combo := 0
		play_boos += 1
		play_acc_hits += 0.05
		play_acc_chks += 2
		result true
	elsif ctime > PLAY_WIN_GREA then
		play_judge_time := Time.Elapsed()
		play_judge_str := "GOOD"
		play_judge_col := yellow
		play_combo += 1
		play_goods += 1
		play_acc_hits += 0.3
		play_acc_chks += 1
		result false
	elsif ctime > PLAY_WIN_PERF then
		play_judge_time := Time.Elapsed()
		play_judge_str := "GREAT"
		play_judge_col := green
		play_combo += 1
		play_greas += 1
		play_acc_hits += 0.8
		play_acc_chks += 1
		result false
	elsif ctime > PLAY_WIN_MARV then
		play_judge_time := Time.Elapsed()
		play_judge_str := "PERFECT!"
		play_judge_col := cyan
		play_combo += 1
		play_perfs += 1
		play_acc_hits += 2.0
		play_acc_chks += 2
		GameState_Play_Splash(x)
		result false
	else
		play_judge_time := Time.Elapsed()
		play_judge_str := "MARVELLOUS!!"
		play_judge_col := purple
		play_combo += 1
		play_marvs += 1
		play_acc_hits += 3.0
		play_acc_chks += 3
		GameState_Play_Splash(x)
		result false
	end if
end GameState_Play_Judge

procedure GameState_Play_CheckRelease(var hold : int)
	if hold >= 0 and play_note(hold).hold then
		if GameState_Play_Judge(play_note(hold).x, play_note(hold).timeend) then
			play_note(hold).hold := false
			play_note(hold).miss := true
			if play_time > play_note(hold).timeend then
				play_note(hold).hit := true
			else
				play_note(hold).time := play_time
			end if
		else
			play_note(hold).hold := false
			play_note(hold).hit := true
		end if
		hold := -1
	end if
end GameState_Play_CheckRelease

procedure GameState_Play_CheckHit(x : nat1, var hold : int)
	GameState_Play_CheckRelease(hold)
	for i : play_note_i .. play_notes
		% Check if note can be hit
		if play_note(i).miss = false and play_note(i).hit = false and (play_note(i).time + PLAY_WIN) >= play_time then
			% Stop checking if out of hit window
			if (play_note(i).time - PLAY_WIN) > play_time then
				exit
			end if
			
			% Check if this is the requested hit
			if play_note(i).x = x then
				% Hit note
				if play_note(i).timeend > play_note(i).time then
					hold := i
					play_note(i).hold := true
				else
					play_note(i).hit := true
				end if
				if GameState_Play_Judge(play_note(i).x, play_note(i).time) then
					% nothing
				end if
				exit
			end if
		end if
	end for
end GameState_Play_CheckHit

function GameState_Play_GetY(time : int4) : int
	result floor((time - play_time) * PLAY_NOTESPD * opt_scrollspeed)
end GameState_Play_GetY

procedure GameState_Play_Update()
	% Clear screen
	Draw.FillBox(0, 0, maxx, maxy, black)
	
	% Get song position
	play_time := Time.Elapsed() - play_start
	
	if opt_botplay then
		% Bot hit notes
		for i : play_note_i .. play_notes
			if (play_note(i).time - PLAY_WIN) > play_time then
				exit
			end if
			if play_note(i).hold = false and play_note(i).hit = false and play_note(i).time <= play_time then
				case play_note(i).x of
					label 0:
						GameState_Play_CheckHit(0, play_hold_left)
					label 1:
						GameState_Play_CheckHit(1, play_hold_down)
					label 2:
						GameState_Play_CheckHit(2, play_hold_up)
					label 3:
						GameState_Play_CheckHit(3, play_hold_right)
				end case
			end if
		end for
		
		% Bot release holds
		if play_hold_left >= 0 and play_note(play_hold_left).timeend <= play_time then
			GameState_Play_CheckRelease(play_hold_left)
		end if
		if play_hold_down >= 0 and play_note(play_hold_down).timeend <= play_time then
			GameState_Play_CheckRelease(play_hold_down)
		end if
		if play_hold_up >= 0 and play_note(play_hold_up).timeend <= play_time then
			GameState_Play_CheckRelease(play_hold_up)
		end if
		if play_hold_right >= 0 and play_note(play_hold_right).timeend <= play_time then
			GameState_Play_CheckRelease(play_hold_right)
		end if
	else
		% Hit notes
		if key_game_left.press then
			GameState_Play_CheckHit(0, play_hold_left)
		end if
		if key_game_down.press then
			GameState_Play_CheckHit(1, play_hold_down)
		end if
		if key_game_up.press then
			GameState_Play_CheckHit(2, play_hold_up)
		end if
		if key_game_right.press then
			GameState_Play_CheckHit(3, play_hold_right)
		end if
		
		% Release holds
		if key_game_left.release then
			GameState_Play_CheckRelease(play_hold_left)
		end if
		if key_game_down.release then
			GameState_Play_CheckRelease(play_hold_down)
		end if
		if key_game_up.release then
			GameState_Play_CheckRelease(play_hold_up)
		end if
		if key_game_right.release then
			GameState_Play_CheckRelease(play_hold_right)
		end if
	end if
	
	% Handle notes
	play_notedraws := 0
	for i : play_note_i .. play_notes
		% Get positions
		var sy := GameState_Play_GetY(play_note(i).time)
		var ey := GameState_Play_GetY(play_note(i).timeend)
		
		if play_note(i).hold then
			% Check for miss and clip
			if (play_note(i).timeend + PLAY_WIN) < play_time then
				% Clip note start when gone off-screen
				if i = play_note_i and ey <= -(PLAY_JUDGERAD + PLAY_NOTERAD) then
					play_note_i += 1
				end if
				
				% Missed
				case play_note(i).x of
					label 0:
						GameState_Play_CheckRelease(play_hold_left)
					label 1:
						GameState_Play_CheckRelease(play_hold_down)
					label 2:
						GameState_Play_CheckRelease(play_hold_up)
					label 3:
						GameState_Play_CheckRelease(play_hold_right)
				end case
			else
				% Draw note
				play_notedraws += 1
				new play_notedraw, play_notedraws
				play_notedraw(play_notedraws).x := floor((play_note(i).x - 1.5) * PLAY_JUDGERAD)
				play_notedraw(play_notedraws).sy := sy
				play_notedraw(play_notedraws).ey := ey
				play_notedraw(play_notedraws).hold := true
				play_notedraw(play_notedraws).miss := play_note(i).miss
			end if
		elsif play_note(i).hit then
			% Clip note start when gone off-screen
			if i = play_note_i and (play_note(i).timeend + PLAY_WIN) < play_time and ey <= -PLAY_NOTERAD then
				play_note_i += 1
			end if
		else
			% Check for miss and clip
			if (play_note(i).time + PLAY_WIN) < play_time then
				% Clip note start when gone off-screen
				if i = play_note_i and ey <= -(PLAY_JUDGERAD + PLAY_NOTERAD) then
					play_note_i += 1
				end if
				
				% Miss if not missed yet
				if not play_note(i).miss then
					play_note(i).miss := true
					if GameState_Play_Judge(play_note(i).x, play_note(i).time) then
						% nothing
					end if
					if play_note(i).timeend > play_note(i).time and GameState_Play_Judge(play_note(i).x, play_note(i).time) then
						% nothing
					end if
				end if
			end if
			
			% Don't draw if off-screen
			if sy >= SCREEN_HEIGHT + PLAY_NOTERAD then
				exit
			end if
			
			% Draw note
			play_notedraws += 1
			new play_notedraw, play_notedraws
			play_notedraw(play_notedraws).x := floor((play_note(i).x - 1.5) * PLAY_JUDGERAD)
			play_notedraw(play_notedraws).sy := sy
			play_notedraw(play_notedraws).ey := ey
			play_notedraw(play_notedraws).hold := false
			play_notedraw(play_notedraws).miss := play_note(i).miss
		end if
	end for
	
	% Get scroll factors
	var scroll_a0 : int
	var scroll_a1 : int
	var scroll_mul : int
	
	if opt_downscroll then
		scroll_a0 := 0
		scroll_a1 := 180
		scroll_mul := -1
	else
		scroll_a0 := 180
		scroll_a1 := 0
		scroll_mul := 1
	end if
	
	% Draw splashes
	for i : 1 .. upper(play_notesplash)
		if Time.Elapsed() < (play_notesplash(i).time + PLAY_SPLASH_T) then
			var p : real := 1.0 - ((Time.Elapsed() - play_notesplash(i).time) / PLAY_SPLASH_T)
			var p2 : real := 1.0 - max(0, (Time.Elapsed() - play_notesplash(i).time) * 1.5 / PLAY_SPLASH_T - 0.5)
			var ro := floor(PLAY_NOTERAD * (2.0 - (p * p * p)))
			var ri := floor(PLAY_NOTERAD * (2.0 - (p2 * p2)))
			Draw.FillOval(play_notesplash(i).x, midy + play_notesplash(i).y * scroll_mul, ro, ro, white)
			Draw.FillOval(play_notesplash(i).x, midy + play_notesplash(i).y * scroll_mul, ri, ri, black)
		end if
	end for
	
	% Draw judgement line
	if (opt_botplay = false and key_game_left.held) or play_hold_left >= 0 then
		Draw.FillOval(midx + floor((0 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	else
		Draw.Oval    (midx + floor((0 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	end if
	if (opt_botplay = false and key_game_down.held) or play_hold_down >= 0 then
		Draw.FillOval(midx + floor((1 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	else
		Draw.Oval    (midx + floor((1 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	end if
	if (opt_botplay = false and key_game_up.held) or play_hold_up >= 0 then
		Draw.FillOval(midx + floor((2 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	else
		Draw.Oval    (midx + floor((2 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	end if
	if (opt_botplay = false and key_game_right.held) or play_hold_right >= 0 then
		Draw.FillOval(midx + floor((3 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	else
		Draw.Oval    (midx + floor((3 - 1.5) * PLAY_JUDGERAD), midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
	end if
	
	% Draw notes
	for i : 1 .. play_notedraws
		if play_notedraw(i).hold then
			if play_notedraw(i).ey > 0 then
				Draw.Arc(midx + play_notedraw(i).x, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, scroll_a0, scroll_a1, white)
				Draw.Line(midx + play_notedraw(i).x - PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, midx + play_notedraw(i).x - PLAY_NOTERAD, midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, white)
				Draw.Line(midx + play_notedraw(i).x + PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, midx + play_notedraw(i).x + PLAY_NOTERAD, midy + (SCREEN_HEIGHT2 - PLAY_JUDGERAD) * scroll_mul, white)
			end if
		elsif play_notedraw(i).miss then
			if play_notedraw(i).ey > play_notedraw(i).sy then
				Draw.Arc(midx + play_notedraw(i).x, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, scroll_a0, scroll_a1, 23)
				Draw.Line(midx + play_notedraw(i).x - PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).sy) * scroll_mul, midx + play_notedraw(i).x - PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, 23)
				Draw.Line(midx + play_notedraw(i).x + PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).sy) * scroll_mul, midx + play_notedraw(i).x + PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, 23)
			end if
			Draw.FillOval(midx + play_notedraw(i).x, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).sy) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, 23)
		else
			if play_notedraw(i).ey > play_notedraw(i).sy then
				Draw.Arc(midx + play_notedraw(i).x, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, scroll_a0, scroll_a1, white)
				Draw.Line(midx + play_notedraw(i).x - PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).sy) * scroll_mul, midx + play_notedraw(i).x - PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, white)
				Draw.Line(midx + play_notedraw(i).x + PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).sy) * scroll_mul, midx + play_notedraw(i).x + PLAY_NOTERAD, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).ey) * scroll_mul, white)
			end if
			Draw.FillOval(midx + play_notedraw(i).x, midy + ((SCREEN_HEIGHT2 - PLAY_JUDGERAD) - play_notedraw(i).sy) * scroll_mul, PLAY_NOTERAD, PLAY_NOTERAD, white)
		end if
	end for
	
	% Draw judgement
	if (play_judge_time + 500) >= Time.Elapsed() then
		var yoff := max(20 - floor((Time.Elapsed() - play_judge_time) / 10), 0)
		Font.Draw(play_judge_str, 20, midy + yoff, font_header, play_judge_col)
		Font.Draw(intstr(play_combo), 30, midy - 30 + yoff, font_regular, white)
	end if
	
	% Draw score
	if opt_botplay then
		Font.Draw("BOTPLAY", 30, midy + 240, font_header, white)
	end if
	Font.Draw("MARVELLOUS: " + intstr(play_marvs), 30, midy + 200, font_regular, white)
	Font.Draw("PERFECT: " + intstr(play_perfs), 30, midy + 180, font_regular, white)
	Font.Draw("GREAT: " + intstr(play_greas), 30, midy + 160, font_regular, white)
	Font.Draw("GOOD: " + intstr(play_goods), 30, midy + 140, font_regular, white)
	Font.Draw("BOO: " + intstr(play_boos), 30, midy + 100, font_regular, white)
	Font.Draw("MISS: " + intstr(play_miss), 30, midy + 80, font_regular, white)
	if play_acc_chks > 0 then
		Font.Draw("ACCURACY: " + realstr(round(play_acc_hits * 10000 / play_acc_chks) / 100, 0) + "%", 30, midy + 60, font_regular, white)
	end if
	
	% Return to menu when enter is pressed
	if key_enter.press then
		GameState_MapSelect_Init()
		game_state := GameState.MapSelect
	end if
end GameState_Play_Update
