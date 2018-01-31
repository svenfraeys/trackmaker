try(destroydialog TrackMaker_Settings_Rollout)catch()
rollout TrackMaker_Settings_Rollout "Settings" width:200 (
	local m_This = TrackMaker_Settings_Rollout
	local m_SettingIni = "$userScripts/TrackMaker/Settings.ini"
	group "Update"(
		checkbox checkbox_AutoUpdate "Auto Update" across:1 offset:[0,6]
		label lbl_Update "" across:2 align:#left offset:[0,9]
		button btn_Update "Update" width:60 height:30 align:#right
	)
	
	label l1 ""
	button btn_Close "Close" width:100 height:30 align:#right
	
	on TrackMaker_Settings_Rollout open do(
		autoUpdateStr = (getinisetting m_SettingIni "settings" "autoUpdate")
		if(autoUpdateStr == "true")then(
			checkbox_AutoUpdate.checked = true
		)
		--m_AutoUpdate_TrackMaker.IsUpdateAvailable()
	)
	
	on btn_Update pressed do(
		res = m_AutoUpdate_TrackMaker.CheckUpdate()
		if(res == false)then(
			lbl_Update.text = "No Updates Available"
		)
		
	)
	
	on checkbox_AutoUpdate changed _val do(
		setinisetting m_SettingIni "settings" "autoUpdate" (_val as string)
	)
	
	on btn_Close pressed do(
		destroydialog m_This
	)
	
)
--createdialog TrackMaker_Settings_Rollout