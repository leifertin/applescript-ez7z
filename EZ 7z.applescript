-- EZ 7z.applescript
--  Created by Leif Heflin on Sat Aug 20 2005.

global MyWindowToolbar, appsup, nl, currentNL, nlMasta, nllist, autoAdvance, defaultPassword, defaultCompressionLevel, splitArchiveMB, sameItemDir, dontRemoveInputItem, splitAmt, defaultOutputDir, outSize, shrinktype2, measurethisDirSize, useunRAR, updatePID, currentProcessString, currentPID, myOutputChoice, prefsFile, prefsfileR, removeThis, ver, enableMultithreading, numberofthreads, b, durl, update_output, currentAction
global checkFile, curOutFile, p7String, checkfileR, o, newO, dropKind, viewPassword, includeFile, pwd, viewResults, skipActionWindow, quitWhenDone, shrinkType, totalsizes, measurethisDir, inSize, deleteOriginal, myQuickLookTempDir, isQuickLook

on drop theObject drag info dragInfo
	set preferred type of pasteboard of dragInfo to "file names"
	set fileinfo to (contents of pasteboard of dragInfo)
	
	set nl to fileinfo
	set nlMasta to nl
	set nllist to (split(nl, "/"))
	set currentNL to 1
	
	set title of window "action_view" to ""
	set content of table view 1 of scroll view 1 of window "action_view" to {}
	set enabled of text field "viewWindowSearch" of window "action_view" to false
	
	if (count nlMasta) is greater than 1 then
		set nl to (item 1 of nlMasta) as string
		set itemCountText to snr((localized string "ITEMCOUNTTEXT"), "2", (count nlMasta))
		set the contents of text field "filepath" of window "main" to ((count nlMasta) & itemCountText) as string
		set the contents of text field "filepathText" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ((item (currentNL) of nlMasta) as string)
		tell application "System Events"
			set dropKind to (kind of (POSIX file (item 1 of nlMasta) as alias))
		end tell
		getDropKind(dropKind)
	else
		set nl to nl as string
		tell application "System Events"
			set dropKind to (kind of (POSIX file (item 1 of nlMasta) as alias))
		end tell
		set the contents of text field "filepathText" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ((item (currentNL) of nlMasta) as string)
		getDropKind(dropKind)
		set nllist to (split(nl, "/"))
		if last character of (item currentNL of nlMasta) is "/" then
			set bxe to split((item currentNL of nlMasta), "/")
			set bxe to item ((count bxe) - 1) of bxe as string
		else
			set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			if dropKind does not contain "Folder" then
				try
					set bxe to reverse of every character of bxe
					repeat until item 1 of bxe is "."
						set bxe to rest of bxe
					end repeat
					set bxe to rest of bxe
					set bxe to reverse of bxe as string
				on error
					set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
				end try
			end if
		end if
		
		set the contents of text field "filepath" of window "main" to bxe as string
	end if
	
	
end drop

on clicked theObject
	if the name of theObject is "cancel_action_win_button" then
		set title of window "main" to ""
		close panel window 1
	else if the name of theObject is "outputChoice1" then
		set myOutputChoice to "1"
	else if the name of theObject is "outputChoice2" then
		set myOutputChoice to "2"
	else if the name of theObject is "closePrefs" then
		set title of window "main" to ""
		close panel window "prefsWin"
		
		if visible of window "liveoutputWindow" is true then
			hide window "main"
		end if
		savePrefs()
	else if the name of theObject is "chooseOutput" then
		set (the contents of text field "defaultOutput" of window "prefsWin") to (POSIX path of (choose folder))
	else if the title of theObject is (localized string "GO_TEXT") then
		set p7String to (quoted form of (appsup & "7za"))
		
		set sameItemDir to getSameItemDir()
		set defaultOutputDir to the contents of text field "defaultOutput" of window "prefsWin" as string
		tell application "System Events"
			set dropKind to (kind of (POSIX file (nl) as alias))
		end tell
		if name of theObject is "go_expand" then
			
			set title of window "main" to ""
			close panel window "action_expand"
			goAction_expand()
			
		else if name of theObject is "go_shrink" then
			
			set title of window "main" to ""
			close panel window "action_shrink"
			goAction_shrink()
			
		end if
	else if the name of theObject is "closeabout" then
		set title of window "main" to ""
		close panel window "about"
		
		if visible of window "liveoutputWindow" is true then
			hide window "main"
		end if
	else if the name of theObject is "canceldialog" then
		set title of window "main" to ""
		close panel window "dialogwindow"
		
		if visible of window "liveoutputWindow" is true then
			hide window "main"
		end if
		
	else if the name of theObject is "clearButton" then
		if last character of (item currentNL of nlMasta) is "/" then
			set bxe to split((item currentNL of nlMasta), "/")
			set bxe to item ((count bxe) - 1) of bxe as string
		else
			set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			try
				set bxe to reverse of every character of bxe
				repeat until item 1 of bxe is "."
					set bxe to rest of bxe
				end repeat
				set bxe to rest of bxe
				set bxe to reverse of bxe as string
			on error
				set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			end try
		end if
		
		set the contents of text field "filepath" of window "main" to bxe as string
		
	else if the name of theObject is "confirmdialog" then
		
		
		set title of window "main" to ""
		
		close panel window "dialogwindow"
		if visible of window "liveoutputWindow" is true then
			hide window "main"
		end if
		
		
	else if the name of theObject is "closeLiveoutput" then
		if title of theObject is (localized string "CLOSE_TEXT") then
			hide window "liveoutputWindow"
			set visible of window "main" to true
		else
			set currentNL to (currentNL + 1)
			set itemCountText to split((localized string "ITEM1OF1TEXT"), "1")
			set itemCountText to ((item 1 of itemCountText) & currentNL & (item 2 of itemCountText) & (count nlMasta)) as string
			set the contents of text field "itemCount" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ("(" & itemCountText & ")")
			batchProcess(currentProcessString)
		end if
	else if the name of theObject is "stopCurrent" then
		set dontRemoveInputItem to true
		try
			do shell script "kill " & currentPID
		end try
		
		
		set the title of button "closeLiveoutput" of window "liveoutputWindow" to (localized string "CLOSE_TEXT")
		set currentNL to 1
	else if the name of theObject is "enter_view_password" then
		
		close panel window "action_view_pw"
		
		set pwd to (contents of text field "pw_input_view" of window "action_view_pw") as string
		if (p7String contains "7za") then
			set currentProcessString to (p7String & " l -slt -p" & quoted form of pwd & " " & quoted form of (item 1 of nlMasta as string))
		else
			set currentProcessString to (p7String & " vb -p" & quoted form of pwd & " " & quoted form of (item 1 of nlMasta as string))
		end if
		set currentProcessString to (currentProcessString & " &> " & quoted form of (appsup & "tempLog.txt") & " & echo $!")
		set viewPassword to true
		set myViewPID to (do shell script currentProcessString)
		viewingItemProcess(myViewPID)
	else if name of theObject is "go_view_delete" then
		set p7String to (quoted form of (appsup & "7za"))
		
		set sameItemDir to getSameItemDir()
		
		set defaultOutputDir to the contents of text field "defaultOutput" of window "prefsWin" as string
		tell application "System Events"
			set dropKind to (kind of (POSIX file (nl) as alias))
		end tell
		
		
		set chosenViewItems to GetKeys()
		if content of table view 1 of scroll view 1 of window "action_view" is {} then
			error number -128
		end if
		if (count chosenViewItems) is 0 then
			error number -128
		end if
		try
			do shell script ("rm " & quoted form of includeFile)
		end try
		try
			repeat with aZib from 1 to (count chosenViewItems)
				do shell script ("echo " & quoted form of (item aZib of chosenViewItems) & " >> " & quoted form of includeFile)
			end repeat
		on error
			error number -128
		end try
		
		set currentAction to "delete"
		if (count GetKeys()) is greater than 1 then
			displayDialog("Deleting multiple items is not currently supported.", "Oh", false)
			error number -128
		else
			set chosenViewItem to item 1 of GetKeys()
			if dropKind is "RAR Archive" then
				displayDialog((localized string "DELETEFROMRARERROR"), "Oh", false)
			else if dropKind is "Split Archive" then
				if useunRAR is "1" then
					displayDialog((localized string "DELETEFROMRARERROR"), "Oh", false)
				else
					if viewPassword is true then
						set currentProcessString to (p7String & " d -p" & quoted form of pwd & " " & quoted form of removeThis & " " & (quoted form of (chosenViewItem)) & " -r")
					else
						set currentProcessString to (p7String & " d " & quoted form of removeThis & " " & (quoted form of (chosenViewItem)) & " -r")
					end if
					batchProcess(currentProcessString)
				end if
			else
				if viewPassword is true then
					set currentProcessString to (p7String & " d -p" & quoted form of pwd & " " & quoted form of removeThis & " " & (quoted form of (chosenViewItem)) & " -r")
				else
					set currentProcessString to (p7String & " d " & quoted form of removeThis & " " & (quoted form of (chosenViewItem)) & " -r")
				end if
				batchProcess(currentProcessString)
			end if
		end if
		
		viewItemInitial()
	else if name of theObject is "go_view_expand" then
		set isQuickLook to false
		go_view_expand_function()
	else if name of theObject is "go_view_quickLook" then
		set isQuickLook to true
		go_view_expand_function()
	end if
