extends Node

# Width of the map
@export var width: int
# Height of the map
@export var height: int
# Water to land ratio (Higher is more water)
@export var fillPercent: int
# How much water should exist at the edges of the map
@export var borderSize: int = 2
# Smoothing iterations of the cellular automata
@export var smoothingAmt: int = 4
# Iterations cleaning up shore bumps or lakes
@export var cleaningAmt: int = 3
# Map seed
@export var seed: String

var map: Array
var rng: RandomNumberGenerator

func _ready():
	rng = RandomNumberGenerator.new()
	if seed == "":
		seed = Time.get_datetime_string_from_system(true)
	rng.seed = hash(seed)
	rng.state = 0
	generateMap()

# Generates a map with doors to other maps
# Returns a double integer array(map) defining open space and walls using 0s and 1s
func generateMap() -> Array:
	var sizeX = width - borderSize * 2;
	var sizeY = height - borderSize * 2;
	
	# Initialize a map and randomly fill it with 1s
	var grid = []
	for y in sizeY:
		grid.append([])
		for x in sizeX:
			var val = rng.randi_range(0, 1)
			grid[y].append(val)

	# Smooth the grid a few times using cellular automata
	for i in smoothingAmt:
		grid = smoothMap()
	
	# Fills in tiny rooms and gets rid of small walls
	processMap(grid)
	
	# Add a border to the map
	sizeX += borderSize * 4
	sizeY += borderSize * 4
	var borderedMap = []
	for y in sizeY:
		borderedMap.append([])
		for x in sizeX:
			if x >= borderSize and x < width + borderSize and y >= borderSize and y < height + borderSize:
				borderedMap[y].append(grid[x-borderSize][y-borderSize])
			else:
				borderedMap[y].append(1)
	
	return []
	# Prepare rooms for connectivity
	#List<List<Point>> roomRegions = getRegions(0);
	#List<CaveRoom> remainingRooms = new ArrayList<CaveRoom>();
	#for (List<Point> roomRegion : roomRegions) {
		#remainingRooms.add(new CaveRoom(roomRegion, map));
	#}
#
	#remainingRooms.sort(null);
	#remainingRooms.get(0).isMainRoom = true;
	#remainingRooms.get(0).isAccessibleFromMainRoom = true;
	#
	#//Connect the rooms
	#connectClosestRooms(remainingRooms, false);
		#
	#//Clean up small rooms and walls
	#processMap();
	#
	#//Smoothes the walls and guarantees 2 wide corridors
	#for (int i = 0; i < cleaningAmt; i++) {
		#map = cleanMap(map);
	#}
	#
	#//Fix border in case of over smoothing and add next level tiles
	#int adjustedWidth = width - borderSize;
	#int adjustedHeight = height - borderSize;
	#for (int x = 0; x < borderedMap.length; x ++) {
		#for (int y = 0; y < borderedMap[x].length; y ++) {
			#if (x >= 1 && x < adjustedWidth + 1 && y >= 1 && y < adjustedHeight + 1) {
				#borderedMap[x][y] = map[x-1][y-1];
			#} else {
				#if (y == 0 && x > borderedMap.length/2-4 && x < borderedMap.length/2+4 && doors[0]) {
					#borderedMap[x][y] = 0;
				#} else if (x == borderedMap.length-1 && y > borderedMap[x].length/2-4 && y < borderedMap[x].length/2+4 && doors[1]) {
					#borderedMap[x][y] = 0;
				#} else if (y == borderedMap[x].length-1 && x > borderedMap.length/2-4 && x < borderedMap.length/2+4 && doors[2]) {
					#borderedMap[x][y] = 0;
				#} else if (x == 0 && y > borderedMap[x].length/2-4 && y < borderedMap[x].length/2+4 && doors[3]) {
					#borderedMap[x][y] = 0;
				#} else {
					#borderedMap[x][y] = 1;
				#}
			#}
			#if (y == 1 && x > borderedMap.length/2-3 && x < borderedMap.length/2+3 && doors[0]) {
				#borderedMap[x][y] = 0;
			#} else if (x == borderedMap.length-2 && y > borderedMap[x].length/2-3 && y < borderedMap[x].length/2+3 && doors[1]) {
				#borderedMap[x][y] = 0;
			#} else if (y == borderedMap[x].length-2 && x > borderedMap.length/2-3 && x < borderedMap.length/2+3 && doors[2]) {
				#borderedMap[x][y] = 0;
			#} else if (x == 1 && y > borderedMap[x].length/2-3 && y < borderedMap[x].length/2+3 && doors[3]) {
				#borderedMap[x][y] = 0;
			#}
		#}
	#}
	#
	#//Return the completed map
	#return borderedMap;
