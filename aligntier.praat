include procs.praat
	# Settings loads: phonetier_name$, wordtier_name$, cantier_name$, tmpfile$,
	# pythonex$, boundary_margin
	@loadSettings:

	# Load editor and longsound info: longsound_file$, longsound_object$,
	# textgrid_object$, selected_tier, longsound_duration, pitch_on,
	# intensity_on, spectrum_on, formant_on, pulses_on
	@loadFileInfo:

	# Extract the tier
	Extract entire selected tier
endeditor

# Select the tier and convert it to a table and write it to a file
extracted_tier$ = selected$("TextGrid", 1)
Down to Table: "no", 6, "yes", "no"
Save as tab-separated file: tmpfile$

# Remove all the created temporary objects
Remove
select TextGrid 'extracted_tier$'
Remove

# Write the tier specific settings
writeFileLine("isettings",
..."WAV: ", longsound_file$)

# Remove the tiers if they already exist
selectObject: textgrid_object$
number_of_tiers = Get number of tiers
tiernumber = 1
while tiernumber < number_of_tiers
    nametier$ = Get tier name: tiernumber
    if nametier$ = phonetier_name$ or nametier$ = wordtier_name$ or nametier$ = cantier_name$ or nametier$ = llhtier_name$
        Remove tier: tiernumber
    else
        tiernumber = tiernumber + 1
    endif
    number_of_tiers = Get number of tiers
endwhile

# Get the index the tiers
selectObject: textgrid_object$
@indexOfTier: phonetier_name$
phonetier_number = indexOfTier.number

@indexOfTier: llhtier_name$
llhtier_number = indexOfTier.number
if llhtier_number <> -1
	phonetier_number = phonetier_number + 1
endif

@indexOfTier: wordtier_name$
wordtier_number = indexOfTier.number
if wordtier_number <> -1
	phonetier_number = phonetier_number + 1
	llhtier_number = llhtier_number + 1
endif

@indexOfTier: cantier_name$
cantier_number = indexOfTier.number
if cantier_number <> -1
	phonetier_number = phonetier_number + 1
	wordtier_number = wordtier_number + 1
	llhtier_number = llhtier_number + 1
endif

# Do the actual alignment
system 'pythonex$' align.py tier

# Close the editor for more speed
editor: textgrid_object$
    Close
endeditor

# Read the results
@insertTableTextGrid: tmpfile$, textgrid_object$, phonetier_name$,
... wordtier_name$, cantier_name$, llhtier_name$, phonetier_number,
... wordtier_number, cantier_number, llhtier_number

# Reselect the TextGrid and re-open editor
selectObject: textgrid_object$
plusObject: longsound_object$
Edit