end clicked

on getDropKind(dropKind)
	if (count nlMasta) is greater than 1 then
		if theGoAhead is 1 then
			set image of image view "dropBoxImage" of window "main" to (load image "multiple_items2")
		else
			delete image of image view "dropBoxImage" of window "main"
		end if
	else
		call method "getImageForPosixPath:placeInImageView:" with parameters {((item currentNL of nlMasta) as string), image view "dropBoxImage" of window "main"}
	end if
end getDropKind

on choose menu item theObject
	if the name of theObject is "open_file" then
		set nl to POSIX path of (choose file)
		set nlMasta to {nl}
		set nllist to (split(nl, "/"))
		set currentNL to 1
		
		if last character of (item currentNL of nlMasta) is "/" then
			set bxe to split((item currentNL of nlMasta), "/")
			set bxe to item ((count bxe) - 1) of bxe as string
		else
			set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			try
				set bxe to reverse of every character of bxe
				repeat until item 1 of bxe is "."
					set bxe to rest of bxe
				end repeat
				set bxe to rest of bxe
				set bxe to reverse of bxe as string
			on error
				set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			end try
		end if
		
		set the contents of text field "filepath" of window "main" to bxe as string
		set the contents of text field "filepathText" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ((item (currentNL) of nlMasta) as string)
		tell application "System Events"
			set dropKind to (kind of (POSIX file (nl) as alias))
		end tell
		getDropKind(dropKind)
		
		
	else if the name of theObject is "open_folder" then
		set nl to POSIX path of (choose folder)
		set nlMasta to {nl}
		set nllist to (split(nl, "/"))
		set currentNL to 1
		if last character of (item currentNL of nlMasta) is "/" then
			set bxe to split((item currentNL of nlMasta), "/")
			set bxe to item ((count bxe) - 1) of bxe as string
		else
			set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			try
				set bxe to reverse of every character of bxe
				repeat until item 1 of bxe is "."
					set bxe to rest of bxe
				end repeat
				set bxe to rest of bxe
				set bxe to reverse of bxe as string
			on error
				set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			end try
		end if
		
		set the contents of text field "filepath" of window "main" to bxe as string
		set the contents of text field "filepathText" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ((item (currentNL) of nlMasta) as string)
		tell application "System Events"
			set dropKind to (kind of (POSIX file (nl) as alias))
		end tell
		getDropKind(dropKind)
		
		
	else if the name of theObject is "aboutwin" then
		
		set title of window "main" to "About Ez7z"
		display panel window "about" attached to window "main"
		
		
	else if the name of theObject is "showPreferences" then
		
		set title of window "main" to title of (menu item "showPreferences" of menu 1 of main menu)
		display panel window "prefsWin" attached to window "main"
	else if the name of theObject is "showDonate" then
		open location "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=UPXL6NRKK2V78"
	end if
end choose menu item

on open theObject
	set title of window "action_view" to ""
	set content of table view 1 of scroll view 1 of window "action_view" to {}
	set enabled of text field "viewWindowSearch" of window "action_view" to false
	
	set nlMasta to {}
	repeat with a from 1 to count theObject
		set nlMasta to nlMasta & {(POSIX path of item a of theObject)}
	end repeat
	set nl to (item 1 of nlMasta)
	set nllist to (split(nl, "/"))
	set currentNL to 1
	
	if (count nlMasta) is greater than 1 then
		set nl to (item 1 of nlMasta) as string
		set itemCountText to snr((localized string "ITEMCOUNTTEXT"), "2", (count nlMasta))
		set the contents of text field "filepath" of window "main" to ((count nlMasta) & itemCountText) as string
		set the contents of text field "filepathText" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ((item (currentNL) of nlMasta) as string)
		tell application "System Events"
			set dropKind to (kind of (POSIX file (item 1 of nlMasta) as alias))
		end tell
		getDropKind(dropKind)
	else
		set nl to nl as string
		tell application "System Events"
			set dropKind to (kind of (POSIX file (item 1 of nlMasta) as alias))
		end tell
		set the contents of text field "filepathText" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ((item (currentNL) of nlMasta) as string)
		getDropKind(dropKind)
		set nllist to (split(nl, "/"))
		if last character of (item currentNL of nlMasta) is "/" then
			set bxe to split((item currentNL of nlMasta), "/")
			set bxe to item ((count bxe) - 1) of bxe as string
		else
			set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			if dropKind does not contain "Folder" then
				try
					set bxe to reverse of every character of bxe
					repeat until item 1 of bxe is "."
						set bxe to rest of bxe
					end repeat
					set bxe to rest of bxe
					set bxe to reverse of bxe as string
				on error
					set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
				end try
			end if
		end if
		
		set the contents of text field "filepath" of window "main" to bxe as string
	end if
	
end open

on opened theObject
end opened

on should quit theObject
	try
		do shell script ("rm " & quoted form of (appsup & "tempLog.txt"))
	end try
	try
		savePrefs()
	end try
	return true
end should quit

on became key theObject
	(*Add your script here.*)
end became key

on should quit after last window closed theObject
	return true
end should quit after last window closed

on idle theObject
	
	
	
end idle

