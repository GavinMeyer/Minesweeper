extends Node2D

@export var matrixLength = 5
@export var mineCount = 8
@export var isMenuEnabled = false
var spotScene = preload("res://spot.tscn")
var field = []
var rng = RandomNumberGenerator.new()
var gameStarted = false
var numRevealed = 0
var ended = false
var gap = 32 + 1
var inMenu = true
var flagStock = mineCount

# Known Buggies
# Zero Chaining will reveal flagged spots
# 
# 
# Possible difficulties:
# Easy ml=6 mc=4 ratio=9.00
# Medium ml=9 mc=12 ratio=6.75
# Hard ml=12 mc=25 ratio=5.76
# Ultrahard ml=25 mc=110 ratio=5.68
# 
# Some seeds
# 5223558732659342616 (ml=8,mc=5)
# 1336441083042598063 (ml=15,mc=30)
# 
# Cool Ideas
#	Make an explosion animation
#	Better mine sprite
#	Better flag sprite
#	Better spot sprite
#

func _ready():
	if (not isMenuEnabled):
		$MainMenu.hide()
		rng.randomize()
		var seedrng = 0
		if seedrng != 0:
			rng.seed = seedrng
		print(rng.seed)
		
		if (matrixLength * matrixLength < mineCount or matrixLength > 25):
			print("Invalid ML or MC")
			get_tree().quit()
		
		placeSpots(Vector2(16,16))

func _process(_delta):
	if (Input.is_action_just_pressed("escape") and not inMenu):
		DisplayServer.window_set_size(Vector2(500, 500))
		$MainMenu.show()
		removeSpots()
		$VictoryText.hide()
		$FlagText.hide()
		inMenu = true
	
	if (Input.is_action_just_pressed("debug_key") and not gameStarted):
		placeSpots(Vector2(16,16))
		# set gameStart = true here or after next line
		# place mines & numbers next !!!

func placeSpots(primaryPos):
	if (matrixLength > 0):
		field = []
		var windowSize = gap * matrixLength
		DisplayServer.window_set_size(Vector2(windowSize, windowSize + gap * 2))
		$Backboard.scale = Vector2(windowSize, windowSize + gap * 2)
		
		for i in range(matrixLength):
			field.append([])
			for j in range(matrixLength):
				field[i].append(spotScene.instantiate())
				add_child(field[i][j])
				field[i][j].exploded.connect(gameOver)
				field[i][j].revealed.connect(spotRevealed)
				field[i][j].flagged.connect(flagCounterUpdate)
				field[i][j].position = (primaryPos + Vector2(gap * i, gap * j))
				field[i][j].index[0] = i
				field[i][j].index[1] = j
				
		$VictoryText.position.y = windowSize + gap
		$VictoryText.position.x = gap
		$FlagText.position.y = windowSize
		$FlagText.position.x = gap
		


func placeMines(ignoreI, ignoreJ):
	if (matrixLength > 0 or mineCount >= matrixLength * matrixLength):
		var currCount = 0
		while (currCount != mineCount):
			var i : int = rng.randi() % matrixLength
			var j : int = rng.randi() % matrixLength
			if (not field[i][j].mine and not (i == ignoreI and j == ignoreJ)):
				field[i][j].giveMine()
				currCount += 1

func placeNumbers():
	var cap = matrixLength - 1
	for i in range(matrixLength):
		for j in range(matrixLength):
			var count = 0
			if (i > 0):
				if (field[i-1][j].mine):
					count += 1
				if (j > 0 and field[i-1][j-1].mine):
					count += 1
				if (j < cap and field[i-1][j+1].mine):
					count += 1
			if (i < cap):
				if (field[i+1][j].mine):
					count += 1
				if (j > 0 and field[i+1][j-1].mine):
					count += 1
				if (j < cap and field[i+1][j+1].mine):
					count += 1
			if (j > 0 and field[i][j-1].mine):
				count += 1
			if (j < cap and field[i][j+1].mine):
				count += 1
				
			field[i][j].number = count
			if (not field[i][j].mine):
				field[i][j].showNumber()

func removeSpots():
	for i in range(matrixLength):
		for j in range(matrixLength):
			remove_child(field[i][j])


func spotRevealed(number, isMine, index):
	if (not gameStarted):