#}
		#
		#/**
		 #* Creates a new map instead of a reference to the dataMap
		 #* 
		 #* @param dataMap (The map that data should be extracted from)
		 #* @return
		 #*/
		#private int[][] getMapData(int[][] dataMap) {
			#int[][] recievingMap = new int[dataMap.length][dataMap[0].length];
			#for (int x = 0; x < recievingMap.length; x ++) {
				#for (int y = 0; y < recievingMap[x].length; y ++) {
					#recievingMap[x][y] = dataMap[x][y];
				#}
			#}
			#return recievingMap;
		#}
		#
		## Fills in tiny rooms and destroys small walls
func processMap(map: Array):
	pass
			#List<List<Point>> wallRegions = getRegions(1);
			#int wallThresholdSize = 25;
			#for (List<Point> wallRegion : wallRegions) {
				#if (wallRegion.size() < wallThresholdSize) {
					#for (Point tile : wallRegion) {
						#map[tile.x][tile.y] = 0;
					#}
				#}
			#}
			#
			#List<List<Point>> roomRegions = getRegions(0);
			#int roomThresholdSize = 100;
			#
			#for (List<Point> roomRegion : roomRegions) {
				#if (roomRegion.size() < roomThresholdSize) {
					#for (Point tile : roomRegion) {
						#map[tile.x][tile.y] = 1;
					#}
				#} 
			#}
			#
			#List<CaveWall> walls = new ArrayList<CaveWall>();
			#for (List<Point> wall : wallRegions) {
				#walls.add(new CaveWall(wall, map));
			#}
			#
			#walls.sort(null);
			#for (CaveWall wall : walls) {
				#wall.checkNearbyWalls(3);
			#} 