on launched theObject
	
	set currentNL to 1
	set removeThis to ((random number from 1 to 9) & "a(" & (random number from 1 to 9) & "k())") as string
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	
	set p7String to (appsup & "7za")
	
	set includeFile to (appsup & "include.txt")
	set isQuickLook to false
	set myQuickLookTempDir to (POSIX path of (path to home folder) & "Library/Application Support/Ez7z-QuickLook/") as string
	try
		do shell script ("rm -r " & (quoted form of myQuickLookTempDir))
	end try
	try
		do shell script ("mkdir " & (quoted form of myQuickLookTempDir))
	end try
	
	set o to appsup
	set prefsFile to (quoted form of (POSIX path of (path to home folder) & "Library/Application Support/Ez7z.prefs"))
	
	try
		try
			set enableMultithreading to item 2 of split(prefsfileR, "<multithreadOn>") as string
		on error
			set enableMultithreading to "0"
		end try
		try
			set defaultOutputDir to item 2 of split(prefsfileR, "<defaultOutput>") as string
		on error
			set defaultOutputDir to (POSIX path of (path to desktop))
		end try
		try
			set numberofthreads to item 2 of split(prefsfileR, "<#ofThreads>") as string
		on error
			set numberofthreads to "3"
		end try
		try
			set myOutputChoice to item 2 of split(prefsfileR, "<outputChoice>") as string
		on error
			set myOutputChoice to "1"
		end try
		
		try
			set useunRAR to item 2 of split(prefsfileR, "<useunRAR>") as string
		on error
			set useunRAR to "1"
		end try
		try
			set deleteOriginal to item 2 of split(prefsfileR, "<deleteOriginal>") as string
		on error
			set deleteOriginal to "0"
		end try
		
		try
			set skipActionWindow to item 2 of split(prefsfileR, "<skipActionW>") as string
		on error
			set skipActionWindow to "0"
		end try
		try
			set quitWhenDone to item 2 of split(prefsfileR, "<quitWhenDone>") as string
		on error
			set quitWhenDone to "0"
		end try
		
		---STICKY
		try
			set autoAdvance to item 2 of split(prefsfileR, "<autoAdvance>") as string
		on error
			set autoAdvance to "1"
		end try
		try
			set defaultCompressionLevel to item 2 of split(prefsfileR, "<compressionLevel>") as string
		on error
			set defaultCompressionLevel to "2"
		end try
		try
			set splitArchiveMB to item 2 of split(prefsfileR, "<splitAmnt>") as string
		on error
			set splitArchiveMB to "1"
		end try
		try
			set shrinkTypeSticky to item 2 of split(prefsfileR, "<shrinkType>") as string
		on error
			set shrinkTypeSticky to "7z"
		end try
		try
			set outputViewType to item 2 of split(prefsfileR, "<outputView>") as string
		on error
			set outputViewType to "summarizedTab"
		end try
	on error
		set enableMultithreading to "0"
		set defaultOutputDir to (POSIX path of (path to desktop))
		set numberofthreads to "3"
		set myOutputChoice to "1"
		
		set useunRAR to "1"
		set deleteOriginal to "0"
		
		set skipActionWindow to "0"
		set quitWhenDone to "0"
		---
		set autoAdvance to "1"
		set defaultCompressionLevel to "2"
		set splitArchiveMB to "1"
		set shrinkTypeSticky to "7z"
		set outputViewType to "summarizedTab"
	end try
	if myOutputChoice is "1" then
		set current row of matrix 1 of window "prefsWin" to 1
	else
		set current row of matrix 1 of window "prefsWin" to 2
	end if
	set state of button "useunRAR" of window "prefsWin" to useunRAR
	set state of button "deleteOriginal" of window "prefsWin" to deleteOriginal
	set state of button "multicoreCheck" of window "prefsWin" to enableMultithreading
	set the contents of text field "defaultOutput" of window "prefsWin" to defaultOutputDir
	set the contents of text field "numberOfThreads" of window "prefsWin" to numberofthreads
	if enableMultithreading is "1" then
		set visible of text field "multithreadtxt" of window "prefsWin" to true
		set visible of text field "numberOfThreads" of window "prefsWin" to true
	else
		set visible of text field "multithreadtxt" of window "prefsWin" to false
		set visible of text field "numberOfThreads" of window "prefsWin" to false
	end if
	set state of button "waitForMe" of tab view item 1 of tab view 1 of window "liveoutputWindow" to autoAdvance
	set the content of control "levelslider" of window "action_shrink" to defaultCompressionLevel
	set the contents of text field "split_text2" of window "action_shrink" to splitArchiveMB
	set title of popup button 1 of window "action_shrink" to shrinkTypeSticky
	set current tab view item of tab view 1 of window "liveoutputWindow" to tab view item outputViewType of tab view 1 of window "liveoutputWindow"
	
	set state of button "skipAction" of window "prefsWin" to skipActionWindow
	set state of button "quitWhenDone" of window "prefsWin" to quitWhenDone
	
	set visible of window "main" to true
	
	
	set nl to ""
	set aboutWindowText2 to (localized string "ABOUTWINDOWTEXT")
	
	
	
	set (the contents of text view 1 of scroll view 1 of window "about") to (aboutWindowText2)
	set currentAction to "expand"
	set otherScript to useOtherScript("shrinkTypeMenu")
	tell otherScript to toggleShrinkItems()
	set the contents of text field "filepath" of window "main" to (localized string "DEFAULTDROPTEXT")
end launched

on should close theObject
	if the name of theObject is "action_view" then
		hide theObject
		set title of theObject to ""
		set content of table view 1 of scroll view 1 of window "action_view" to {}
		set enabled of text field "viewWindowSearch" of window "action_view" to false
	end if
	return false
end should close

on action theObject
	if the name of theObject is "viewWindowSearch" then
		try
			set viewSearchQuery to contents of text field "viewWindowSearch" of window "action_view" as string
			if viewSearchQuery is "" then
				set contents of table view 1 of scroll view 1 of window "action_view" to viewResults
			else
				if (count every character of viewSearchQuery) is greater than 1 then
					set possibleOnes to {}
					repeat with bb from 1 to (count viewResults)
						if (item bb of viewResults) contains viewSearchQuery then
							set possibleOnes to possibleOnes & (item bb of viewResults)
						end if
					end repeat
					set contents of table view 1 of scroll view 1 of window "action_view" to possibleOnes
				end if
			end if
		end try
	end if
end action

on clicked toolbar item theObject
	set clickedTBButton to (name of theObject)
	
	if clickedTBButton is "Expand" then
		if the contents of text field "filepath" of window "main" is (localized string "DEFAULTDROPTEXT") then
			displayDialog((localized string "FORGOTITEM"), "Oh", false)
			error number -128
		else
			
			set sameItemDir to getSameItemDir()
			set defaultOutputDir to the contents of text field "defaultOutput" of window "prefsWin" as string
			
			set itemCountText to split((localized string "ITEM1OF1TEXT"), "1")
			set itemCountText to ((item 1 of itemCountText) & currentNL & (item 2 of itemCountText) & (count nlMasta)) as string
			set the contents of text field "itemCount" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ("(" & itemCountText & ")")
			
			if skipActionWindow is "1" then
				goAction_expand()
			else
				
				set title of window "main" to "Expand"
				display panel window "action_expand" attached to window "main"
			end if
			
		end if
	else if the name of theObject is "View" then
		viewItemInitial()
	else if the name of theObject is "Shrink" then
		if the contents of text field "filepath" of window "main" is (localized string "DEFAULTDROPTEXT") then
			displayDialog((localized string "FORGOTITEM"), "Oh", false)
			error number -128
		else
			
			set sameItemDir to getSameItemDir()
			set defaultOutputDir to the contents of text field "defaultOutput" of window "prefsWin" as string
			
			set itemCountText to split((localized string "ITEM1OF1TEXT"), "1")
			set itemCountText to ((item 1 of itemCountText) & currentNL & (item 2 of itemCountText) & (count nlMasta)) as string
			set the contents of text field "itemCount" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ("(" & itemCountText & ")")
			tell window "action_shrink"
				set visible of matrix 1 to false
				set visible of text field "shrink_archiveOptionText1" to false
				set visible of text field "shrink_archiveOptionText2" to false
			end tell
			
			if skipActionWindow is "1" then
				goAction_shrink()
			else
				
				set title of window "main" to "Shrink"
				display panel window "action_shrink" attached to window "main"
			end if
		end if
	else if the name of theObject is "PAR2" then
		
		if the contents of text field "filepath" of window "main" is (localized string "DEFAULTDROPTEXT") then
			displayDialog((localized string "FORGOTITEM"), "Oh", false)
			error number -128
		else
			set defaultOutputDir to the contents of text field "defaultOutput" of window "prefsWin" as string
			set sameItemDir to getSameItemDir()
			set itemCountText to split((localized string "ITEM1OF1TEXT"), "1")
			set itemCountText to ((item 1 of itemCountText) & currentNL & (item 2 of itemCountText) & (count nlMasta)) as string
			set the contents of text field "itemCount" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ("(" & itemCountText & ")")
			set currentAction to "par2"
			tell application "System Events"
				set dropKind to (kind of (POSIX file (nl) as alias))
			end tell
			
			set p7String to (quoted form of appsup & "par2")
			if dropKind is "Parchive" then
				set currentProcessString to (p7String & " r " & quoted form of removeThis)
				batchProcess(currentProcessString)
			else
				if defaultOutputDir is "" then
					set defaultOutputDir to "/"
				end if
				if sameItemDir is "" then
					set sameItemDir to "/"
				end if
				
				if last character of (item currentNL of nlMasta) is "/" then
					set bxe to split((item currentNL of nlMasta), "/")
					set bxe to item ((count bxe) - 1) of bxe as string
				else
					set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
					try
						set bxe to reverse of every character of bxe
						repeat until item 1 of bxe is "."
							set bxe to rest of bxe
						end repeat
						set bxe to rest of bxe
						set bxe to reverse of bxe as string
					on error
						set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
					end try
				end if
				if (count nlMasta) is greater than 1 then
					if myOutputChoice is "1" then
						try
							set o to POSIX path of (choose folder default location (POSIX file defaultOutputDir))
						on error number -1700
							set o to POSIX path of (choose folder default location (POSIX file sameItemDir))
						end try
					else
						set o to POSIX path of (choose folder default location (POSIX file sameItemDir))
					end if
				else
					if myOutputChoice is "1" then
						try
							set o to POSIX path of (choose file name default location (POSIX file defaultOutputDir) default name bxe & ".par2")
						on error number -1700
							set o to POSIX path of (choose file name default location (POSIX file sameItemDir) default name bxe & ".par2")
						end try
					else
						set o to POSIX path of (choose file name default location (POSIX file sameItemDir) default name bxe & ".par2")
						
					end if
				end if
				
				
				set myShellCommand to ((p7String & " c " & o & " " & quoted form of removeThis))
				set currentProcessString to myShellCommand
				batchProcess(currentProcessString)
			end if
		end if
	end if
