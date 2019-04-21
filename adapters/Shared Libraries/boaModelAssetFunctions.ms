struct modelAssetFunctions
(
	
	fn GroupAndClose thenodes = 
	(
		Leaders = for o in thenodes where (not isgroupmember o and isgrouphead o) or (not isgrouphead o and not isgroupmember o) collect o
		if leaders.count != 1 then 
		(
			for o in thenodes do (if isopengroupHead o do setGroupOpen o false) -- close groups
			group thenodes
			select thenodes
			Leaders = for o in selection where ((o.parent == undefined or isopengroupmember o) and (not isOpenGroupHead o)) collect o 
		) -- END CHECK
		else 
		(
			for o in thenodes do (if isopengroupHead o do setGroupOpen o false) -- close groups
		)
		return leaders[1] --return group head
	),
	
	fn displayAsBox thenodes thestate =
	(
		case thestate of 
		(
			"toggle":
			for i in thenodes do
			(
				if (superclassof i) == GeometryClass do
				(
					if (classof i) == vrayproxy then
					(
						if i.display == 0 then i.display = 1
						else	i.display = 0
					)
					else 
					(
						if i.boxmode == true then i.boxmode = false
						else	i.boxmode = true
					)
				)
			)
				
			"on":
			for i in thenodes do
			(
				if (superclassof i) == GeometryClass do
				(
					if (classof i) == vrayproxy then
					(
						i.display = 0
					)
					else 
					(
						i.boxmode = true
					)
				)
			)
				
			"off":
			for i in thenodes do
			(
				if (superclassof i) == GeometryClass do
				(
					if (classof i) == vrayproxy then
					(
						i.display = 1
					)
					else 
					(
						i.boxmode = false
					)
				)
			)
		)
	),

	fn merge thepath ignoreSettings:false = --  RETURN = merged mesh selected
	(
		------------------------------------------------------------------------
		-- INTERFACE SETTINGS-------------------------------------------
		------------------------------------------------------------------------
		local showAsBox = false --hcgab.getDN_CHKstate "hcgab_merge_GBgeneral_CHK_DispAsBox"
		--merge settings
		local resettransformations = false --hcgab.getDN_CHKstate "hcgab_merge_GBgeneral_CHK_ResetTransf"
		local useCustomPivot = false --hcgab.getDN_CHKstate "hcgab_pivotsettings_GB_general_checkbox_enabled"
		----------------------------------------------------------------------
		
		local mergedobjects = undefined
		
		local oldObjects = objects as array
		mergeMAXFile thepath #select #renameMtlDups #mergedups #noRedraw quiet:true
		mergedobjects = for o in objects where findItem oldObjects o == 0 collect o
		select mergedobjects
		
		--mergedobjects = selection
		
		if ignoreSettings == false do
		(
			if selection.count != 0 do
			(
				-- RESET TRANSFORMATIONS
				if resettransformations then ResetTransform mergedobjects
				
				-- GROUP AND CLOSE
				grouphead = (GroupAndClose selection)
				
				mergedobjects = selection
				
				-- DISPlAY AS BOX
				if showAsBox then
				(
					displayAsBox mergedobjects "on"
				) 
				else 
				(
					displayAsBox mergedobjects "off"
				)
				
				--### END SETTINGS
				
			)
		)
		
		-- weird old bug have to check what is the problem again
		/*if findstring thepath "Design Connected" != undefined do
		(
			print "hcgMergeMAXFile -> it's design connected"
			for o in mergedobjects do o.scale = [1,1,1]
		)*/
		
		setUserProp mergedobjects "hcgab_modelpath" thepath
		
		return mergedobjects
	)
)
global boaModelF
boaModelF = modelAssetFunctions()