#
#
		#/**
		 #* Connects the closest rooms to each other recursively until all rooms are connected
		 #* 
		 #* @param allRooms
		 #* @param forceAccessibilityFromMainRoom (Guarantee this room is connected to the main (biggest) room)
		 #*/
		#private void connectClosestRooms(List<CaveRoom> allRooms, boolean forceAccessibilityFromMainRoom) {
			#
			#//Room lists for accessibility from main room
			#List<CaveRoom> roomListA = new ArrayList<CaveRoom>();
			#List<CaveRoom> roomListB = new ArrayList<CaveRoom>();
			#
			#//Organize rooms into their respective lists
			#if (forceAccessibilityFromMainRoom) {
				#for (CaveRoom room : allRooms) {
					#if (room.isAccessibleFromMainRoom) {
						#roomListB.add(room);
					#} else {
						#roomListA.add(room);
					#}
				#}
			#} else {
				#roomListA = allRooms;
				#roomListB = allRooms;
			#}
			#
			#int bestDistance = 0;
			#Point bestTileA = new Point();
			#Point bestTileB = new Point();
			#CaveRoom bestRoomA = new CaveRoom();
			#CaveRoom bestRoomB = new CaveRoom();
			#boolean possibleConnectionFound = false;
			#
			#for (CaveRoom roomA : roomListA) {
				#//Create only one connection to another room if not forcing accessibility
				#if (!forceAccessibilityFromMainRoom) {
					#possibleConnectionFound = false;
					#if (roomA.connectedRooms.size() > 0) {
						#continue;
					#}
				#}
				#for (CaveRoom roomB : roomListB) {
					#//Skip these rooms if they are the same room or are already connected
					#if (roomA == roomB || roomA.isConnected(roomB)) {
						#continue;
					#}
					#//Loop through the edge tile of both rooms and find the shortest distance
					#for (int tileIndexA = 0; tileIndexA < roomA.edgeTiles.size(); tileIndexA++) {
						#for (int tileIndexB = 0; tileIndexB < roomB.edgeTiles.size(); tileIndexB++) {
							#Point tileA = roomA.edgeTiles.get(tileIndexA);
							#Point tileB = roomB.edgeTiles.get(tileIndexB);
							#int distanceBetweenRooms = (int) ((tileA.x-tileB.x)*(tileA.x-tileB.x) + (tileA.y-tileB.y)*(tileA.y-tileB.y));
							#
							#//Set the current best connection between rooms
							#if (distanceBetweenRooms < bestDistance || !possibleConnectionFound) {
								#bestDistance = distanceBetweenRooms;
								#possibleConnectionFound = true;
								#bestTileA = tileA;
								#bestTileB = tileB;
								#bestRoomA = roomA;
								#bestRoomB = roomB;
							#}
						#}
					#}
				#}
				#
				#//Connect the 2 rooms if a connection is found and not forcing accessibility
				#if (possibleConnectionFound && !forceAccessibilityFromMainRoom) {
					#createPassage(bestRoomA, bestRoomB, bestTileA, bestTileB);
				#}
			#} 
#
			#//Loop recursively until no possible connections are found
			#if (possibleConnectionFound && forceAccessibilityFromMainRoom) {
				#createPassage(bestRoomA, bestRoomB, bestTileA, bestTileB);
				#connectClosestRooms(allRooms, true);
			#}
			#
			#//If not forcing accessibility recursively connect rooms while forcing accessibility
			#if (!forceAccessibilityFromMainRoom) {
				#connectClosestRooms(allRooms, true);
			#}
		#}
		#
		#/**
		 #* Erase walls between rooms in a line
		 #* 
		 #* @param roomA (The one of the rooms being connected)
		 #* @param roomB (The other room being connected)
		 #* @param tileA (Starting tile)
		 #* @param tileB (Ending tile)
		 #*/
		#private void createPassage(CaveRoom roomA, CaveRoom roomB, Point tileA, Point tileB) {
			#roomA.connectRooms(roomB);
			#
			#List<Point> line = getLine(tileA, tileB);
			#for (Point p : line) {
				#drawCircle(p, 3);
			#}
			#
		#}
		#
		#/**
		 #* Erase walls in a circular radius from a point
		 #* 
		 #* @param p (The center point)
		 #* @param r (The radius of the circle)
		 #*/
		#private void drawCircle (Point p, int r) {
			#for (int x = -r; x <= r; x++) {
				#for (int y = -r; y <= r; y++) {
					#if (x*x + y*y <= r*r) {
						#int drawX = p.x + x;
						#int drawY = p.y + y;
						#if (isInMapRange(drawX, drawY)) {
							#map[drawX][drawY] = 0;
						#}
					#}
				#}
			#}
		#}
		#
		#/**
		 #* Create a list of points from a starting point to an ending point
		 #* 
		 #* @param from (Starting point)
		 #* @param to (Ending point)
		 #* @return the list of points between the two points
		 #*/
		#private List<Point> getLine(Point from, Point to) {
			#List<Point> line = new ArrayList<Point>();
			#
			#int x = from.x;
			#int y = from.y;
			#
			#int dx = to.x - from.x;
			#int dy = to.y - from.y;
			#
			#boolean inverted = false;
			#int step = sign(dx); 
			#int gradientStep = sign(dy);
			#
			#int longest = Math.abs(dx);
			#int shortest = Math.abs(dy);
			#
			#if (longest < shortest) {
				#inverted = true;
				#longest = Math.abs(dy);
				#shortest = Math.abs(dx);
		#
				#step = sign(dy);
				#gradientStep = sign(dx);
			#}
			#
			#int gradientAccumulation = longest / 2;
			#for (int i = 0; i < longest; i++) {
				#line.add(new Point(x, y));
			#
				#if (inverted) {
					#y += step;
				#} else {
					#x += step;
				#}
				#
				#gradientAccumulation += shortest;
				#if (gradientAccumulation >= longest) {
					#if (inverted) {
						#x += gradientStep;
					#} else {
						#y += gradientStep;
					#}
					#
					#gradientAccumulation -= longest;
				#}
			#}
			#
			#return line;
		#}
		#
		#/**
		 #* Limit an int to the range -1, 1
		 #* 
		 #* @param i (input)
		 #* @return 
		 #*/
		#private int sign(int i) {
			#return i < 0 ? -1 : i > 0 ? 1 : 0;
		#}
		#
		## Get all the regions of a tileType (0 or 1)
		## Returns an array containing arrays of tiles that correspond to a room/region of tileType
		#getRegions(int tileType) -> Array:
			#regions = new ArrayList<List<Point>>();
			#int[][] mapFlags = new int[width][height];
			#
			#for (int x = 0; x < width; x ++) {
				#for (int y = 0; y < height; y ++) {
					#if (mapFlags[x][y] == 0 && map[x][y] == tileType) {
						#List<Point> newRegion = getRegionTiles(x, y);
						#regions.add(newRegion);
						#
						#for(Point tile : newRegion) {
							#mapFlags[tile.x][tile.y] = 1;
						#}
					#}
				#}
			#}
			#
			#return regions;
