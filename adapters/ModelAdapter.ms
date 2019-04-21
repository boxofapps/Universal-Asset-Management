(
	
struct uamModelAsset (
	private
	base=uamAsset(),
	
	public
	-- Default uamAsset Members that are required
	properties = #(),
	fn getPropertyValue propertyName = 
	(
		local property = (for p in properties where p.name == propertyName collect p)[1]
		if property != undefined do return property.value
	),
	--
	
	fn merge = 
	(
		boaModelF.merge (getPropertyValue "SourcePath")
	)
)

struct uamModelAdapter (
	assetInputType = "Model",
	assetOutputType = "Model",
	fn process theFilePath cascadeProperties =
	(
		local assets = #()
		
		local properties = #()
		append properties (uamProp "SourcePath" theFilePath)
		append properties (uamProp "AssetType" "Model")
		local asset = uamModelAsset()
		asset.properties = boa.uam.overrideOrAddProperties cascadeProperties properties
		append assets asset
		
		return assets
	)
)

boa.uam.registerAdapter (uamModelAdapter())

)