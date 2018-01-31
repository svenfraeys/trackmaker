--userInterface
try(destroydialog TrackMaker_Rollout)catch()

rcmenu RC_TrackMaker_MainMenuSettings(
	menuItem mi_Settings "Settings"
	menuItem mi_About "About"
	
	on mi_About picked do(
		createDialog TrackMaker_About_Rollout
	)
	on mi_Settings picked do(
		createDialog TrackMaker_Settings_Rollout
	)
)

rollout TrackMaker_Rollout "Track Maker" width:300(
	local m_ImageFolder
	local m_WindowSaver_TrackMaker
	local m_SplineObj
	local m_TrackObj
	fn splineFilter obj=(
		if(obj == m_TrackObj)then(
			return false
		)
		if(superClassOf obj == shape)then(
			return true	
		)else(
			return false
		)
	)
	
	fn trackFilter obj=(
		if(obj == m_SplineObj)then(
			return false
		)
		return true
	)
	
	
	
	
	local buttonSize = [100,30]
	local m_UIMessageLabel_TrackMaker
	dotNetControl Text_Message "system.windows.forms.label" text:"Message" pos:[0,0] width:(300-24) height:15
	dotnetcontrol pictureBox_Settings "system.windows.forms.picturebox"  width:24 height:24 pos:[TrackMaker_Rollout.width-24,0]
	
	
	
	
	
	
	local offsetValue = [40,0]
	
	
	button btn_QuickBuild "Build Track" width:buttonSize[1] height:buttonSize[2] align:#center
	group "Track"(
		label lbl_Axis "Axis" across:3
		radiobuttons radioXYZ  labels:#("X","Y","Z") align:#left columns:3
		checkbox checkbox_Flip "Flip"
		
		spinner spinner_Size "Size" across:2 range:[1,99999999999,5]
		button btn_EsitmateSize "Estimate"
		checkbox checkbox_InheritRotation "Inherit Rotation" align:#center offset:[-60,0] checked:true
	)
	button btn_MakeControllers "Make Controllers" width:buttonSize[1] height:buttonSize[2] across:2
	button btn_SnapShot "SnapShot" width:buttonSize[1] height:buttonSize[2]
	
	
	
	fn SetStep1=(
		
		
		
		spinner_Size.enabled = false
		lbl_Axis.enabled = false
		radioXYZ.enabled = false
		checkbox_Flip.enabled = false
		btn_EsitmateSize.enabled = false
		checkbox_InheritRotation.enabled = false
		btn_SnapShot.enabled = false
		btn_MakeControllers.enabled = false
		radioXYZ.state = 1
		checkbox_Flip.checked = false
	)
	
	fn UnSetStep2=(
		spinner_Size.enabled = false
		btn_EsitmateSize.enabled = false
		checkbox_InheritRotation.enabled = false
		btn_SnapShot.enabled = false
		btn_MakeControllers.enabled = false
		lbl_Axis.enabled = true
		radioXYZ.enabled = false
		radioXYZ.state = 1
		checkbox_Flip.checked = false
		checkbox_Flip.enabled = false
	)
	
	fn SetStep2=(
		lbl_Axis.enabled = true
		radioXYZ.enabled = true
		spinner_Size.enabled = true
		btn_EsitmateSize.enabled = true
		checkbox_InheritRotation.enabled = true
		btn_SnapShot.enabled = true
		btn_MakeControllers.enabled = true
		radioXYZ.state = 1
		checkbox_Flip.checked = false
		checkbox_Flip.enabled = true
	)
	
	fn UpdateLiveEdit=(
		sizeValue = m_TrackMaker_System.GetSizeObjectValue()
		spinner_Size.value = sizeValue
-- 		m_TrackMaker_System.UpdateSize
	)
	
	on pictureBox_Settings MouseClick _args do(
		dpos = getdialogpos TrackMaker_Rollout
		
		pictureBox_Settings
		newPos = dpos + (pictureBox_Settings.pos) + [0, 46]
		
		popupmenu RC_TrackMaker_MainMenuSettings pos:newPos
	)
	
	on TrackMaker_Rollout open do(
		m_ImageFolder = #userScripts
		
		userScriptFolder = (symbolicPaths.getPathValue("$userScripts")+"\\")
		imageClass = dotnetclass "System.Drawing.Image"
		imageObj = imageClass.FromFile (userScriptFolder + @"TrackMaker\images\settings.png")
		pictureBox_Settings.image = imageObj
		
	
		m_WindowSaver_TrackMaker = WindowSaver_TrackMaker()
		m_WindowSaver_TrackMaker.onOpen "$userScripts/TrackMaker/Settings.ini" TrackMaker_Rollout
		m_UIMessageLabel_TrackMaker = UIMessageLabel_TrackMaker()
		m_UIMessageLabel_TrackMaker.Initiate Text_Message
		SetStep1()
		
		d = (windows.getChildHWND 0 TrackMaker_Rollout.title)[1]
		WM_SETICON = 0x0080
		ICON_SMALL = 0
		icon = dotnetobject "System.Drawing.Icon" (userScriptFolder + @"TrackMaker\images\trackMaker.ico")
		
		windows.SendMessage d WM_SETICON ICON_SMALL icon.handle
		
	)
	
	
	
	
	
	fn ChangeTrackAxis=(
		_arg = radioXYZ.state
		if(_arg == 1)then(
			m_TrackMaker_System.ChangeAxis "X" checkbox_Flip.checked
		)
		if(_arg == 2)then(
			m_TrackMaker_System.ChangeAxis "Y" checkbox_Flip.checked
		)
		if(_arg == 3)then(
			m_TrackMaker_System.ChangeAxis "Z" checkbox_Flip.checked
		)
		UpdateLiveEdit()
	)
	on checkbox_Flip changed _arg do(
		ChangeTrackAxis()
	)
	
	
	
	on radioXYZ changed _arg do(
		ChangeTrackAxis()
		
	)
	
	on btn_SnapShot pressed do(
		obj = m_TrackMaker_System.SnapShotTrack()
		select obj
	)
	
	on checkbox_InheritRotation changed _state do(
		m_TrackMaker_System.SetInheritRotation _state
		ChangeTrackAxis()
	)
	
	on btn_EsitmateSize pressed do(
		m_TrackMaker_System.EstimateSize()
		UpdateLiveEdit()
	)
	
	
	
	
	on spinner_Size changed _value do(
		m_TrackMaker_System.UpdateSize _value
	)
	
	fn SetMessage _messageStr state:true=(
		m_UIMessageLabel_TrackMaker.SetMessage _messageStr style:state
	)
	
	on btn_MakeControllers pressed do(
		res = m_TrackMaker_System.MakeControllers()
		if(res)then(
			SetMessage "Controllers Created" state:true
		)else(
			SetMessage "Could not make controllers" state:false
		)
		m_TrackMaker_System.ReInitData()
		UnSetStep2()
		
	)
	
	
	
	fn BuildIt=(
-- 		spline
-- 		track
-- 		if(superclassof selection[1] == shape)then(
-- 			spline = selection[1]
-- 			track = selection[2]
-- 		)else(
-- 			spline = selection[2]
-- 			track = selection[1]
-- 		)
-- 		m_TrackMaker_System.CreateTrack spline track
		
-- 		selection[2]
		
		if(m_SplineObj == undefined)then(
			SetMessage "No Spline Was Selected" state:false
			return false
		)
		if(isdeleted m_SplineObj)then(
			SetMessage "Spline Object Could Not Be Found" state:false
			return false
		)
		
		if(m_TrackObj == undefined)then(
			SetMessage "No Track Was Selected" state:false
			return false
		)
		if(isdeleted m_TrackObj)then(
			SetMessage "Track Object Could Not Be Found" state:false
			return false
		)
		
		m_TrackMaker_System.CreateTrack m_SplineObj #(m_TrackObj)
		
		UpdateLiveEdit()
		return true
	)
	
	
	
	on btn_QuickBuild pressed do(
		selArr= (selection as array)
		if(selArr.count < 2)then(
			SetMessage "Error : Select at least 2 objects"
			return false
		)
		for obj in selArr do(
			if(isdeleted obj)then(
				SetMessage "Object could not be found"
				return false
			)
		)
		shapeObj
		meshObjArr = #()
		foundShape = false
		for obj in selArr do(
			
			if(superClassOf obj == shape and foundShape == false)then(
				shapeObj = obj
				foundShape = true
			)else(
				append meshObjArr obj
			)
		
				
			
		)
		if(shapeObj == undefined)then(
			SetMessage "No Spline was found"
			return false
		)
		
		
		m_TrackMaker_System.CreateTrack shapeObj meshObjArr
		UpdateLiveEdit()
		
		SetMessage "Track Created" state:true
		SetStep2()
		
	)
	
	on TrackMaker_Rollout close do(
		m_WindowSaver_TrackMaker.onClose()
		m_TrackMaker_System.Destroy()
	)
	
)

createdialog TrackMaker_Rollout pos:[50,200]