#
		#/**
		 #* Get the connected tiles to the one at x, y
		 #* 
		 #* @param startX
		 #* @param startY
		 #* @return List of Points that define that region
		 #*/
		#getRegionTiles(int startX, int startY) {
			#List<Point> tiles = new ArrayList<Point>();
			#int[][] mapFlags = new int[width][height];
			#int tileType = map[startX][startY];
			#
			#Queue<Point> queue = new LinkedList<Point>();
			#queue.add(new Point(startX, startY));
			#mapFlags[startX][startY] = 1;
			#
			#while(!queue.isEmpty()) {
				#Point tile = queue.poll();
				#tiles.add(tile);
			#
				#for (int x = tile.x - 1; x <= tile.x + 1; x++) {
					#for (int y = tile.y - 1; y <= tile.y + 1; y++) {
						#if (isInMapRange(x, y) && (y == tile.y || x == tile.x)) {
							#if (mapFlags[x][y] == 0 && map[x][y] == tileType) {
								#mapFlags[x][y] = 1;
								#queue.add(new Point(x, y));
							#}
						#}
					#}
				#}
			#}
			#
			#return tiles;
		#}
#
		#
		#/**
		 #* Check if the point is within the map
		 #* 
		 #* @param x
		 #* @param y
		 #* @return true if the point is inside the map
		 #*/
		#private boolean isInMapRange(int x, int y) {
			#return x >= 0 && x < width && y >= 0 && y < height;
		#}
#
		## Smooth the map using cellular automata
func smoothMap():
	pass
			#for (int x = 0; x < width; x ++) {
				#for (int y = 0; y < height; y ++) {
					#int neighbourWallTiles = GetSurroundingWallCount(x,y);
#
					#if (neighbourWallTiles > 4)
						#map[x][y] = 1;
					#else if (neighbourWallTiles < 4)
						#map[x][y] = 0;
#
				#}
			#}
			#return getMapData(map);
		#}
#
		#/**
		 #* Smoothes walls and guarantees 2 wide corridors 
		 #* Not from tutorial
		 #* 
		 #* @param map
		 #* @return a cleaned map
		 #*/
		#private int[][] cleanMap(int[][] map) {
			#for (int y = 0; y < height; y ++) {
				#for (int x = 0; x < width; x ++) {
					#int tileType = map[x][y];
					#int neighbourWallTiles = GetSurroundingWallCount(x,y);
