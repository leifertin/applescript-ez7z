--  checkBoxes.applescript
--  Created by Leif Heflin on Sat Aug 20 2005.

on clicked theObject
	if the name of theObject is "multicoreCheck" then
		tell window "prefsWin"
			if the state of button "multicoreCheck" is 0 then
				set visible of text field "multithreadtxt" to false
				set visible of text field "numberOfThreads" to false
			else if the state of button "multicoreCheck" is 1 then
				set visible of text field "multithreadtxt" to true
				set visible of text field "numberOfThreads" to true
			end if
		end tell
	else if the name of theObject is "pw_check_expand" then
		if the state of theObject is 0 then
			set visible of text field "pw_input_expand" of window "action_expand" to false
		else if the state of theObject is 1 then
			set visible of text field "pw_input_expand" of window "action_expand" to true
		end if
	else if the name of theObject is "pw_check_shrink" then
		tell window "action_shrink"
			if the state of theObject is 0 then
				set visible of text field "pw_input_shrink" to false
				set visible of text field "hideFileNames_label" to false
				set visible of button "hideFileNames_check" to false
			else if the state of theObject is 1 then
				set visible of text field "pw_input_shrink" to true
				if ((title of current menu item of popup button "shrinkType") as string) is "7z" then
					set visible of text field "hideFileNames_label" to true
					set visible of button "hideFileNames_check" to true
				end if
			end if
		end tell
	else if the name of theObject is "split_check" then
		if the state of theObject is 0 then
			set visible of (text field "split_text" of window "action_shrink") to false
			set visible of (text field "split_text2" of window "action_shrink") to false
		else
			set visible of (text field "split_text" of window "action_shrink") to true
			set visible of (text field "split_text2" of window "action_shrink") to true
		end if
	end if
end clicked