#		print("Safety Engaged")
#		field[index[0]][index[1]].removeMine()
#		decrementAOE(index[0], index[1])
#		var i = rng.randi() % matrixLength
#		var j = rng.randi() % matrixLength
#		while (field[i][j].mine and field[i][j].isRevealed):
#			i = rng.randi() % matrixLength
#			j = rng.randi() % matrixLength
#		field[i][j].giveMine()
#		incrementAOE(i, j)
		placeMines(index[0], index[1])
		placeNumbers()
		if (field[index[0]][index[1]].number == 0):
			zeroChain(index[0], index[1])
	elif (gameStarted and number == 0 and not isMine):
		zeroChain(index[0], index[1])
	
	gameStarted = true
	numRevealed += 1
	
	var victoryCheck = matrixLength * matrixLength - mineCount
	if (numRevealed >= victoryCheck):
		gameOver(true)

func zeroChain(i, j):
#	print("i: %d j: %d" % [i,j])
	var cap = matrixLength - 1
	if (i < 0 or i > cap or j < 0 or j > cap):
		return false
	
	var check = false
	
	if (i > 0):
		if (not field[i-1][j].isRevealed):
			field[i-1][j].revealSpot(true)
			check = true
			numRevealed += 1
		if (j > 0 and not field[i-1][j-1].isRevealed):
			field[i-1][j-1].revealSpot(true)
			check = true
			numRevealed += 1
		if (j < cap and not field[i-1][j+1].isRevealed):
			field[i-1][j+1].revealSpot(true)
			check = true
			numRevealed += 1
	if (i < cap):
		if (not field[i+1][j].isRevealed):
			field[i+1][j].revealSpot(true)
			check = true
			numRevealed += 1
		if (j > 0 and not field[i+1][j-1].isRevealed):
			field[i+1][j-1].revealSpot(true)
			check = true
			numRevealed += 1
		if (j < cap and not field[i+1][j+1].isRevealed):
			field[i+1][j+1].revealSpot(true)
			check = true
			numRevealed += 1
	if (j > 0 and not field[i][j-1].isRevealed):
		field[i][j-1].revealSpot(true)
		check = true
		numRevealed += 1
	if (j < cap and not field[i][j+1].isRevealed):
		field[i][j+1].revealSpot(true)
		check = true
		numRevealed += 1
		
	if (not check):
		return
	
	if (i > 0):
		if (field[i-1][j].number == 0):
			zeroChain(i - 1, j)
		if (j > 0 and field[i-1][j-1].number == 0):
			zeroChain(i - 1, j - 1)
		if (j < cap and field[i-1][j+1].number == 0):
			zeroChain(i - 1, j + 1)
	if (i < cap):
		if (field[i+1][j].number == 0):
			zeroChain(i + 1, j)
		if (j > 0 and field[i+1][j-1].number == 0):
			zeroChain(i + 1, j - 1)
		if (j < cap and field[i+1][j+1].number == 0):
			zeroChain(i + 1, j + 1)
	if (j > 0 and field[i][j-1].number == 0):
		zeroChain(i, j - 1)
	if (j < cap and field[i][j+1].number == 0):
		zeroChain(i, j + 1)


func flagCounterUpdate(isFlagged):
	if (isFlagged):
		flagStock -= 1
	else:
		flagStock += 1
	
	if (flagStock < 0):
		$FlagText.text = "Flags: %d" % 0
	else:
		$FlagText.text = "Flags: %d" % flagStock


func gameOver(isVictory):
	if (not ended):
		if (isVictory):
			$VictoryText.text = "Victory!"
		else:
			$VictoryText.text = "Failure!"
		$VictoryText.show()
		ended = true
		
		for i in range(matrixLength):
				for j in range(matrixLength):
					field[i][j].isRevealed = true


func _on_main_menu_start(mL, mC):
	matrixLength = mL
	mineCount = mC
	flagStock = mineCount
	
	$FlagText.text = "Flags: %d" % flagStock
	$FlagText.show()
	
	gameStarted = false
	numRevealed = 0
	ended = false
	inMenu = false
	
	rng.randomize()
	var seedrng = 0
	if seedrng != 0:
		rng.seed = seedrng
	print(rng.seed)
	
	if (matrixLength * matrixLength < mineCount or matrixLength > 25 or matrixLength < 4 or mineCount < 0):
		print("Invalid ML or MC")
		get_tree().quit()
	
	placeSpots(Vector2(16,16))