end clicked toolbar item

on snr(the_string, search_string, replace_string)
	tell (a reference to my text item delimiters)
		set {old_tid, contents} to {contents, search_string}
		set {the_string, contents} to {the_string's text items, replace_string}
		set {the_string, contents} to {"" & the_string, old_tid}
	end tell
	return the_string
end snr

on split(someText, delimiter)
	set AppleScript's text item delimiters to delimiter
	set someText to someText's text items
	set AppleScript's text item delimiters to {""}
	return someText
end split



on displayDialog(thediatext, butttext, cancelenabled)
	set visible of button 2 of window "dialogwindow" to cancelenabled
	set the title of button "confirmdialog" of window "dialogwindow" to butttext
	set the contents of text field "textofdialogwindow" of window "dialogwindow" to thediatext
	display panel window "dialogwindow" attached to window "main"
end displayDialog


on awake from nib theObject
	if the name of theObject is "mainTB" then
		set MyWindowToolbar to make new toolbar at end with properties {name:"MyWindow toolbar", identifier:"MyWindow toolbar identifier", allows customization:false, auto sizes cells:true, display mode:label only display mode, size mode:default size mode}
		set allowed identifiers of MyWindowToolbar to {"Expand", "Shrink", "View", "PAR2", "customize toolbar item identifer", "flexible space item identifer", "space item identifier", "separator item identifier"}
		set default identifiers of MyWindowToolbar to {"flexible space item identifer", "Expand", "Shrink", "View", "PAR2", "flexible space item identifer"}
		make new toolbar item at end of toolbar items of MyWindowToolbar with properties {identifier:"Expand", name:"Expand", label:"Expand", palette label:"Expand", tool tip:"Open a compressed file.", image name:"NSEnterFullScreenTemplate"}
		make new toolbar item at end of toolbar items of MyWindowToolbar with properties {identifier:"Shrink", name:"Shrink", label:"Shrink", palette label:"Shrink", tool tip:"Create a compressed file.", image name:"NSExitFullScreenTemplate"}
		make new toolbar item at end of toolbar items of MyWindowToolbar with properties {identifier:"View", name:"View", label:"View", palette label:"View", tool tip:"Inspect a compressed file.", image name:"NSFlowViewTemplate"}
		make new toolbar item at end of toolbar items of MyWindowToolbar with properties {identifier:"PAR2", name:"PAR2", label:"PAR2", palette label:"PAR2", tool tip:"Create/View a PAR2 file.", image name:"NSColumnViewTemplate"}
		set toolbar of window "main" to MyWindowToolbar
	end if
end awake from nib

on batchProcess(myShellCommand)
	set visible of progress indicator 1 of tab view item 1 of tab view 1 of window "liveoutputWindow" to false
	set the contents of text field "filepathText" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ((item (currentNL) of nlMasta) as string)
	set visible of window "main" to false
	set dontRemoveInputItem to false
	try
		set the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of window "liveoutputWindow" to ""
	end try
	set title of button "closeLiveoutput" of window "liveoutputWindow" to (localized string "NEXT_TEXT")
	set enabled of button "closeLiveoutput" of window "liveoutputWindow" to false
	set abee to (item currentNL of nlMasta) as string
	if last character of (item currentNL of nlMasta) is "/" then
		set bxe to split((item currentNL of nlMasta), "/")
		set bxe to item ((count bxe) - 1) of bxe as string
		copy bxe to bxe_full
	else
		set bxe_full to last item of (split((item currentNL of nlMasta), "/")) as string
		copy bxe_full to bxe
		try
			set bxe to reverse of every character of bxe
			repeat until item 1 of bxe is "."
				set bxe to rest of bxe
			end repeat
			set bxe to rest of bxe
			set bxe to reverse of bxe as string
		on error
			set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
		end try
	end if
	
	show window "liveoutputWindow"
	
	tell application "System Events"
		set dropKind to (kind of (POSIX file (item (currentNL) of nlMasta) as alias))
	end tell
	if currentAction is "expand" then
		if dropKind is "RAR Archive" then
			set myShellCommand to snr(myShellCommand, (" -o'"), "")
		else if dropKind is "Split Archive" then
			if useunRAR is "1" then
				set myShellCommand to snr(myShellCommand, (" -o'"), "")
			else
				set myShellCommand to snr(myShellCommand, o, ("-o" & o))
			end if
		else
			if dropKind is not "bzip2 compressed archive" then
				set myShellCommand to snr(myShellCommand, o, ("-o" & o))
			end if
		end if
	else if currentAction is "shrink" then
		if (count nlMasta) is greater than 1 then
			if current row of matrix 1 of window "action_shrink" is 1 then
				set newO to (o & bxe & "." & shrinktype2) as string
				set myShellCommand to snr(myShellCommand, o, newO)
			else
				set newO to o
			end if
		else
			set newO to o
		end if
	else if currentAction is "par2" then
		tell application "System Events"
			set dropKind to (kind of (POSIX file (item (currentNL) of nlMasta) as alias))
		end tell
		if dropKind ends with "Folder" then
			set abee to (abee & "/*")
		else if dropKind is "Volume" then
			set abee to (abee & "/*")
		end if
		
		if (count nlMasta) is greater than 1 then
			if dropKind is not "Parchive" then
				set newO to (o & bxe & ".par2") as string
				set myShellCommand to snr(myShellCommand, o, newO)
			end if
		else
			set newO to o
		end if
	else
		set newO to o
	end if
	
	
	set abd to (snr(myShellCommand, removeThis, abee))
	set abd to (abd & " &> " & quoted form of (appsup & "tempLog.txt") & " & echo $!")
	
	if currentAction is "expand" then
		set the contents of text field "bigWhite" of tab view item 1 of tab view 1 of window "liveoutputWindow" to (localized string ("CREATEPROGRESS"))
		if dropKind is "bzip2 compressed archive" then
			set p7String2 to "\"" & appsup & "7za\" "
			set CPString to (p7String2 & " l " & quoted form of (item currentNL of nlMasta as string))
			set viewResults to (do shell script (CPString))
			set viewResults to (item 2 of split(viewResults, "------------------- ----- ------------ ------------  ------------------------")) as string
			set viewResults to every paragraph of viewResults
			set viewResults to reverse of rest of reverse of viewResults
			set viewResults to rest of viewResults as string
			
			set viewResults to last item of (split(viewResults, "                   "))
			set viewResults to split(viewResults, "  ")
			set viewResultsCount to (count viewResults)
			set outSize to (item (viewResultsCount - 1) of viewResults) as string
			
		else
			if dropKind is "RAR Archive" then
				set p7String2 to "\"" & appsup & "unrar\" "
				set abd to (snr(abd, "Resources/7za", "Resources/7za"))
			else if dropKind is "Split Archive" then
				if useunRAR is "1" then
					set p7String2 to "\"" & appsup & "unrar\" "
					set abd to (snr(abd, "Resources/7za", "Resources/unrar"))
				else
					set p7String2 to "\"" & appsup & "7za\" "
					set abd to (snr(abd, "Resources/unrar", "Resources/7za"))
				end if
			else
				set p7String2 to "\"" & appsup & "7za\" "
				set abd to (snr(abd, "Resources/unrar", "Resources/7za"))
			end if
			
			set abdd to (p7String2 & " l " & quoted form of ((item (currentNL) of nlMasta) as string) & " &> " & quoted form of (appsup & "tempLog.txt") & " & echo $!")
			do shell script abdd
			delay (0.3)
			set viewResults to (do shell script "cat " & quoted form of (appsup & "tempLog.txt")) as string
			set abdd to every paragraph of viewResults
			if dropKind is "RAR Archive" then
				set abdd to (item ((count abdd) - 1) of abdd) as string
				--set outSize to word 2 of abdd as string
			else if dropKind is "Split Archive" then
				if useunRAR is "1" then
					set abdd to (item ((count abdd) - 1) of abdd) as string
					try
						set outSize to word 2 of abdd as string
					on error
						if currentNL is greater than or equal to (count nlMasta) then
							set title of button "closeLiveoutput" of window "liveoutputWindow" to (localized string "CLOSE_TEXT")
							set enabled of button "closeLiveoutput" of window "liveoutputWindow" to true
							set currentNL to 1
							set the contents of text field "bigWhite" of tab view item 1 of tab view 1 of window "liveoutputWindow" to (localized string ("IDLE_TEXT"))
							displayDialog((localized string "TOGGLEUNRAR"), (localized string "OKAY_TEXT"), false)
							error number -128
						else
							set enabled of button "closeLiveoutput" of window "liveoutputWindow" to true
							if state of button "waitForMe" of tab view item 1 of tab view 1 of window "liveoutputWindow" is 0 then
								set currentNL to currentNL + 1
								set itemCountText to split((localized string "ITEM1OF1TEXT"), "1")
								set itemCountText to ((item 1 of itemCountText) & currentNL & (item 2 of itemCountText) & (count nlMasta)) as string
								set the contents of text field "itemCount" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ("(" & itemCountText & ")")
								batchProcess(currentProcessString)
							else
								displayDialog((localized string "TOGGLEUNRAR"), (localized string "OKAY_TEXT"), false)
								set the contents of text field "bigWhite" of tab view item 1 of tab view 1 of window "liveoutputWindow" to (localized string ("IDLE_TEXT"))
								error number -128
							end if
						end if
					end try
				else
					
					set abdd to last item of abdd as string
					
					set temp_abdd to split(abdd, (ASCII character 32))
					set temp_abdd to cleanMyList(temp_abdd, {""})
					set abdd to ((item 1 of temp_abdd) as string)
					
					copy abdd to outSize
				end if
			else
				set abdd to last item of abdd as string
				
				set temp_abdd to split(abdd, (ASCII character 32))
				set temp_abdd to cleanMyList(temp_abdd, {""})
				set abdd to ((item 1 of temp_abdd) as string)
				
				copy abdd to outSize
				
			end if
		end if
		
		
		
	end if
	
	if currentAction is "shrink" then
		
		set bxd to split(o, "/")
		if item (count bxd) of bxd is "" then
			set bxd to reverse of rest of reverse of bxd
		end if
		set bxd to rest of bxd
		
	end if
	
	set enabled of button "stopCurrent" of window "liveoutputWindow" to true
	if currentAction is "expand" then
		set abd_bzExtra to ("mv " & quoted form of (appsup & "tempLog.txt") & " " & quoted form of (o & bxe))
	else
		
		set abd_bzExtra to ("mv " & quoted form of (appsup & "tempLog.txt") & " " & quoted form of (o & bxe_full & ".bz2"))
	end if
	
	
	do shell script (abd)
	set currentPID to the result
	
	
	set the contents of text field "bigWhite" of tab view item 1 of tab view 1 of window "liveoutputWindow" to (localized string ("PROCESSING_TEXT"))
	set currentDisplayLog to ((the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of window "liveoutputWindow") as string)
	set exitLoop to true
	set bzExpand to false
	if dropKind is "bzip2 compressed archive" then
		if currentAction is "expand" then
			set bzExpand to true
		end if
	else
		if currentAction is "shrink" then
			if shrinkType is "bzip2" then
				set bzExpand to true
			end if
		end if
	end if
	
	
	repeat
		
		delay 0.5
		if bzExpand is true then
			set (the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of window "liveoutputWindow") to (localized string ("PROCESSING_TEXT"))
			set bzExpand_o to (appsup & "tempLog.txt") as string
			
		else
			
			try
				set curOutFile to (do shell script "cat " & quoted form of (appsup & "tempLog.txt")) as string
				set (the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of window "liveoutputWindow") to curOutFile
				set currentDisplayLog to ((the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of window "liveoutputWindow") as string)
			end try
			
		end if
		
		try
			
			set exitLoop2 to (count of paragraphs in (do shell script "ps -p " & currentPID)) as integer
			
		on error number 1
			exit repeat
		end try
		
	end repeat
	if currentAction is "expand" then
		if dropKind is not "bzip2 compressed archive" then
			if dontRemoveInputItem is false then
				if (curOutFile) contains ". Wrong password?" then
					displayDialog((localized string "WRONG_PASSWORD"), (localized string "OKAY_TEXT"), false)
				end if
			end if
		end if
	end if
	
	if bzExpand is true then
		do shell script abd_bzExtra
		set (the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of window "liveoutputWindow") to localized string ("IDLE_TEXT")
	end if
	
	
	set enabled of button "stopCurrent" of window "liveoutputWindow" to false
	set enabled of button "closeLiveoutput" of window "liveoutputWindow" to true
	
	if deleteOriginal is "1" then
		if currentAction is "shrink" then
			try
				set delThis to ((item (currentNL) of nlMasta) as string)
				set mvFld to POSIX path of (((path to home folder) & ".Trash") as string)
			end try
			try
				do shell script ("mv -f " & (quoted form of delThis) & " " & (quoted form of mvFld))
			end try
		end if
	end if
	try
		set (the contents of text view 1 of scroll view 1 of tab view item 2 of tab view 1 of window "liveoutputWindow") to curOutFile
	end try
	
	if state of button "waitForMe" of tab view item 1 of tab view 1 of window "liveoutputWindow" is 0 then
		
		if currentNL is greater than or equal to (count nlMasta) then
			set title of button "closeLiveoutput" of window "liveoutputWindow" to (localized string "CLOSE_TEXT")
			set currentNL to 1
			set the contents of text field "bigWhite" of tab view item 1 of tab view 1 of window "liveoutputWindow" to (localized string ("IDLE_TEXT"))
			
			if quitWhenDone is "1" then
				if isQuickLook is false then
					tell me to quit
				end if
			end if
		else
			set enabled of button "stopCurrent" of window "liveoutputWindow" to true
			set currentNL to (currentNL + 1)
			set itemCountText to split((localized string "ITEM1OF1TEXT"), "1")
			set itemCountText to ((item 1 of itemCountText) & currentNL & (item 2 of itemCountText) & (count nlMasta)) as string
			set the contents of text field "itemCount" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ("(" & itemCountText & ")")
			batchProcess(currentProcessString)
		end if
	else
		if currentNL is greater than or equal to (count nlMasta) then
			set title of button "closeLiveoutput" of window "liveoutputWindow" to (localized string "CLOSE_TEXT")
			set currentNL to 1
			set the contents of text field "bigWhite" of tab view item 1 of tab view 1 of window "liveoutputWindow" to (localized string ("IDLE_TEXT"))
			
			if quitWhenDone is "1" then
				if isQuickLook is false then
					tell me to quit
				end if
			end if
		else
			set the contents of text field "bigWhite" of tab view item 1 of tab view 1 of window "liveoutputWindow" to (localized string ("IDLE_TEXT"))
		end if
	end if
end batchProcess

on savePrefs()
	tell window "prefsWin"
		set enableMultithreading to state of button "multicoreCheck" as string
		set defaultOutputDir to the contents of text field "defaultOutput" as string
		set numberofthreads to the contents of text field "numberOfThreads"
		set useunRAR to state of button "useunRAR" as string
		set deleteOriginal to state of button "deleteOriginal" as string
		set skipActionWindow to state of button "skipAction" as string
		set quitWhenDone to state of button "quitWhenDone" as string
	end tell
	tell window "liveoutputwindow"
		set autoAdvance to state of button "waitForMe" of tab view item 1 of tab view 1 as string
		set outputViewType to (name of current tab view item of tab view 1) as string
	end tell
	tell window "action_shrink"
		set defaultCompressionLevel to the content of control "levelslider" as string
		set splitArchiveMB to the contents of text field "split_text2" as string
		set shrinkTypeSticky to title of popup button 1 as string
	end tell
	
	if (current row of matrix 1 of window "prefsWin") is 1 then
		set myOutputChoice to "1"
	else
		set myOutputChoice to "2"
	end if
	set writeThisStuff to "<multithreadOn>" & enableMultithreading & "<multithreadOn> <defaultOutput>" & defaultOutputDir & "<defaultOutput>"
	set writeThisStuff to writeThisStuff & "<#ofThreads>" & numberofthreads & "<#ofThreads> <useunRAR>" & useunRAR & "<useunRAR>"
	set writeThisStuff to writeThisStuff & "<outputChoice>" & myOutputChoice & "<outputChoice>"
	set writeThisStuff to writeThisStuff & "<deleteOriginal>" & deleteOriginal & "<deleteOriginal>"
	set writeThisStuff to writeThisStuff & "<autoAdvance>" & autoAdvance & "<autoAdvance> <compressionLevel>" & defaultCompressionLevel & "<compressionLevel>"
	set writeThisStuff to writeThisStuff & "<splitAmnt>" & splitArchiveMB & "<splitAmnt>"
	set writeThisStuff to writeThisStuff & "<shrinkType>" & shrinkTypeSticky & "<shrinkType> <outputView>" & outputViewType & "<outputView>"
	set writeThisStuff to writeThisStuff & "<skipActionW>" & skipActionWindow & "<skipActionW> <quitWhenDone>" & quitWhenDone & "<quitWhenDone>"
	
	
	do shell script "echo " & quoted form of writeThisStuff & " > " & prefsFile
end savePrefs

on update_progress(iteration, total_count, windowVar)
	if windowVar is "liveoutputWindow" then
		tell tab view item 1 of tab view 1 of window "liveoutputWindow"
			if iteration = 1 then
				tell progress indicator 1 to start
				set indeterminate of progress indicator 1 to true
			else
				tell progress indicator 1 to stop
				set indeterminate of progress indicator 1 to false
			end if
			set maximum value of progress indicator 1 to total_count
			set content of progress indicator 1 to iteration
		end tell
		tell window "liveoutputWindow"
			update
		end tell
	else
		tell window windowVar
			if iteration = 1 then
				tell progress indicator 1 to start
				set indeterminate of progress indicator 1 to true
			else
				tell progress indicator 1 to stop
				set indeterminate of progress indicator 1 to false
			end if
			set maximum value of progress indicator 1 to total_count
			set content of progress indicator 1 to iteration
			update
		end tell
	end if
end update_progress

on switchDockicon(iconNumber)
	try
		set a to load image ("dock" & iconNumber)
		tell me
			set icon image to a
		end tell
	on error
		if iconNumber is greater than 9.9 then
			set a to load image ("AppIconBWJeansGradient")
		else if iconNumber is greater than 8.9 then
			set a to load image ("dock" & "9")
		else if iconNumber is greater than 7.9 then
			set a to load image ("dock" & "8")
		else if iconNumber is greater than 6.9 then
			set a to load image ("dock" & "7")
		else if iconNumber is greater than 5.9 then
			set a to load image ("dock" & "6")
		else if iconNumber is greater than 4.9 then
			set a to load image ("dock" & "5")
		else if iconNumber is greater than 3.9 then
			set a to load image ("dock" & "4")
		else if iconNumber is greater than 2.9 then
			set a to load image ("dock" & "3")
		else if iconNumber is greater than 1.9 then
			set a to load image ("dock" & "2")
		else if iconNumber is greater than 0.9 then
			set a to load image ("dock" & "1")
		end if
		tell me
			set icon image to a
		end tell
	end try
end switchDockicon

to GetKeys()
	tell (table view 1 of scroll view 1 of window "action_view")
		set allItems to (contents of data cell 1 of data rows of it's data source)
		set s_keys to (call method "objectsAtIndexes:" of allItems ¬
			with parameter (call method "selectedRowIndexes" of it)) --Creates list of selected keywords
	end tell
	return s_keys
end GetKeys

on alphabetizeME(the_list)
	set ascii_10 to ASCII character 10
	tell (a reference to my text item delimiters)
		set {old_atid, contents} to {contents, ascii_10}
		set {the_list, contents} to {the_list as Unicode text, old_atid}
	end tell
	set the_list to (do shell script "echo " & quoted form of the_list & " | sort")'s paragraphs
end alphabetizeME

on useOtherScript(scriptNameID)
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript

on viewItemInitial()
	delay (0.5)
	repeat
		try
			set startViewing to ((count of paragraphs in (do shell script "ps -p " & currentPID)) > 1)
		on error
			set startViewing to true
		end try
		if startViewing is true then
			set currentAction to "view"
			set p7String to (quoted form of (appsup & "7za"))
			if the contents of text field "filepath" of window "main" is (localized string "DEFAULTDROPTEXT") then
				displayDialog((localized string "FORGOTITEM"), "Oh", false)
				error number -128
			else
				if (count nlMasta) is greater than 1 then
					displayDialog((localized string "MULTIPLEITEMVIEWERROR"), "Oh", false)
					error number -128
				else
					set itemCountText to split((localized string "ITEM1OF1TEXT"), "1")
					set itemCountText to ((item 1 of itemCountText) & currentNL & (item 2 of itemCountText) & (count nlMasta)) as string
					set the contents of text field "itemCount" of tab view item 1 of tab view 1 of window "liveoutputWindow" to ("(" & itemCountText & ")")
					set bxd to split(nl, "/")
					if item (count bxd) of bxd is "" then
						set bxd to reverse of rest of reverse of bxd
					end if
					tell application "System Events"
						set dropKind to (kind of (POSIX file (nl) as alias))
					end tell
					
					if dropKind is "RAR Archive" then
						set p7String to (quoted form of (appsup & "unrar"))
					else if dropKind is "Split archive" then
						if useunRAR is "1" then
							set p7String to (quoted form of (appsup & "unrar"))
						end if
					end if
					set viewPassword to false
					if (p7String contains "7za") then
						if dropKind is "bzip2 compressed archive" then
							set currentProcessString to (p7String & " l " & quoted form of (item 1 of nlMasta as string))
						else
							set currentProcessString to (p7String & " l -slt " & quoted form of (item 1 of nlMasta as string))
						end if
					else
						set currentProcessString to (p7String & " vb " & quoted form of (item 1 of nlMasta as string))
					end if
					
					set currentProcessString to (currentProcessString & " &> " & quoted form of (appsup & "tempLog.txt") & " & echo $!")
					set myViewPID to (do shell script currentProcessString)
					viewingItemProcess(myViewPID)
				end if
			end if
			exit repeat
		end if
	end repeat
end viewItemInitial

on viewingItemProcess(myViewPID)
	delay (0.5)
	repeat
		try
			set startViewing to ((count of paragraphs in (do shell script "ps -p " & myViewPID)) > 1)
		on error
			set startViewing to true
		end try
		if startViewing is true then
			set viewResults to (do shell script "cat " & quoted form of (appsup & "tempLog.txt")) as string
			
			if viewResults contains ("Can not open encrypted archive. Wrong password?") then
				show window "action_view"
				display panel window "action_view_pw" attached to window "action_view"
			else if viewResults contains ("Can not open file as archive") then
				displayDialog(localized string ("NONVIEWITEM"), "Oh", false)
			else
				set the title of window "action_view" to ((item (currentNL) of nlMasta) as string)
				
				if dropKind is "bzip2 compressed archive" then
					set viewResults to (item 2 of split(viewResults, "------------------- ----- ------------ ------------  ------------------------")) as string
					set viewResults to every paragraph of viewResults
					set viewResults to reverse of rest of reverse of viewResults
					set viewResults to rest of viewResults as string
					
					set viewResults to split(viewResults, "                   ")
					set viewResults to (last item of split((last item of viewResults), "  ")) as string
					
					toggleViewButtons(viewResults, false)
					
				else
					
					try
						if (p7String contains "7za") then
							set viewResults to split(viewResults, "Path = ")
							set viewResults2 to {}
							repeat with aZarb from 1 to (count viewResults)
								set viewResults2 to viewResults2 & {item 1 of split((item aZarb of viewResults), "Modified = ")}
							end repeat
							set viewResults to viewResults2
							set viewResults3 to {}
							repeat with aZarb from 1 to (count viewResults)
								set viewResults3 to viewResults3 & {paragraph 1 of (item aZarb of viewResults)}
							end repeat
							set viewResults to viewResults3
							set viewResults to rest of rest of viewResults
							set viewResults to alphabetizeME(viewResults)
							
							toggleViewButtons(viewResults, true)
						else
							set viewResults to every paragraph of viewResults
							set viewResults to alphabetizeME(viewResults)
							
							toggleViewButtons(viewResults, true)
						end if
					end try
				end if
			end if
			exit repeat
		end if
	end repeat
end viewingItemProcess


------
--GO ACTIONS
------
on goAction_shrink()
	
	set currentAction to "shrink"
	if the state of button "pw_check_shrink" of window "action_shrink" is 1 then
		set pw_input to (the contents of text field "pw_input_shrink") of window "action_shrink"
		if pw_input is "" then
			displayDialog((localized string "NOPASSPROVIDED"), "Oh", false)
			error number -128
		end if
		if the state of button "hideFileNames_check" of window "action_shrink" is 1 then
			set p7String to p7String & " -mhe -p" & quoted form of pw_input
		else
			set p7String to p7String & " -p" & quoted form of pw_input
		end if
	end if
	set shrinkType to (title of (current menu item of popup button "shrinkType" of (window "action_shrink")))
	if shrinkType is "gzip" then
		set shrinktype2 to "gz"
	else if shrinkType is "bzip2" then
		set shrinktype2 to "bz2"
	else
		set shrinktype2 to shrinkType
	end if
	set clevel to (the content of control "levelslider" of window "action_shrink") as string
	set clevel to snr(clevel, ".0", "")
	set clevel to snr(clevel, ",0", "")
	if clevel is "1" then
		set clevel to "0"
	else if clevel is "2" then
		set clevel to "1"
	else if clevel is "3" then
		set clevel to "3"
	else if clevel is "4" then
		set clevel to "5"
	else if clevel is "5" then
		set clevel to "7"
	else if clevel is "6" then
		set clevel to "9"
	end if
	if last character of (item currentNL of nlMasta) is "/" then
		set bxe to split((item currentNL of nlMasta), "/")
		set bxe to item ((count bxe) - 1) of bxe as string
	else
		set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
		tell application "System Events"
			set dropKind to (kind of (POSIX file (item currentNL of nlMasta) as alias))
		end tell
		if dropKind does not contain "Folder" then
			try
				set bxe to reverse of every character of bxe
				repeat until item 1 of bxe is "."
					set bxe to rest of bxe
				end repeat
				set bxe to rest of bxe
				set bxe to reverse of bxe as string
			on error
				set bxe to last item of (split((item currentNL of nlMasta), "/")) as string
			end try
		end if
	end if
	
	if defaultOutputDir is "" then
		set defaultOutputDir to "/"
	end if
	if sameItemDir is "" then
		set sameItemDir to "/"
	end if
	
	if myOutputChoice is "1" then
		try
			if shrinkType is "bzip2" then
				set o to POSIX path of (choose folder default location (POSIX file defaultOutputDir))
			else
				if (count nlMasta) is equal to 1 then
					set o to POSIX path of (choose file name default location (POSIX file defaultOutputDir) default name bxe & "." & shrinktype2)
				else
					if current row of matrix 1 of window "action_shrink" is 2 then
						set o to POSIX path of (choose file name default location (POSIX file defaultOutputDir) default name bxe & "." & shrinktype2)
					else
						set o to POSIX path of (choose folder default location (POSIX file defaultOutputDir))
					end if
				end if
			end if
		on error number -1700
			if shrinkType is "bzip2" then
				set o to POSIX path of (choose folder default location (POSIX file sameItemDir))
			else
				if (count nlMasta) is equal to 1 then
					set o to POSIX path of (choose file name default location (POSIX file sameItemDir) default name bxe & "." & shrinktype2)
				else
					if current row of matrix 1 of window "action_shrink" is 2 then
						set o to POSIX path of (choose file name default location (POSIX file sameItemDir) default name bxe & "." & shrinktype2)
					else
						set o to POSIX path of (choose folder default location (POSIX file sameItemDir))
					end if
				end if
			end if
		end try
	else
		if shrinkType is "bzip2" then
			set o to POSIX path of (choose folder default location (POSIX file sameItemDir))
		else
			if (count nlMasta) is equal to 1 then
				set o to POSIX path of (choose file name default location (POSIX file sameItemDir) default name bxe & "." & shrinktype2)
			else
				if current row of matrix 1 of window "action_shrink" is 2 then
					set o to POSIX path of (choose file name default location (POSIX file sameItemDir) default name bxe & "." & shrinktype2)
				else
					set o to POSIX path of (choose folder default location (POSIX file sameItemDir))
				end if
			end if
		end if
	end if
	
	
	if shrinkType is "bzip2" then
		set p7String to ("bzip2 -kc --")
		set currentProcessString to (p7String & " " & quoted form of removeThis)
		batchProcess(currentProcessString)
	else
		if shrinkType is "7z" then
			set p7String to (p7String & " a -t" & shrinkType) as string
			if enableMultithreading is "1" then
				set p7String to p7String & " -mmt=" & numberofthreads
			end if
		else
			
			set p7String to (p7String & " a -t" & shrinkType) as string
			if shrinkType is "zip" then
				if enableMultithreading is "1" then
					set p7String to p7String & " -mmt=" & numberofthreads
				end if
			end if
		end if
		if the state of button "split_check" of window "action_shrink" is 1 then
			set splitAmt to the contents of text field "split_text2" of window "action_shrink" as string
			if splitAmt is "" then
				displayDialog((localized string "NOSPLITAMOUNT"), "Oh", false)
				error number -128
			end if
			set splitAmt to snr(splitAmt, ".0", "")
			set currentProcessString to (p7String & " -mx" & clevel & " " & quoted form of o & " " & quoted form of removeThis & " -v" & splitAmt & "m")
			batchProcess(currentProcessString)
		else
			set currentProcessString to (p7String & " -mx" & clevel & " " & quoted form of o & " " & quoted form of removeThis)
			batchProcess(currentProcessString)
		end if
	end if
end goAction_shrink

on goAction_expand()
	set currentAction to "expand"
	if dropKind is "RAR Archive" then
		set p7String to (quoted form of (appsup & "unrar"))
	else if dropKind is "Split Archive" then
		if useunRAR is "1" then
			set p7String to (quoted form of (appsup & "unrar"))
		else
			set p7String to (quoted form of (appsup & "7za"))
		end if
	else if dropKind is "bzip2 compressed archive" then
		set p7String to ("bunzip2 -kc")
	else
		set p7String to (quoted form of (appsup & "7za"))
	end if
	if the state of button "pw_check_expand" of window "action_expand" is 1 then
		set pw_input to (the contents of text field "pw_input_expand") of window "action_expand"
		if pw_input is "" then
			displayDialog((localized string "NOPASSPROVIDED"), "Oh", false)
			error number -128
		else
			set p7String to (p7String & " -p" & quoted form of pw_input)
		end if
	end if
	if the state of button "overwriteFiles" of window "action_expand" is 1 then
		if dropKind is not "bzip2 compressed archive" then
			set p7String to (p7String & " -y ")
		else
			set p7String to (p7String & "f")
		end if
	end if
	
	if dropKind is "bzip2 compressed archive" then
		set p7String to (p7String & " --")
	end if
	
	if defaultOutputDir is "" then
		set defaultOutputDir to "/"
	end if
	if sameItemDir is "" then
		set sameItemDir to "/"
	end if
	
	if myOutputChoice is "1" then
		try
			set g to (choose folder default location (POSIX file defaultOutputDir)) as string
		on error number -1700
			set g to (choose folder default location (POSIX file sameItemDir)) as string
		end try
	else
		set g to (choose folder default location (POSIX file sameItemDir)) as string
	end if
	set o to POSIX path of g
	
	if dropKind is "bzip2 compressed archive" then
		set currentProcessString to (p7String & " " & quoted form of removeThis)
		batchProcess(currentProcessString)
	else
		if state of (button "keepFullPaths" of window "action_expand") is 1 then
			if dropKind is "RAR Archive" then
				set currentProcessString to (p7String & " x " & quoted form of removeThis & " " & quoted form of o)
				batchProcess(currentProcessString)
			else
				if enableMultithreading is "1" then
					if dropKind is not "gzip compressed archive" then
						set p7String to p7String & " -mmt=" & numberofthreads
					end if
				end if
				set currentProcessString to (p7String & " x " & quoted form of removeThis & " " & quoted form of o)
				batchProcess(currentProcessString)
			end if
		else
			if dropKind is "RAR Archive" then
				set currentProcessString to (p7String & " e " & quoted form of removeThis & " " & quoted form of o)
				batchProcess(currentProcessString)
			else
				if enableMultithreading is "1" then
					if dropKind is not "gzip compressed archive" then
						set p7String to p7String & " -mmt=" & numberofthreads
					end if
				end if
				set currentProcessString to (p7String & " e " & quoted form of removeThis & " " & quoted form of o)
				batchProcess(currentProcessString)
			end if
		end if
	end if
end goAction_expand
------
---END GO ACTIONS
------

on getSameItemDir()
	set bxd to split(nl, "/")
	if item (count bxd) of bxd is "" then
		set bxd to reverse of rest of reverse of bxd
	end if
	set bxd to rest of bxd
	set sameItemDir to "/"
	repeat with aLoopVar from 1 to ((count bxd) - 1)
		set sameItemDir to (sameItemDir & item aLoopVar of bxd & "/") as string
	end repeat
	set sameItemDir to reverse of rest of reverse of every character of sameItemDir as string
	return sameItemDir
end getSameItemDir

on getSizeOfMe(myGivenFolder)
	try
		with timeout of 2 seconds
			set myGivenFolderSize to (do shell script "cd " & (quoted form of myGivenFolder) & ";du -c")
			set myGivenFolderSize to split((last paragraph of myGivenFolderSize), "	total") as string
		end timeout
		
		
	on error
		set myGivenFolderSize to "0"
	end try
	return myGivenFolderSize
end getSizeOfMe

on cleanMyList(theList, itemsToDelete)
	set cleanList to {}
	repeat with i from 1 to count theList
		if {theList's item i} is not in itemsToDelete then set cleanList's end to theList's item i
	end repeat
	return cleanList
end cleanMyList

on toggleViewButtons(viewResults, toggleViewBool)
	tell window "action_view"
		if toggleViewBool is false then
			set contents of table view 1 of scroll view 1 to {viewResults}
		else
			set contents of table view 1 of scroll view 1 to viewResults
		end if
		set enabled of text field "viewWindowSearch" to toggleViewBool
		set enabled of button "go_view_expand" to toggleViewBool
		set enabled of button "go_view_delete" to toggleViewBool
	end tell
	show window "action_view"
end toggleViewButtons



on go_view_expand_function()
	set p7String to (quoted form of (appsup & "7za"))
	
	set sameItemDir to getSameItemDir()
	set defaultOutputDir to the contents of text field "defaultOutput" of window "prefsWin" as string
	tell application "System Events"
		set dropKind to (kind of (POSIX file (nl) as alias))
	end tell
	
	set chosenViewItems to GetKeys()
	if content of table view 1 of scroll view 1 of window "action_view" is {} then
		error number -128
	end if
	if (count chosenViewItems) is 0 then
		error number -128
	end if
	
	try
		do shell script ("rm " & quoted form of includeFile)
	end try
	try
		repeat with aZib from 1 to (count chosenViewItems)
			do shell script ("echo " & quoted form of (item aZib of chosenViewItems) & " >> " & quoted form of includeFile)
		end repeat
	on error
		error number -128
	end try
	
	
	set currentAction to "expand"
	if (count GetKeys()) is greater than 1 then
		displayDialog("You can only quick look at one item at a time.", "Oh", false)
		error number -128
	end if
	if dropKind is "RAR Archive" then
		set p7String to (quoted form of (appsup & "unrar"))
	else if dropKind is "Split Archive" then
		if useunRAR is "1" then
			set p7String to (quoted form of (appsup & "unrar"))
		else
			set p7String to (quoted form of (appsup & "7za"))
		end if
	else
		set p7String to (quoted form of (appsup & "7za"))
	end if
	
	
	if defaultOutputDir is "" then
		set defaultOutputDir to "/"
	end if
	if sameItemDir is "" then
		set sameItemDir to "/"
	end if
	if isQuickLook is true then
		set g to myQuickLookTempDir
	else
		if myOutputChoice is "1" then
			set g to (choose folder default location (POSIX file defaultOutputDir)) as string
		else
			set g to (choose folder default location (POSIX file sameItemDir)) as string
		end if
	end if
	set o to POSIX path of g
	
	if dropKind is not "RAR Archive" then
		if enableMultithreading is "1" then
			if dropKind is not "gzip compressed archive" then
				set p7String to p7String & " -mmt=" & numberofthreads
			end if
		end if
		if viewPassword is true then
			set currentProcessString to (p7String & " x -p" & quoted form of pwd & " " & quoted form of removeThis & " " & quoted form of o & " -i" & quoted form of ("@" & includeFile))
		else
			set currentProcessString to (p7String & " x " & quoted form of removeThis & " " & quoted form of o & " -i" & quoted form of ("@" & includeFile))
			
		end if
	else
		if viewPassword is true then
			set currentProcessString to (p7String & " x -p" & quoted form of pwd & " " & quoted form of removeThis & " " & quoted form of o & " -n" & quoted form of ("@" & includeFile))
		else
			set currentProcessString to (p7String & " x " & quoted form of removeThis & " " & quoted form of o & " -n" & quoted form of ("@" & includeFile))
		end if
	end if
	set currentProcessString to (currentProcessString & " -y")
	batchProcess(currentProcessString)
	if isQuickLook is true then
		set quickLookFile to (o & (item 1 of chosenViewItems)) as string
		quickLookMe(quickLookFile)
	end if
end go_view_expand_function

on quickLookMe(the_file)
	set the_path to quoted form of (POSIX path of the_file) as string
	do shell script ("qlmanage -p " & the_path)
end quickLookMe