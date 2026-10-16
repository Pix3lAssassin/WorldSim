extends Node

const BOX_TILE = preload("res://Scenes/box.tscn")

@export var skip: bool = false
@export var material: StandardMaterial3D
@export var seed = ""
@export var width = 256
@export var height = 256
@export var step = 127
# Depth in pixel colors 0-255
@export var oceanDepth: float = 16.0
@export var worldBoundaryStrength = 0.1
@export var worldBoundaryVariance = 0.02
@export var continentFrequency = 0.005
@export var landFrequency = 0.005
var continentNoise = FastNoiseLite.new()
var heightNoise = FastNoiseLite.new()
var rng = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if skip:
		return
	
	if seed == "":
		seed = Time.get_datetime_string_from_system(true)
	rng.seed = hash(hash(seed))
	
	# Initialize seeds for noise
	continentNoise.seed = hash(seed)
	heightNoise.seed = hash(seed)
	
	# Spikey noise for continent mask
	continentNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	continentNoise.fractal_type = FastNoiseLite.FRACTAL_FBM
	continentNoise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN
	continentNoise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE
	continentNoise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX
	continentNoise.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_PROGRESSIVE
	
	continentNoise.offset = Vector3(0, 0, 0)
	continentNoise.frequency = continentFrequency * 0.001
	
	# Smooth noise for inital land heights
	heightNoise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	heightNoise.fractal_type = FastNoiseLite.FRACTAL_FBM
	heightNoise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN
	heightNoise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE
	heightNoise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX
	heightNoise.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_PROGRESSIVE
	
	heightNoise.offset = Vector3(0, 0, 0)
	heightNoise.frequency = landFrequency * 0.0075
	#heightNoise.frequency = 0.1
	
	# Percentage of height for land and ocean
	var oceanDetail: float = 1.0 / (256.0 / oceanDepth) 
	var landDetail: float = 1.0 - oceanDetail
	
	# Arrays to store height/pixel data
	var continentMaskData = PackedByteArray()
	var continentNoiseData = PackedByteArray()
	var combinedNoiseData = PackedByteArray()
	
	# Loop to calculate land mask
	for y in height:
		for x in width:
			var xZeroDist = x / float(width)
			var xMaxDist = 1 - x / float(width)
			var yZeroDist = y / float(height)
			var yMaxDist = 1 - y / float(height)
			# Calculate the distance to the closest edge of the current pixel location
			var closestEdgeDist = minf(minf(xZeroDist, xMaxDist), minf(yZeroDist, yMaxDist))
			closestEdgeDist = maxf(0, closestEdgeDist + rng.get_noise_2d(x, y) * worldBoundaryVariance)
			
			# Store noise values for debug (Noise values generally between -1 and 1)
			var val: float = continentNoise.get_noise_2d(x, y) 
			continentNoiseData.append(val * 127 + 127)
			
			# Calculate height value of pixel with falloff for map border taken into account
			var bump = (val * 127 + 127) * minf(closestEdgeDist * (1 / worldBoundaryStrength), 1)
			
			
			if step >= 0:
				
				# Continent mask
				var result = 0
				if bump > step:
					result = 255
				
				continentMaskData.append(result)
			else:
				continentMaskData.append(bump)
	
	# Save continent mask
	var continentMaskImage = Image.create_from_data(width, height, false, Image.FORMAT_L8, continentMaskData)
	continentMaskImage.save_png("res://Textures/Noise/continentMask.png")
	
	# Resize image for blurring/smoothing
	var minSize = 128
	continentMaskImage.resize(minSize, minSize)
	var maskData = continentMaskImage.get_data()
	var finalMaskData = PackedByteArray()
	
	# Blur downsized image
	var blurSize: float = 25.0
	var blurOffset: int = blurSize / 2
	var blurIntensity: float = 1.0 / (blurSize * blurSize)
	for y in continentMaskImage.get_height():
		print(y)
		for x in continentMaskImage.get_width():
			var b: float = 0.0
			
			# Blur kernel loop
			for m in range(-blurOffset, blurOffset + 1):
				for n in range(-blurOffset, blurOffset + 1):
					var c = clamp(y + m, 0, continentMaskImage.get_height() - 1)
					var d = clamp(x + n, 0, continentMaskImage.get_width() - 1)
					var index = c * continentMaskImage.get_width() + d
					
					b += float(maskData.get(index)) * blurIntensity
					
			
			finalMaskData.append(b)
	
	# Resize image to initial size and save it
	continentMaskImage.set_data(minSize, minSize, false, Image.FORMAT_L8, finalMaskData)
	continentMaskImage.resize(height, width, Image.INTERPOLATE_CUBIC)
	continentMaskImage.save_png("res://Textures/Noise/continentMaskBlurred.png")
	
	# Find min and max for normalizing land noise
	var minNoise = 1;
	var maxNoise = -1;
	for y in height:
		for x in width:
			var heightVal: float = heightNoise.get_noise_2d(x, y)
			if heightVal < minNoise:
				minNoise = heightVal
			if heightVal > maxNoise:
				maxNoise = heightVal
	
	# Calculate normalized heights
	var heightNoiseData = PackedByteArray()
	var noiseDist = 1 / (maxNoise - minNoise)
	for y in height:
		for x in width:
			var heightVal: float = (heightNoise.get_noise_2d(x, y) - minNoise) * noiseDist
			
			var landHeight: float = clampf(heightVal * 256, 0, 255)
			heightNoiseData.append(landHeight)
	
	# Combine mask, slope blur, and final noise texture for combined heightmap
	for y in height:
		for x in width:
			var index = y * width + x
			var mask = continentMaskData.get(index)
			var imageBlur = continentMaskImage.get_data().get(index)
			var blur: float = float(imageBlur) / 256.0
			var landHeight = heightNoiseData.get(index)
			
			var finalHeight = clampf(landHeight * oceanDetail + (oceanDepth * 1 * blur), 0, oceanDepth);
			if mask > 0:
				if blur < 0.5:
					print(x, ", ", y, " ", blur)
				finalHeight = clampf(landHeight * landDetail * ((blur - 0.5) * 2) + oceanDepth, oceanDepth, 255);
			
			combinedNoiseData.append(finalHeight)
	
	# Save remaining heightmaps for debug
	var continentNoiseImage = Image.create_from_data(width, height, false, Image.FORMAT_L8, continentNoiseData)
	continentNoiseImage.save_png("res://Textures/Noise/continentNoise.png")

	var heightNoiseImage = Image.create_from_data(width, height, false, Image.FORMAT_L8, heightNoiseData)
	heightNoiseImage.save_png("res://Textures/Noise/heightNoise.png")
	
	var combinedNoiseImage = Image.create_from_data(width, height, false, Image.FORMAT_L8, combinedNoiseData)
	combinedNoiseImage.save_png("res://Textures/Noise/combinedNoise.png")
	
	var imageTexture = ImageTexture.create_from_image(combinedNoiseImage)
	
	processErosion(combinedNoiseData)
	
	# Generate 3D cube terrain from heightmap
	for y in height:
		for x in width:
			var tile = BOX_TILE.instantiate()
			
			tile.init(x, y, width, height, combinedNoiseData.get(y * width + x), oceanDepth)
			add_child(tile)

func processErosion (heightMap: PackedByteArray):
	pass # To do

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