#
					#if (tileType == 0) {
						#if (neighbourWallTiles > 4 && getWallCount(x,y) > 4) {
							#map[x][y] = 1;
						#} else if (neighbourWallTiles == 4) {
							#int[] surroundingWalls = GetSurroundingWalls(x, y);
							#if (surroundingWalls[1] == 1 && surroundingWalls[2] == 1 && surroundingWalls[6] == 1 && surroundingWalls[7] == 1) {
								#map[x+0][y-1] = 0;
								#map[x+1][y-1] = 0;
							#} else if (surroundingWalls[0] == 1 && surroundingWalls[1] == 1 && surroundingWalls[7] == 1 && surroundingWalls[8] == 1) {
								#map[x-1][y-1] = 0;
								#map[x+0][y-1] = 0;
							#} else if (surroundingWalls[0] == 1 && surroundingWalls[3] == 1 && surroundingWalls[5] == 1 && surroundingWalls[8] == 1) {
								#map[x-1][y-1] = 0;
								#map[x-1][y+0] = 0;
							#} else if (surroundingWalls[2] == 1 && surroundingWalls[3] == 1 && surroundingWalls[5] == 1 && surroundingWalls[6] == 1) {
								#map[x+1][y-1] = 0;
								#map[x+1][y+0] = 0;
							#}
						#} else if (neighbourWallTiles == 3) {
							#int[] surroundingWalls = GetSurroundingWalls(x, y);
							#if (surroundingWalls[0] == 1 && surroundingWalls[1] == 1 && surroundingWalls[8] == 1) {
								#map[x-1][y-1] = 0;
								#map[x+0][y-1] = 0;
							#} else if (surroundingWalls[0] == 1 && surroundingWalls[3] == 1 && surroundingWalls[8] == 1) {
								#map[x-1][y-1] = 0;
								#map[x-1][y+0] = 0;
							#} else if (surroundingWalls[0] == 1 && surroundingWalls[5] == 1 && surroundingWalls[8] == 1) {
								#map[x+1][y+0] = 0;
								#map[x+1][y+1] = 0;
							#} else if (surroundingWalls[0] == 1 && surroundingWalls[7] == 1 && surroundingWalls[8] == 1) {
								#map[x+1][y+1] = 0;
								#map[x+0][y+1] = 0;
							#} else if (surroundingWalls[2] == 1 && surroundingWalls[1] == 1 && surroundingWalls[6] == 1) {
								#map[x+0][y-1] = 0;
								#map[x+1][y-1] = 0;
							#} else if (surroundingWalls[2] == 1 && surroundingWalls[5] == 1 && surroundingWalls[6] == 1) {
								#map[x+1][y-1] = 0;
								#map[x+1][y+0] = 0;
							#} else if (surroundingWalls[2] == 1 && surroundingWalls[3] == 1 && surroundingWalls[6] == 1) {
								#map[x-1][y+0] = 0;
								#map[x-1][y+1] = 0;
							#} else if (surroundingWalls[2] == 1 && surroundingWalls[7] == 1 && surroundingWalls[6] == 1) {
								#map[x-1][y+1] = 0;
								#map[x+0][y+1] = 0;
							#}
						#} else if (neighbourWallTiles == 2) {
							#int[] surroundingWalls = GetSurroundingWalls(x, y);
							#if (surroundingWalls[2] == 1 && surroundingWalls[6] == 1) {
								#map[x+1][y-1] = 0;
							#} else if (surroundingWalls[0] == 1 && surroundingWalls[8] == 1) {
								#map[x-1][y-1] = 0;
							#}
						#}
					#} else {
						#if (neighbourWallTiles < 4)
							#map[x][y] = 0;
					#}
					#
				#}
			#}
			#return getMapData(map);
		#}
