# Clear screen, import functions and select tiername
clearinfo
include lib.praat

form Set the variables
	comment Name for the output tier(may already exist)
	sentence newtier align

	comment Select language
	optionmenu lang: 1
		option tze
		option spa

	comment Custom dictionary path
	boolean dictpath 0
	
	comment Use ruleset(name ruleset.lang)
	boolean ruleset 0

	comment Export the graph to pdf
	boolean pdf 0

	comment Temporary file directory
	sentence tmpdir /tmp/
endform
pdf$ = if pdf then "True" else "False" fi
dictpath$ = if dictpath then chooseReadFile$("Open the dictionary") else "" fi
ruleset$ = if ruleset then "ruleset.'lang$'" else "None" fi
basetmp$ = "praat_temp_out"
tmp$ = tmpdir$ + basetmp$

# Get selections and set variables
tg$ = selected$("TextGrid", 1)
snd$ = selected$("LongSound", 1)

select TextGrid 'tg$'
call getTierNumber 'newtier$' tiernumber

# If the tier is present use it otherwise create it
if tiernumber = -1
	tiernumber = 1
	Insert interval tier... 1 'newtier$'
endif

# Open editor and let the user select the intervals
oldstart = -1
oldend = -1
plus LongSound 'snd$'
Edit
editor TextGrid 'tg$'
	t$ = LongSound info
	sndpath$ = extractWord$(t$, "File name: ")
endeditor
while 1=1
	# If this is not the first time, reset the screen
	if oldstart <> -1
		select TextGrid 'tg$'
		plus LongSound 'snd$'
		Edit
		editor TextGrid 'tg$'
			Zoom... 'oldstart' 'oldend'
		endeditor
	endif

	# Grab the editor and get the data from the user
	editor TextGrid 'tg$'
		pause Select a new interval to align
		start = Get start of selection
		end = Get end of selection
		label$ = Get label of interval
		Move cursor to... 'start'
		t$ = Editor info
		oldstart = extractNumber(t$, "Window start:")
		oldend = extractNumber(t$, "Window end:")
		Close
	endeditor
	
	# Clean up old boundaries and prepare for alignment
	minus LongSound 'snd$'
	call removeBetween 'tiernumber' 'start' 'end'
	Insert boundary... 'tiernumber' 'start'
	Insert boundary... 'tiernumber' 'end'
	plus LongSound 'snd$'
		
	# Print to infowindow
	printline python aligner.py "'label$'" 'start' 'end' 'sndpath$' 'lang$' 'ruleset$' 'pdf$' - ./ 'dictpath$' > 'tmp$'
	system  python aligner.py "'label$'" 'start' 'end' 'sndpath$' 'lang$' 'ruleset$' 'pdf$' - ./ 'dictpath$' > 'tmp$'

	# Read the results
	Read Table from comma-separated file... 'tmp$'

	# Put the results in the textgrid
	rows = Get number of rows
	for i to rows
		select Table 'basetmp$'
		sstart$ = Get value... 'i' start
		send$ = Get value... 'i' end
		svalue$ = Get value... 'i' label
		select TextGrid 'tg$'
		Insert boundary... 'tiernumber' 'send$'
		intnum = Get interval at time... 'tiernumber' 'sstart$'+0.0001
		Set interval text... 'tiernumber' 'intnum' 'svalue$'
	endfor

	# Remove temp files and reselect the TextGrid and LongSound
	select Table 'basetmp$'
	Remove
	select TextGrid 'tg$'
	plus LongSound 'snd$'
endwhile
