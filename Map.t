% Map types
type Map_Indexed:
	record
		path : string
		name : string
		song : string
	end record

var map_index : flexible array 1 .. 0 of Map_Indexed

% Map functions
procedure Map_Index()
	% Open maps directory
	var dpath := Dir.Current + "/maps"
	var dp := Dir.Open(dpath)
	assert(dp > 0)
	
	% Iterate through maps
	loop
		% Get file name and check if is a valid directory
		var sname := Dir.Get(dp)
		exit when sname = ""
		if sname ~= "." and sname ~= ".." then
			var spath := dpath + "/" + sname
			if Dir.Exists(spath) then
				% Open map directory
				var sp := Dir.Open(spath)
				assert(sp > 0)
				
				% Iterate through files
				loop
					% Check if file is a .map file
					var mname := Dir.Get(sp)
					exit when mname = ""
					
					var mpath := spath + "/" + mname
					if (not Dir.Exists(mpath)) and length(mname) > 4 and mname(*-3 .. *) = ".map" then
						% Index map
						new map_index, upper(map_index) + 1
						map_index(upper(map_index)).path := mpath
						map_index(upper(map_index)).name := mname(1 .. *-4)
						map_index(upper(map_index)).song := spath + "/" + sname + ".mp3"
					end if
				end loop
				
				% Close map directory
				Dir.Close(sp)
			end if
		end if
	end loop
	
	% Close maps directory
	Dir.Close(dp)
end Map_Index