#
		#/**
		 #* Gets how many walls are around the tile at x, y
		 #* 
		 #* @param gridX
		 #* @param gridY
		 #* @return the number of walls surrounding the tile at x, y
		 #*/
		#private int GetSurroundingWallCount(int gridX, int gridY) {
			#int wallCount = 0;
			#for (int neighbourX = gridX - 1; neighbourX <= gridX + 1; neighbourX ++) {
				#for (int neighbourY = gridY - 1; neighbourY <= gridY + 1; neighbourY ++) {
					#if (neighbourX >= 0 && neighbourX < width && neighbourY >= 0 && neighbourY < height) {
						#if (neighbourX != gridX || neighbourY != gridY) {
							#wallCount += map[neighbourX][neighbourY];
						#}
					#}
					#else {
						#wallCount ++;
					#}
				#}
			#}
#
			#return wallCount;
		#}
#
		#
		#/**
		 #* Gets how many walls are around the tile at x, y. Doesn't include out of map as walls
		 #* 
		 #* @param gridX
		 #* @param gridY
		 #* @return the number of walls surrounding the tile at x, y
		 #*/
		#private int getWallCount(int gridX, int gridY) {
			#int wallCount = 0;
			#for (int neighbourX = gridX - 1; neighbourX <= gridX + 1; neighbourX ++) {
				#for (int neighbourY = gridY - 1; neighbourY <= gridY + 1; neighbourY ++) {
					#if (neighbourX >= 0 && neighbourX < width && neighbourY >= 0 && neighbourY < height) {
						#if (neighbourX != gridX || neighbourY != gridY) {
							#wallCount += map[neighbourX][neighbourY];
						#}
					#}
				#}
			#}
#
			#return wallCount;
		#}
#
		#/**
		 #* Gets the walls that are around the tile at x, y
		 #* Not tutorial
		 #* 
		 #* @param gridX
		 #* @param gridY
		 #* @return an array containing the surrounding walls (1 for wall 0 for null)
		 #* <br> 0 1 2
		 #* <br> 3 + 5
		 #* <br> 6 7 8
		 #*/
		#private int[] GetSurroundingWalls(int gridX, int gridY) {
			#int[] surroundingWalls = new int[9];
			#int indexCounter = 0;
			#for (int neighbourY = gridY - 1; neighbourY <= gridY + 1; neighbourY ++) {
				#int indexY = neighbourY - gridY + 1;
				#for (int neighbourX = gridX - 1; neighbourX <= gridX + 1; neighbourX ++) {
					#int indexX = neighbourX - gridX + 1;
					#if (neighbourX >= 0 && neighbourX < width && neighbourY >= 0 && neighbourY < height) {
						#surroundingWalls[indexY * 3 + indexX] = map[neighbourX][neighbourY];
					#}
					#else {
						#surroundingWalls[indexY * 3 + indexX] = 1;
					#}
				#}
			#}
