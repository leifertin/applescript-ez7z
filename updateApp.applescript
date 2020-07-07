-- updateApp.applescript
-- Ez7z

--  Created by Leif Heflin on Sat Aug 20 2005.
--  Copyright 2010 Leifertin. All rights reserved.

global theDownloadGo, appsup, pathTOCURLfile, pathTOCURLedfile, thedownloadsite, ver, update_v, usrEmail, usrSerial, prefsfileR, prefsFile

property current_version : "2.13"
property homeRootURL : "http://grayarea.be/app/eZ7z/"

on updateMePlus(isLaunch)
	initializeMe_SM()
	
	if getGoAhead() is 0 then
		tell window "registerWindow"
			set the contents of text field "emailAdd" to "Email Address"
			set the contents of text field "serialNum" to "Serial Number"
		end tell
	end if
	
	set visible of progress indicator 1 of window "updatewindow" to false
	set the text color of text view 1 of scroll view 1 of window "updatewindow" to "white"
	set title of button 1 of window "updatewindow" to (localized string "CLOSE_TEXT")
	set the contents of text view 1 of scroll view 1 of window "updatewindow" to ""
	
	set update_f to "http://grayarea.be/app/eZ7z/toDoList.html" as string
	try
		do shell script ("rm " & quoted form of (pathTOCURLedfile))
	end try
	set continueUpdate to false
	try
		set pingMySite to (do shell script "ping -t3 -o grayarea.be") as string
		do shell script ("perl " & quoted form of pathTOCURLfile & " " & quoted form of update_f & " " & quoted form of (pathTOCURLedfile))
		set continueUpdate to true
	on error
		lastCheckForConnection()
	end try
	
	if continueUpdate is true then
		set update_c to do shell script ("cat " & quoted form of (pathTOCURLedfile))
		do shell script ("rm " & quoted form of (pathTOCURLedfile))
		set current_version_int to cv_string2int(current_version)
		----
		----
		set update_c_download to (item 2 of split(update_c, "<!--download-->")) as string
		set update_c_complete to (item 2 of split(update_c, "<!--complete-->")) as string
		set update_c_incomplete to (item 2 of split(update_c, "<!--incomplete-->")) as string
		
		set update_c to ""
		
		set update_v to (item 1 of split(update_c_download, "<br><br>")) as string
		set update_v to (last item of split(update_v, "<!--v")) as string
		set update_v to split(update_v, "-->") as string
		set update_v_int to cv_string2int(update_v)
		--GOT VERSION
		
		set changelog_text to update_c_complete
		set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
		try
			set changelog_text_splitter to item 2 of split(changelog_text, ("<h4>")) as string
			set changelog_text_splitter to item 1 of split(changelog_text_splitter, (" />")) as string
			set changelog_text to snr(changelog_text, changelog_text_splitter, "") as string
		end try
		
		set changelog_text to snr(changelog_text, "	", "")
		set changelog_text to snr(changelog_text, "<li>", " • ")
		set changelog_text to snr(changelog_text, "</li>", "")
		set changelog_text to snr(changelog_text, "<i>", "(")
		set changelog_text to snr(changelog_text, "</i>", ")")
		set changelog_text to snr(changelog_text, "<ul>", "<br>")
		set changelog_text to snr(changelog_text, "</b>", "")
		set changelog_text to snr(changelog_text, "</ul>", "<br>")
		set changelog_text to snr(changelog_text, "<b>", "")
		set changelog_text to snr(changelog_text, "</ul>", "")
		set changelog_text to snr(changelog_text, "<br><br>", "	")
		set changelog_text to snr(changelog_text, "<div style=\"margin-top:5px; display:none; border:0px;\"><p>", "")
		set changelog_text to snr(changelog_text, "<h4> />", "")
		set changelog_text to snr(changelog_text, "</h4>", "")
		set changelog_text to snr(changelog_text, "</p>", "")
		set changelog_text to snr(changelog_text, "</div>", "")
		
		set update_v_int_1 to (item 1 of split(update_v_int, ",")) as string
		set current_version_int_1 to (item 1 of split(current_version_int, ",")) as string
		set update_v_int_2 to (item 2 of split(update_v_int, ",")) as string
		set current_version_int_2 to (item 2 of split(current_version_int, ",")) as string
		
		set update_v_int_2 to split(update_v_int_2, ".") as string
		set current_version_int_2 to split(current_version_int_2, ".") as string
		
		--MATCH 1st Items
		if (count (every character of current_version_int_1)) is greater than (count (every character of update_v_int_1)) then
			repeat with artichoke from 1 to ((count (every character of current_version_int_1)) - (count (every character of update_v_int_1)))
				set update_v_int_1 to (update_v_int_1 & "0") as string
			end repeat
		else if (count (every character of current_version_int_1)) is less than (count (every character of update_v_int_1)) then
			repeat with artichoke from 1 to ((count (every character of update_v_int_1)) - (count (every character of current_version_int_1)))
				set current_version_int_1 to (current_version_int_1 & "0") as string
			end repeat
		end if
		
		--MATCH 2nd Items
		if (count (every character of current_version_int_2)) is greater than (count (every character of update_v_int_2)) then
			repeat with artichoke from 1 to ((count (every character of current_version_int_2)) - (count (every character of update_v_int_2)))
				if update_v_int_2 is not "!" then
					set update_v_int_2 to (update_v_int_2 & "0") as string
				end if
			end repeat
		else if (count (every character of current_version_int_2)) is less than (count (every character of update_v_int_2)) then
			repeat with artichoke from 1 to ((count (every character of update_v_int_2)) - (count (every character of current_version_int_2)))
				if current_version_int_2 is not "!" then
					set current_version_int_2 to (current_version_int_2 & "0") as string
				end if
			end repeat
		end if
		
		
		if (update_v_int_1) is greater than (current_version_int_1) then
			set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
			finishUpdateLoad(update_c_download)
			show window "updatewindow"
		else if (update_v_int_1) is less than (current_version_int_1) then
			set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
			set contents of (text field 1 of window "updatewindow") to (localized string "RUNNINGNEWEST")
			if isLaunch is false then
				show window "updatewindow"
			end if
		else if (update_v_int_1) is equal to (current_version_int_1) then
			--CHECK OTHER SIDE
			if (update_v_int_2) is equal to (current_version_int_2) then
				set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
				set contents of (text field 1 of window "updatewindow") to (localized string "RUNNINGNEWEST")
				if isLaunch is false then
					show window "updatewindow"
				end if
			else if (update_v_int_2) is "!" then
				set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
				finishUpdateLoad(update_c_download)
				show window "updatewindow"
			else if (current_version_int_2) is "!" then
				set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
				set contents of (text field 1 of window "updatewindow") to (localized string "RUNNINGNEWEST")
				if isLaunch is false then
					show window "updatewindow"
				end if
			else if (update_v_int_2 as integer) is greater than (current_version_int_2 as integer) then
				set changelog_text to item 1 of split(changelog_text, ("<!--v" & current_version & "-->")) as string
				finishUpdateLoad(update_c_download)
				show window "updatewindow"
			else if (update_v_int_2 as integer) is less than (current_version_int_2 as integer) then
				set changelog_text to item 1 of split(changelog_text, ("<!--v" & update_v & "-->")) as string
				set contents of (text field 1 of window "updatewindow") to (localized string "RUNNINGNEWEST")
				if isLaunch is false then
					show window "updatewindow"
				end if
			end if
		end if
		
		set changelog_text_l to every paragraph of changelog_text
		repeat with ch_loopV from 1 to (count changelog_text_l)
			if ((item ch_loopV of changelog_text_l) as string) starts with "<!--v" then
				set (item ch_loopV of changelog_text_l) to ""
			end if
		end repeat
		set changelog_text to changelog_text_l as string
		
		set changelog_text to snr(changelog_text, "<br>", "
")
	else
		set changelog_text to (localized string ("UPDATESITEDOWN"))
	end if
	set the contents of text view 1 of scroll view 1 of window "updatewindow" to changelog_text
end updateMePlus

on choose menu item theObject
	if the name of theObject is "update" then
		updateMePlus(false)
	else if the name of theObject is "homepageMenuItem" then
		open location "http://grayarea.be"
	else if the name of theObject is "contactdev" then
		open location "mailto:leifh90@gmail.com?Subject=Ez7z Feedback (v" & current_version & ")"
	end if
end choose menu item

on clicked theObject
	if the title of theObject is (localized string "CLOSE_TEXT") then
		set theDownloadGo to false
		close panel window "updatewindow"
		set title of button "downloadupdate" of window "updatewindow" to (localized string "CLOSE_TEXT")
	else if the title of theObject is (localized string "DOWNLOAD_TEXT") then
		set title of button "downloadupdate" of window "updatewindow" to (localized string "CLOSE_TEXT")
		set abxi to ("curl " & thedownloadsite & " -o " & quoted form of ((POSIX path of (path to desktop)) & "Ez7z " & update_v & ".dmg") & " &> " & quoted form of (appsup & "updateLog.txt") & " & echo $!")
		do shell script abxi
		set updatePID to result
		set theDownloadGo to true
		
		set visible of progress indicator 1 of window "updatewindow" to true
		set theDownloadGo to true
		set (the contents of text field 1 of window "updatewindow") to (localized string "DOWNLOADINGTODESKTOP")
		
		repeat until theDownloadGo is false
			delay (0.5)
			try
				set curOutUpdateFile to (do shell script "cat " & quoted form of (appsup & "updateLog.txt")) as string
				set curOutUpdateFile to (word 1 of (the last paragraph of curOutUpdateFile)) as string
			end try
			update_progress(curOutUpdateFile, 100, "updatewindow")
			set thisWeirdNumber to (100 - curOutUpdateFile)
			set (the contents of text field 1 of window "updatewindow") to ((localized string "DOWNLOADINGTODESKTOP") & thisWeirdNumber & "% " & snr((localized string "DOWNLOADINGTODESKTOP2"), "50%", ""))
			try
				((count of paragraphs in (do shell script "ps -p " & updatePID)) > 1)
			on error
				set (the contents of text field 1 of window "updatewindow") to ""
				set theDownloadGo to false
				set curOutUpdateFile to (do shell script "cat " & quoted form of (appsup & "updateLog.txt")) as string
				update_progress(0, 100, "updatewindow")
				set visible of progress indicator 1 of window "updatewindow" to false
				set title of button 1 of window "updatewindow" to (localized string "CLOSE_TEXT")
			end try
		end repeat
		try
			do shell script "kill " & updatePID
		end try
		set theDownloadGo to false
	end if
end clicked

on should close theObject
	if the name of theObject is "updatewindow" then
		try
			if theDownloadGo is true then
				do shell script "kill " & updatePID
			end if
		end try
		hide window "updatewindow"
	end if
	return false
end should close

on update_progress(iteration, total_count, windowVar)
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
end update_progress

on initializeMe_SM()
	set theDownloadGo to false
	set appsup to ((POSIX path of (path to me)) & ("Contents/Resources/")) as string
	set p7String to (appsup & "7za")
	set pathTOCURLfile to (appsup & "dp.pl")
	set pathTOCURLedfile to (appsup & "CURLfile.yah")
	set pathTOHURLfile to (appsup & "rl.pl")
	
	set prefsFile to (quoted form of (POSIX path of (path to home folder) & "Library/Application Support/Ez7z.prefs"))
	try
		set prefsfileR to do shell script "cat " & prefsFile
		set usrEmail to (item 2 of split(prefsfileR, "<userEmail>")) as string
		set usrSerial to (item 2 of split(prefsfileR, "<userSerial>")) as string
		set the contents of text field "emailAdd" of window "registerWindow" to usrEmail
		set the contents of text field "serialNum" of window "registerWindow" to usrSerial
	on error
		set usrEmail to "Email Address"
		set usrSerial to "Serial Number"
		set the contents of text field "emailAdd" of window "registerWindow" to usrEmail
		set the contents of text field "serialNum" of window "registerWindow" to usrSerial
	end try
end initializeMe_SM

on common_displayDialog(thediatext, butttext, cancelenabled)
	set otherScript to useOtherScript("EZ 7z")
	tell otherScript to displayDialog(thediatext, butttext, cancelenabled)
end common_displayDialog

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

on cv_string2int(cv_string)
	set cv_int to snr(cv_string, ",", "")
	set cv_int to snr(cv_int, "b", ",") as string
	
	if cv_int does not contain "," then
		set cv_int to (cv_int & ",!") as string
	end if
	return cv_int
end cv_string2int

on finishUpdateLoad(update_c_download)
	set contents of (text field 1 of window "updatewindow") to (localized string "YOURVERSIONTEXT") & " " & current_version & return & (localized string "CURRENTVERSION") & " " & update_v
	set update_dlURL to (item 2 of split(update_c_download, ("<!--v" & update_v & "-->")))
	set update_dlURL to (item 1 of split(update_dlURL, ("\">")))
	set update_dlURL to (item 2 of split(update_dlURL, ("<a href=\""))) as string
	set thedownloadsite to update_dlURL as string
	set title of button "downloadupdate" of window "updatewindow" to (localized string "DOWNLOAD_TEXT")
end finishUpdateLoad

on lastCheckForConnection()
	try
		set bcs to (do shell script "ping -t4 -o google.com") as string
	on error
		common_displayDialog((localized string "NOTCONNECTED"), (localized string "OKAY_TEXT"), false, "")
		error number -128
	end try
	common_displayDialog((localized string "UPDATESITEDOWN"), (localized string "OKAY_TEXT"), false, "")
	error number -128
end lastCheckForConnection

on useOtherScript(scriptNameID)
	tell me
		set otherScript to POSIX file ((appsup & "Scripts/" & scriptNameID & ".scpt") as string)
		--set otherScript to ((path for script scriptNameID) as string)
	end tell
	set otherScript to load script (otherScript)
	return otherScript
end useOtherScript

on getGoAhead()
	set theGoAhead to 0
	
	set usrEmail to snr(usrEmail, "?", "")
	set usrSerial to snr(usrSerial, "?", "")
	set usrEmail to snr(usrEmail, "&", "")
	set usrSerial to snr(usrSerial, "&", "")
	
	--if contents of text field 1 of window "main" is not "..." then
	set myHomeDate to (get (month of (current date)) as integer) as string
	set myInfoURL to (homeRootURL & "new_login.php") as string
	try
		set theResultingMonth to (do shell script ("curl --data " & quoted form of ("email=" & usrEmail & "&serial=" & usrSerial & "&month=" & myHomeDate) & " -e 'Ez7z.login' " & quoted form of myInfoURL & " -m 3")) as string
	on error
		set theResultingMonth to "15"
	end try
	
	
	if theResultingMonth is "15" then
		displayDialog((localized string "EZ7Z_SITEDOWN"), (localized string "LAME_TEXT"), false)
	else
		if (theResultingMonth as integer) is equal to (myHomeDate as integer) then
			if usrEmail contains "@" then
				if usrSerial contains "-" then
					set theGoAhead to 1
				end if
			end if
		end if
	end if
	(*else
		if usrEmail contains "@" then
			if usrSerial contains "-" then
				set theGoAhead to 1
			end if
		end if
	end if
	*)
	return theGoAhead
end getGoAhead