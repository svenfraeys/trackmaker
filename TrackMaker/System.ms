TrackMakerCA = attributes TrackMaker
(
parameters main rollout:params
(
	percentage type:#float ui:spinner_percentage default:0
)
 
rollout params "Track Maker"
(
	spinner spinner_percentage "Percentage" type:#float range:[-999999999999999,9999999999999999,0]
)

)


struct TrackMaker_System(
	m_OrigTrack,
	m_OrigSpline,
	m_TrackObjects,
	m_ControlMaster,
	m_ConstrolMasterModifier,
	m_HelperArr,
	m_SizeObject,
	m_NewSpline,
	m_HelperRef,
	m_Axis,
	m_Flipped,
	m_OrigTracksArr,
	m_InheritRotation,
	fn RemoveHelperRef=(
		try(
		delete m_HelperRef
		)catch()
		m_HelperRef = undefined
	),
	fn GetHelperRef=(
		if(m_HelperRef == undefined)then(
			m_HelperRef = point()
		)
		if(isdeleted m_HelperRef)then(
			m_HelperRef = point()
		)
		return m_HelperRef
	),
	fn GetSizeObjectValue=(
		return m_SizeObject
	),
	fn GetSizeObject _obj axis:"X"=(
		
		bb = nodeLocalBoundingBox _obj
		
		sizeObject = 0
		if(axis == "X")then(
			sizeObject = (bb[1][1] - bb[2][1])
		)
		if(axis == "Y")then(
			sizeObject = (bb[1][2] - bb[2][2])
		)
		if(axis == "Z")then(
			sizeObject = (bb[1][3] - bb[2][3])
		)
		
		
		if(sizeObject < 0)then(
			sizeObject = sizeObject * -1
		)
		if(sizeObject < 1)then(
			sizeObject = 1
		)
		
		return sizeObject
	),
	fn ReInitData=(
		m_TrackObjects  = #()
		m_HelperArr = #()
		RemoveHelperRef()
		m_Axis = "X"
		m_Flipped = false
	),
	fn Initiate=(
		m_InheritRotation = true
		ReInitData()
	),
	fn CreateMaster=(
		
		m_ControlMaster = Circle()
		m_ControlMaster.name = uniquename ("Master_"+m_OrigTrack.name)
		m_ControlMaster.position = m_NewSpline.pos
		
		bb = nodeLocalBoundingBox m_NewSpline
		zPos = bb[1][3]
		zPos2 = bb[2][3]
		newZPos = zPos2
		
		if(zPos < newZPos)then(
			-- new Z
			newZPos = zPos
		)
		
		m_ControlMaster.position.z = newZPos
		
		
		m_ConstrolMasterModifier = (EmptyModifier())
		addmodifier m_ControlMaster m_ConstrolMasterModifier
		custAttributes.add m_ConstrolMasterModifier TrackMakerCA 
		
		
			
		m_NewSpline.parent = m_ControlMaster
	),
	
	fn GetNumObjectsNeededOnSpline _spline _size=(
		lengthVal = curveLength _spline 1
		sizeObject = _size
		m_SizeObject = sizeObject
		totalObjectsNeeded = (lengthVal / sizeObject)
	),
	
	fn WireConstraint foo=(
		PAdjust = foo.pos.controller.Path_Constraint.controller.percent
		
			WireFormula = "-(percentage + " + PAdjust as string + ") / 100"
		
			spinnerObj = m_ConstrolMasterModifier.TrackMaker[#percentage]

			pathConstraintPercentage = foo.pos.controller.Path_Constraint.controller[#Percent]

			paramWire.connect spinnerObj pathConstraintPercentage WireFormula
	),
	fn UpdatePositions=(
		for i = 1 to m_HelperArr.count do 
		(
			
			foo = m_HelperArr[i]
			
			
			
			timeLineLength = 100.0
		-------reset the initial postition
		newtime = (((i as float)) / (m_HelperArr.count as float))*timeLineLength
-- 		slidertime = newtime
		newPercent = newtime
-- 		slidertime = 0
		
		foo.pos.controller.Path_Constraint.controller.percent = newpercent
			
		)
		
	),
	fn RemoveKeys=(
		for helperObj in m_HelperArr do(
			if(isdeleted helperObj)then(
				continue
			)
			deleteKeys helperObj.pos.controller.Path_Constraint.controller.percent.keys
		)
	),
	m_TrackCounter,
	fn AddTrack=(
		m_TrackCounter += 1
		if(m_TrackCounter > m_OrigTracksArr.count)then(
			m_TrackCounter = 1
		)
		
		
		polyObj = instance (m_OrigTracksArr[m_TrackCounter])
		
		if(m_InheritRotation == false)then(
			setInheritanceFlags polyObj #{1..3,7..9}
		)
		
		append m_TrackObjects polyObj
		
		--polyObj = instance m_OrigTrack
		HelpersObj = instance (GetHelperRef())
		append m_HelperArr HelpersObj
		HelpersObj.name = uniquename ("TrackMaker_"+m_OrigTrack.name+"_")
					
		
			
		HelpersObj.transform = polyObj.transform
		origTransform = HelpersObj.transform
			
		rotationOffset = 0
			
		if(m_Flipped)then(
			rotationOffset = 180
		)
			
		if(m_Axis == "X")then(
			
			HelpersObj.rotation.x_rotation += (0 + rotationOffset)
		)
		if(m_Axis == "Y")then(
			HelpersObj.rotation.z_rotation -= (90 + rotationOffset)
			
		)
		if(m_Axis == "Z")then(
			HelpersObj.rotation.y_rotation += (90 + rotationOffset)
			
		)
		
		
		
		polyObj.parent = HelpersObj
		
		
		
		HelpersObj.transform = origTransform
		
		foo = HelpersObj
		-------set the y rotation to zero so it is orientated to the path
		foo.rotation.controller.y_rotation = 0

		-------add a list Controller
		foo.pos.controller = position_list ()
		listctrl.setname foo.pos.controller 1 "Zero"

		-------add the path Constraint
		foo.pos.controller.Available.controller = Path_Constraint ()
		foo.pos.controller.Path_Constraint.controller.path = m_NewSpline
		foo.pos.controller.Path_Constraint.controller.follow = on
		foo.pos.controller.Path_Constraint.controller.allowUpsideDown = on
		foo.pos.controller.Path_Constraint.controller.axis = 0
		foo.pos.controller.Path_Constraint.controller.axisFlip = off
-- 		deleteKeys foo.pos.controller.Path_Constraint.controller.percent.keys
	),
	fn RemoveTrack=(
		newHelperArr = #()
		objToDelete
		for i = 1 to m_HelperArr.count do(
			if(i == 1)then(
				objToDelete = m_HelperArr[i]
			)else(
				append newHelperArr m_HelperArr[i]	
			)
			
		)
		if(objToDelete != undefined)then(
			childPos = finditem m_TrackObjects (objToDelete.children[1])
			if(childPos != 0)then(
				newTrackArr = #()
				for trackObj in m_TrackObjects do(
					if(trackObj == objToDelete.children[1])then(
						continue
					)
					append newTrackArr trackObj
				)
				m_TrackObjects = newTrackArr
			)
			
				
			delete objToDelete.children
			delete objToDelete
			
		)
		m_HelperArr = newHelperArr
	),
	fn UpdateSize _value=(
		totalObjectsNeeded = GetNumObjectsNeededOnSpline m_NewSpline _value
		totalObjectsNeeded =(totalObjectsNeeded as integer)
		
		if(totalObjectsNeeded == m_HelperArr.count )then(
			
		)else if(totalObjectsNeeded < m_HelperArr.count )then(
			-- remove
			--print ("Remove : "+((m_HelperArr.count - totalObjectsNeeded) as string) )
			for i = 1 to (m_HelperArr.count - totalObjectsNeeded) do(
				
				RemoveTrack()
			)
			
		)else if(totalObjectsNeeded > m_HelperArr.count )then(
			--print ("Add : "+((totalObjectsNeeded - m_HelperArr.count)as string))
			for i = 1 to (totalObjectsNeeded - m_HelperArr.count) do(
				AddTrack()
			)
			-- add
			
		)
		UpdatePositions()
	),
	
	
	
	fn WireConstraints=(
		for foo in m_HelperArr do
		(
			if(isdeleted foo)then(
				continue
			)
			WireConstraint foo
		)
	),
	fn RemoveAllTracks=(
		while m_HelperArr.count != 0 do(
			RemoveTrack()	
		)
	),
	
	
	
	
	fn CreateTrackNodes=(
		m_TrackCounter = 0
		sizeObject = GetSizeObject m_OrigTrack axis:m_Axis
		
		totalObjectsNeeded = GetNumObjectsNeededOnSpline m_NewSpline sizeObject
		
		for i = 1 to (totalObjectsNeeded as integer) do(
			AddTrack()
		)
	),
	fn SnapShotTrack=(
		nameStr = (m_OrigSpline.name+"_track_snapshot")
		ep = editable_mesh name:(uniquename nameStr)
		converttopoly ep
		ep.transform = m_NewSpline.transform
		--print m_TrackObjects.count
		for trackObj in m_TrackObjects do(
			
			snapObj = snapshot trackObj
			ep.attach snapObj ep
		)
		return ep
	),
	
	fn CreateTrack _spline _trackArr=(
		_track = _trackArr[1]
		ReInitData()
		m_OrigTrack = _track
		m_OrigSpline = _spline
		m_OrigTracksArr = _trackArr
		select _track
		
		m_NewSpline = instance m_OrigSpline
		
		
		
		CreateTrackNodes()
		UpdatePositions()
		
		select m_NewSpline
		
	),
	
	fn ChangeAxis _newAxis _flipped=(
		RemoveAllTracks()
		m_Flipped = _flipped
		m_Axis = _newAxis
		CreateTrackNodes()
		
		UpdatePositions()
	),
	fn MakeControllers=(
		if(isdeleted m_NewSpline)then(
			return false
		)
		RemoveKeys()
		CreateMaster()
		WireConstraints()
		RemoveHelperRef()
		return true
	),
	
	fn EstimateSize=(
		UpdateSize (GetSizeObject m_OrigTrack)
	),
	fn Destroy=(
		RemoveHelperRef()
	),
	fn SetInheritRotation _value=(
		m_InheritRotation = _value
	)
)

m_TrackMaker_System = TrackMaker_System()
m_TrackMaker_System.Initiate()

/*
delete $*
delete $splineObj*
splineObj = circle()
splineObj.name = "splineObj"

delete $trackObj*
trackOBj = box()
-- trackOBj.radius = 5
 trackOBj.width = 10
 trackOBj.length = 25
 trackOBj.height = 2
trackOBj.name = "trackObj"
converttopoly trackOBj

trackOBj2 = box()
-- trackOBj.radius = 5
 trackOBj2.width = 10
 trackOBj2.length = 20
 trackOBj2.height = 2
trackOBj2.name = "trackObj2"


splineObj.rotation.y_rotation = 90


m_TrackMaker_System.CreateTrack splineObj #(trackOBj, trackOBj2)
m_TrackMaker_System.ChangeAxis "X" true

*/