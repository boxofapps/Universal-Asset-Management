--clearlistener()
(
global uamProp, uamAsset
struct uamProp (name, value)
struct uamAsset (
	properties = #(),
	fn getPropertyValue propertyName = 
	(
		local property = (for p in properties where matchpattern p.name pattern:propertyName collect p)[1]
		if property != undefined do return property.value
	)
)

local uamConfigFileFolder = getFilenamePath (getThisScriptFilename()) 
local uamConfigFile = uamConfigFileFolder + "ua.config"
local uamConfigFileContent = (dotnetClass "System.IO.File").ReadAllLines uamConfigFile

global boa
struct boaStruct (
	uam = (struct uam (
		-- Config
		debugLevel = 1,
		rootFolder = uamConfigFileContent[1],
		sharedFolder = uamConfigFileFolder + @"adapters\Shared Libraries\*.*",
		adaptersFolder = uamConfigFileFolder + @"adapters\*.*",
		--
		
		-- cached list of assets
		assets = #(),
		-- list of adapters currently registered. Find out if there is a more appropriate programming term for this as I go
		adapters = #(),
		
		-- this function just checks if the adapter already exists to avoid adding same adapter twice, right now checking by input output name, maybe just check for structure type later? Replace old adapter might also make more sense
		fn registerAdapter theAdapter =
		(
			local alreadyExists = (for i in adapters where matchpattern i.assetInputType pattern:theAdapter.assetInputType and matchpattern i.assetOutputType pattern:theAdapter.assetOutputType collect i).count > 0
			if not alreadyExists do append adapters theAdapter
		),
		
		-- reads the properties line by line spliting by ":" very basic but good for now
		fn getConfigProperties theFilePath =
		(
			local properties = #()
			local propertyLines = (dotnetClass "System.IO.File").ReadAllLines theFilePath
			
			for i = 1 to propertyLines.count do 
			(
				local nameValueStringArray = filterString propertyLines[i] ":"
				append properties (uamProp nameValueStringArray[1] nameValueStringArray[2])
			)
			
			return properties
		),
		
		-- override + add one list of properties on another as a basic cascade system if I can call it like that
		fn overrideOrAddProperties cascadeProperties overrideProperties =
		(
			-- TODO: do proper override process if there is a property with same name
			cascadeProperties + overrideProperties
		),
		
		-- main querying function for now, example: boa.uam.get("AssetType:Model;Tag:Chair")
		fn get getString = 
		(
			local getAssets = #()
			local queries = #()
			local propertyLines = filterString getString ";"
			for i = 1 to propertyLines.count do 
			(
				local nameValueStringArray = filterString propertyLines[i] ":"
				append queries (uamProp nameValueStringArray[1] nameValueStringArray[2])
			)
			
			for a in assets do
			(
				local pass = true
				
				--print ("queries count: " + (queries.count as string))
				for q in queries where pass do
				(
					local aQueryProperty = (for ap in a.properties where matchpattern ap.name pattern:q.name collect ap)[1]
					if aQueryProperty == undefined then
					(
						pass = false
					)
					else
					(
						pass = matchpattern (aQueryProperty.value as string) pattern:(q.value) --ignoreCase:false --(aQueryProperty.value as string) == q.value
					)
				)
				
				if pass do append getAssets a
			)
			
			return getAssets
		),
		
		-- folder and file scanning logic, idea is that each config leads to the next, configs should have enough options to map your mind workflow in file systems.
		fn processAssetFolderConfigs theFolder =
		(
			folderArray = #(#(theFolder,#())) --GetDirectories (theFolder + "*")
			
			for fa in folderArray do
			(
				f = fa[1]
				passedProperties = fa[2]
				if debugLevel > 1 do print ("processing " + f)
				
				-- get all config files from root folder
				local configSetsToProcess = #(passedProperties)
				local configFiles = getFiles (f + "*.boaassets")
				
				-- process config files found in the current folder 1 by one
				for cfgf in configFiles do
				(
					local configProps = boa.uam.getConfigProperties cfgf --ignore "cascading" for now --overrideOrAddProperties passedProperties (boa.uam.getConfigProperties cfgf)
					
					-- if config file has instructions on how to navigate the folders up, process the instructions and add the folders to the array
					local includeFoldersPattern = (for i in configProps where matchpattern i.name pattern:"includeFolders" collect i.value)[1]
					-- Remove includeFolders as we don't want to cascade this property (for now)
					for i = configProps.count to 1 by -1 where matchpattern configProps[i].name pattern:"includeFolders" do deleteItem configProps i
					if includeFoldersPattern != undefined then
					(
						-- Split in case we have folders specified by one by one separated by commas
						for fpsplit in filterstring includeFoldersPattern "," do
						(
							local includeFolders = (getDirectories (f + fpsplit))
							for f2 in includeFolders do appendifunique folderArray #(f2, configProps)
							--join folderArray (getDirectories (f + includeFolders))
						)
					)
					-- if includeFolders was not found then we are just processing the files in the current folder
					else
					(
						append configSetsToProcess configProps
					)
				)
				
				for configSet in configSetsToProcess do
				(
					local configProps = configSet
					
					-- if config has a file filter then we will go through the files that match the filter
					local assetFilter = (for i in configProps where matchpattern i.name pattern:"filter" collect i.value)[1]
					if assetFilter != undefined do
					(
						if debugLevel > 1 do print assetFilter
						
						local assetInputType = (for i in configProps where matchpattern i.name pattern:"assetInputType" collect i.value)[1]
						local assetOutputType = (for i in configProps where matchpattern i.name pattern:"assetOutputType" collect i.value)[1]
						
						-- check if we have an adapter to handle this asset type
						local adapter = (for i in boa.uam.adapters where (matchpattern i.assetInputType pattern:assetInputType) and (matchpattern i.assetOutputType pattern:assetOutputType) collect i)[1]
						if adapter != undefined do
						(
							-- get the list of files that are asset sources based on filter
							local assetSourceFiles = getFiles (f + assetFilter)
							if debugLevel > 1 do print assetSourceFiles.count 
							
							-- process asset source file through adapter and retrieve the specialized asset structs from it
							for af in assetSourceFiles do
							(
								local assets = adapter.process af configProps
								join boa.uam.assets assets
							)
						)
					)
				)
				
			)
		),
		
		fn scan =
		(
			-- include shared libraries in the shared libraries folder
			for f in (getFiles sharedFolder) do
			(
				filein f
			)
			
			-- include adapters in the adapters folder
			for f in (getFiles adaptersFolder) do
			(
				filein f
			)
			
			-- scan the file system for assets
			processAssetFolderConfigs rootFolder
		)
		
	);)(),
		
	-- Code executed once struct is instanced
	on create do 
	(
		print "-- Box of Apps: Universal Asset API Initialized. To access use \"boa.uam\" commands. --"
		
		
		--ua.scan() -- not working and I don't know why yet
	)
)

boa = boaStruct()
boa.uam.scan()

-- Move this to "on create do" once figure out how to perform scan while in the strcut
if boa.uam.debugLevel > 0 do
(
	local assetTypes = #()
	for i in boa.uam.assets do 
	(
		appendifunique assetTypes (i.getPropertyValue "AssetType")
	)
	
	print "-- Summary of assets:"
	for i in assetTypes do 
	(
		
		print (i + " Assets Total: " + ((boa.uam.get ("AssetType:"+i)).count as string))
	)
)

)
--clearlistener()
--a = (boa.uam.get "ColorName:ABYSS")[1].getLinearColor()
--b = (boa.uam.get "AssetType:Model")[1].GetPropertyValue "SourcePath"
