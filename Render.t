% Render state
var window_id : int

% Render functions
procedure Render_Init()
	% Open window
	window_id := Window.Open("offscreenonly,noecho,title:turingmania,position:middle;middle,nobuttonbar,graphics:"+intstr(SCREEN_WIDTH)+";"+intstr(SCREEN_HEIGHT))
end Render_Init

procedure Render_Quit()
	% Close window
	Window.Close(window_id)
end Render_Quit