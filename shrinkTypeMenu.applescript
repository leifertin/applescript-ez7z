--  shrinkTypeMenu.applescript
--  Created by Leif Heflin on Sat Aug 20 2005.

on choose menu item theObject
	if the name of theObject is "shrinkType" then
		toggleShrinkItems()
	end if
end choose menu item

on toggleShrinkItems()
	tell window "action_shrink"
		if ((title of current menu item of popup button "shrinkType") as string) is "tar" then
			--Split
			set visible of text field "split_text" to true
			set visible of text field "split_text2" to true
			set visible of text field "split_text3" to true
			set visible of button "split_check" to true
			--Password
			set visible of text field "pw1" to false
			set visible of text field "pw_input_shrink" to false
			set visible of button "pw_check_shrink" to false
			set state of button "pw_check_shrink" to 0
			set visible of text field "hideFileNames_label" to false
			set visible of button "hideFileNames_check" to false
			set visible of slider "levelslider" to false
			set visible of text field "levellabel1" to false
		else if ((title of current menu item of popup button "shrinkType") as string) is "gzip" then
			--Split
			set visible of text field "split_text" to true
			set visible of text field "split_text2" to true
			set visible of text field "split_text3" to true
			set visible of button "split_check" to true
			--Password
			set visible of text field "pw1" to false
			set visible of text field "pw_input_shrink" to false
			set visible of button "pw_check_shrink" to false
			set state of button "pw_check_shrink" to 0
			set visible of text field "hideFileNames_label" to false
			set visible of button "hideFileNames_check" to false
			set visible of slider "levelslider" to true
			set visible of text field "levellabel1" to true
		else if ((title of current menu item of popup button "shrinkType") as string) is "bzip2" then
			--Split
			set visible of text field "split_text" to false
			set visible of text field "split_text2" to false
			set visible of text field "split_text3" to false
			set visible of button "split_check" to false
			--Password
			set visible of text field "pw1" to false
			set visible of text field "pw_input_shrink" to false
			set visible of button "pw_check_shrink" to false
			set state of button "pw_check_shrink" to 0
			set visible of text field "hideFileNames_label" to false
			set visible of button "hideFileNames_check" to false
			set visible of slider "levelslider" to false
			set visible of text field "levellabel1" to false
		else
			--Split
			set visible of text field "split_text" to true
			set visible of text field "split_text2" to true
			set visible of text field "split_text3" to true
			set visible of button "split_check" to true
			--Password
			set visible of text field "levellabel1" to true
			set visible of slider "levelslider" to true
			set visible of text field "pw1" to true
			if state of button "pw_check_shrink" is 1 then
				set visible of text field "pw_input_shrink" to true
				if ((title of current menu item of popup button "shrinkType") as string) is "7z" then
					set visible of text field "hideFileNames_label" to true
					set visible of button "hideFileNames_check" to true
				else
					set visible of text field "hideFileNames_label" to false
					set visible of button "hideFileNames_check" to false
				end if
			end if
			set visible of button "pw_check_shrink" to true
		end if
	end tell
end toggleShrinkItems