(
	
struct uamColorAsset (
	private
	base=uamAsset(),
	
	public
	properties = #(),
	fn getPropertyValue propertyName = 
	(
		local property = (for p in properties where p.name == propertyName collect p)[1]
		if property != undefined do return property.value
	),
	
	fn roundFloat d pre:1 =
	(
		d = (d as float)/pre
		v = if (d - (v1 = floor d)) > ((v2 = ceil d) - d) then v2 else v1 
		v*pre
	),

	fn linearFromGammaCorrected theVal =
	(
		local f = 255 * (((theVal as float)/255)^2.2)

		return (roundFloat f)
	),

	fn getLinearColor =
	(
		local c = color (linearFromGammaCorrected (getPropertyValue "ColorR")) (linearFromGammaCorrected (getPropertyValue("ColorG"))) (linearFromGammaCorrected (getPropertyValue("ColorB")))
		c2 = black
		-- subtract %4 from the LRV to compensate approx 1.6 IOR from fresnel frontal  reflection that is added on top in CG but is not removed from LRV Scanning
		c2.v = (roundFloat (((getPropertyValue "ColorLRV") - 4)/100.0*255)) 
		c2.s = c.s
		c2.h = c.h
		return c2
	)
)

struct uamColorsCSVToColorsAdapter (
	assetInputType = "ColorsCSV",
	assetOutputType = "Color",
	fn process theFilePath cascadeProperties =
	(
		local colorAssets = #()
		local csvLines = (dotnetClass "System.IO.File").ReadAllLines theFilePath
		
		-- Ignore first line as it should be the columns definitions
		for i = 2 to csvLines.count do 
		(
			local asset = uamColorAsset()
			
			local properties = #()
			append properties (uamProp "SourcePath" theFilePath)
			append properties (uamProp "AssetType" "Color")
			
			local csvLineSplit = filterString csvLines[i] ","
			for si = 1 to csvLineSplit.count do (csvLineSplit[si] = (trimright (trimleft (csvLineSplit[si]))))
			-- Id,Name,R,G,B,LRV
			append properties (uamProp "ColorId" csvLineSplit[1])
			append properties (uamProp "ColorName" csvLineSplit[2])
			append properties (uamProp "ColorR" (csvLineSplit[3] as integer))
			append properties (uamProp "ColorG" (csvLineSplit[4] as integer))
			append properties (uamProp "ColorB" (csvLineSplit[5] as integer))
			append properties (uamProp "ColorLRV" (csvLineSplit[6] as float))
			
			asset.properties = boa.uam.overrideOrAddProperties cascadeProperties properties
			append colorAssets asset
		)
		
		return colorAssets
	)
)

boa.uam.registerAdapter (uamColorsCSVToColorsAdapter())

)