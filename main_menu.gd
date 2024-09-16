extends Node2D

signal start(matrixLength, mineCount)
var mineCount = 0
var boardLength = 4
var difficulty = 0
# 0 easy, 1 medium
# 2 hard, 3 UH, 4 custom

# Easy ml=6 mc=4 ratio=9.00
# Medium ml=9 mc=12 ratio=6.75
# Hard ml=12 mc=25 ratio=5.76
# Ultrahard ml=25 mc=110 ratio=5.68

# Called when the node enters the scene tree for the first time.
func _ready():
	$MC.text = "mines: 0"
	$ML.text = "board length: 4"
	difficulty = $Difficulty.get_selected_id()
	numChangeToggle(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	difficulty = $Difficulty.get_selected_id()
	
	if (difficulty != 4):
		numChangeToggle(true)
	
	if (difficulty == 0):
		$MC.text = "mines: 5"
		$ML.text = "board length: 7"
		mineCount = 5
		boardLength = 7
	elif (difficulty == 1):
		$MC.text = "mines: 12"
		$ML.text = "board length: 9"
		mineCount = 12
		boardLength = 9
	elif (difficulty == 2):
		$MC.text = "mines: 25"
		$ML.text = "board length: 12"
		mineCount = 25
		boardLength = 12
	elif (difficulty == 3):
		$MC.text = "mines: 110"
		$ML.text = "board length: 25"
		mineCount = 110
		boardLength = 25
	else:
		$MC.text = "mines: %d" % mineCount
		$ML.text = "board length: %d" % boardLength
		numChangeToggle(false)
	
	if (mineCount > boardLength * boardLength - 1):
		mineCount = boardLength * boardLength - 1


func numChangeToggle(isHidden):
	if (isHidden):
		$Up1.hide()
		$Down1.hide()
		$Up2.hide()
		$Down2.hide()
		$MegaUp1.hide()
		$MegaDown1.hide()
	else:
		$Up1.show()
		$Down1.show()
		$Up2.show()
		$Down2.show()
		$MegaUp1.show()
		$MegaDown1.show()



func _on_up_1_pressed():
	var maxMines = boardLength * boardLength - 1
	if(mineCount < maxMines):
		mineCount += 1


func _on_down_1_pressed():
	if(mineCount > 0):
		mineCount -= 1

func _on_mega_up_1_pressed():
	var maxMines = boardLength * boardLength - 1
	if(mineCount < maxMines - 10):
		mineCount += 10
	else:
		mineCount = maxMines

func _on_mega_down_1_pressed():
	if(mineCount > 9):
		mineCount -= 10
	else:
		mineCount = 0

func _on_up_2_button_down():
	if(boardLength < 25):
		boardLength += 1


func _on_down_2_pressed():
	if(boardLength > 4):
		boardLength -= 1


func _on_start_button_pressed():
	emit_signal("start", boardLength, mineCount)
	hide()


func _on_button_pressed():
	get_tree().quit()
