    if not fileReadable("settings")
        exitScript("No settings file found, please run the setup first")
    endif
    settings$ = readFile$("settings")
    new$ = extractLine$(settings$, "NEW: ")
    wrd$ = extractLine$(settings$, "WRD: ")
    out$ = extractLine$(settings$, "OUT: ")

    start = Get starting point of interval
    end = Get end point of interval

    info$ = LongSound info
    wav$ = extractLine$(info$, "File name: ")
    utt$ = Get label of interval

    info$ = TextGrid info
    tg$ = extractLine$(info$, "Object name: ")
endeditor
select TextGrid 'tg$'
# get phonetier number
tiernum_p = -1
numtier = Get number of tiers
for i to numtier
    name$ = Get tier name... i
    if name$ == new$
        tiernum_p = i
    endif
endfor
if tiernum_p = -1
    Insert interval tier... 1 'new$'
    tiernum_p = 1
endif

# get word tier number
tiernum_w = -1
numtier = Get number of tiers
for i to numtier
    name$ = Get tier name... i
    if name$ == wrd$
        tiernum_w = i
    endif
endfor
if tiernum_w = -1
    Insert interval tier... 1 'wrd$'
    tiernum_w = 1
endif

editor TextGrid 'tg$'
# clean the phone tier
    curtier = -1
    repeat
        Select next tier
        info$ = Editor info
        curtier = extractNumber(info$, "Selected tier:")
    until tiernum_p = curtier
    Select... 'start' 'end'
include cleaninterval.praat

editor TextGrid 'tg$'
# clean the word tier
    curtier = -1
    repeat
        Select next tier
        info$ = Editor info
        curtier = extractNumber(info$, "Selected tier:")
    until tiernum_w = curtier
    Select... 'start' 'end'
include cleaninterval.praat
select TextGrid 'tg$'

dur = end - start
writeFileLine("isettings",
..."STA: ", start, newline$,
..."DUR: ", dur, newline$,
..."UTT: ", utt$, newline$,
..."WAV: ", wav$)
system python alignannotation.py

# Read the results
Read Table from comma-separated file... 'out$'

# Put the results in the textgrid
rows = Get number of rows
for i to rows
    select Table praat_temp_out
    sstart$ = Get value... 'i' start
    send$ = Get value... 'i' end
    svalue$ = Get value... 'i' label
    stype$ = Get value... 'i' type
    select TextGrid 'tg$'
    if stype$ = "p"
        nocheck Insert boundary... 'tiernum_p' 'sstart$'
        Insert boundary... 'tiernum_p' 'send$'
        intnum = Get interval at time... 'tiernum_p' 'sstart$'+0.0001
        Set interval text... 'tiernum_p' 'intnum' 'svalue$'
    elif stype$ = "w"
        nocheck Insert boundary... 'tiernum_w' 'sstart$'
        Insert boundary... 'tiernum_w' 'send$'
        intnum = Get interval at time... 'tiernum_w' 'sstart$'+0.0001
        Set interval text... 'tiernum_w' 'intnum' 'svalue$'
    endif
endfor

# Remove temp files and reselect the TextGrid and LongSound
select Table praat_temp_out
Remove