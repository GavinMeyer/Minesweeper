extends Node2D

signal exploded
signal revealed
signal flagged
var number = 0
var mine = false
var clickable = false
var isRevealed = false
var isFlagged = false
var index = [0, 0]

func _ready():
	pass

func _process(_delta):
	if (not isRevealed and clickable and not isFlagged and Input.is_action_just_pressed("left_click")):
		revealSpot(false)
	if (not isRevealed and clickable and Input.is_action_just_pressed("right_click")):
		isFlagged = not isFlagged
		if (isFlagged):
			$Flag.show()
		else:
			$Flag.hide()
		emit_signal("flagged", isFlagged)
	if (Input.is_action_just_pressed("debug_key")):
		$Cover.hide()
		isRevealed = true

func revealSpot(isChaining):
	$Cover.hide()
	isRevealed = true
	if mine:
		emit_signal("exploded", false)
	if(not isChaining):
		emit_signal("revealed", number, mine, index)

func giveMine():
	mine = true
	$Mine.show()
	$NumberLabel.hide()

func removeMine():
	mine = false
	$Mine.hide()
	showNumber()

func showNumber():
	$NumberLabel.text = "%d" % number
	$NumberLabel.show()
	
	# selecting color
	var ls
	
	if (number == 1):
		ls = load("res://label1.tres")
	elif (number == 2):
		ls = load("res://label2.tres")
	elif (number == 3):
		ls = load("res://label3.tres")
	elif (number == 4):
		ls = load("res://label4.tres")
	elif (number == 5):
		ls = load("res://label5.tres")
	elif (number == 6):
		ls = load("res://label6.tres")
	elif (number == 7):
		ls = load("res://label7.tres")
	elif (number == 8):
		ls = load("res://label8.tres")
	else:
		ls = load("res://label0.tres")
		
	$NumberLabel.set_label_settings(ls)

func _on_click_detect_mouse_entered():
	clickable = true

func _on_click_detect_mouse_exited():
	clickable = false