#
			#return surroundingWalls;
		#}
		#
		#public String getSeed() {
			#return seed;
		#}
		#
		#/**
		 #* @author Justin Schreiber
		 #*
		 #* Room defined by connected tile of value 0
		 #*/
		#class CaveRoom implements Comparable<CaveRoom> {
			#public List<Point> tiles;
			#public List<Point> edgeTiles;
			#public List<CaveRoom> connectedRooms;
			#public int roomSize;
			#public boolean isAccessibleFromMainRoom;
			#public boolean isMainRoom;
			#
			#public CaveRoom() {}
			#
			#/**
			 #* Creates a room with a list of points and passes in the map for finding edge tiles
			 #* 
			 #* @param roomTiles
			 #* @param map
			 #*/
			#public CaveRoom(List<Point> roomTiles, int[][] map) {
				#tiles = roomTiles;
				#roomSize = tiles.size();
				#connectedRooms = new ArrayList<CaveRoom>();
				#
				#//Initializes ands add all edge tiles to the list
				#edgeTiles = new ArrayList<Point>();
				#for (Point tile : tiles) {
					#for (int x = tile.x - 1; x <= tile.x + 1; x++) {
						#for (int y = tile.y - 1; y <= tile.y + 1; y++) {
							#if (isInMapRange(x, y) && map[x][y] == 1 && (y == tile.y || x == tile.x)) {
								#edgeTiles.add(tile);
							#}
						#}
					#}
				#}
			#}
			#
			#/**
			 #* Set accessible from main room to true and all connected rooms
			 #*/
			#public void setAccessibleFromMainRoom() {
				#if (!isAccessibleFromMainRoom) {
					#isAccessibleFromMainRoom = true;
					#for (CaveRoom connectedRoom : connectedRooms) {
						#connectedRoom.setAccessibleFromMainRoom();
					#}
				#}
			#}
			#
			#/**
			 #* Adds each other to their respective connected rooms list and updates it accessibility
			 #* 
			 #* @param roomB
			 #*/
			#public void connectRooms(CaveRoom roomB) {
				#if (this.isAccessibleFromMainRoom) {
					#roomB.setAccessibleFromMainRoom();
				#} else if (roomB.isAccessibleFromMainRoom) {
					#this.setAccessibleFromMainRoom();
				#}
				#connectedRooms.add(roomB);
				#roomB.connectedRooms.add(this);
			#}
			#
			#public boolean isConnected(CaveRoom otherRoom) {
				#return connectedRooms.contains(otherRoom);
			#}
#
			#@Override
			#public int compareTo(CaveRoom ocr) {
				#return ocr.roomSize - roomSize;
			#}
		#}
		#
		#/**
		 #* @author Justin Schreiber
		 #*
		 #* Wall defined by connected tile of value 1
		 #*/
		#class CaveWall implements Comparable<CaveWall> {
			#public List<Point> tiles;
			#public List<Point> edgeTiles;
			#public int wallSize;
			#
			#public CaveWall() {	}
			#
			#/**
			 #* Creates a wall with a list of points and passes in the map for finding edge tiles
			 #* 
			 #* @param wallTiles
			 #* @param map
			 #*/
			#public CaveWall(List<Point> wallTiles, int[][] map) {
				#tiles = wallTiles;
				#wallSize = tiles.size();
				#
				#edgeTiles = new ArrayList<Point>();
				#for (Point tile : tiles) {
					#for (int x = tile.x - 1; x <= tile.x + 1; x++) {
						#for (int y = tile.y - 1; y <= tile.y + 1; y++) {
							#if (isInMapRange(x, y) && map[x][y] == 1 && (y == tile.y || x == tile.x)) {
								#edgeTiles.add(tile);
							#}
						#}
					#}
				#}
			#}
			#
			#/**
			 #* Updates the edge tiles
			 #*/
			#private void updateEdgeTiles() {
				#edgeTiles = new ArrayList<Point>();
				#for (Point tile : tiles) {
					#for (int x = tile.x - 1; x <= tile.x + 1; x++) {
						#for (int y = tile.y - 1; y <= tile.y + 1; y++) {
							#if (isInMapRange(x, y) && map[x][y] == 1 && (y == tile.y || x == tile.x)) {
								#edgeTiles.add(tile);
							#}
						#}
					#}
				#}
			#}
			#
			#/**
			 #* 
			 #* 
			 #* @param r
			 #*/
			#public void checkNearbyWalls(int r) {
				#for (Point tile : edgeTiles) {
					#for (int x = tile.x - r; x <= tile.x + r; x++) {
						#for (int y = tile.y - r; y <= tile.y + r; y++) {
							#if (isInMapRange(x, y) && map[x][y] == 1 && !tiles.contains(new Point(x, y))) {
								#map[x][y] = 0;
								#tiles.remove(tile);
							#}
						#}
					#}
				#}
				#updateEdgeTiles();
			#}
			#
			#@Override
			#public int compareTo(CaveWall ocw) {
				#return ocw.wallSize - wallSize;
			#}
		#}
