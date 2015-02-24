# This imports all the layers from a Sketch project called "UI"
UIFromSketch = Framer.Importer.load "imported/UI"
Framer.Defaults.Animation = {
    curve: "spring(800,30,0)"
}

# Variables to control the interactions
screenWidth         = Framer.Device.screen.width
screenHeight        = Framer.Device.screen.height
animationFront      = false
animationBack       = false
initialDragPosition = 0

# Imported layers from Sketch
background = UIFromSketch.background
card1      = UIFromSketch.cardOne	   # Each card is 485 x 793
card2      = UIFromSketch.cardTwo   
card3      = UIFromSketch.cardThree
backCard1  = UIFromSketch.backOne
backCard2  = UIFromSketch.backTwo
backCard3  = UIFromSketch.backThree
close1     = UIFromSketch.closeOne
close2     = UIFromSketch.closeTwo
close3     = UIFromSketch.closeThree

# Initialization of the cards
background.x = background.y = 0
card1.x      = 70
card2.x      = 600
card3.x      = 1130
card1.y      = card2.y = card3.y = 80

# Initialization of the back cards precisely behind the cards
backCard1.x         = 75
backCard2.x         = 605
backCard3.x         = 1135
backCard1.y         = backCard2.y = backCard3.y = 85
# A backcard should also start invisible and rotated 180 degrees.
backCard1.opacity   = backCard2.opacity = backCard3.opacity = 0;
backCard1.rotationY = backCard2.rotationY = backCard3.rotationY = 180

# Initialize the X button of all cards. They are not visible.
close1.x       = card2.x - 120
close2.x       = card3.x - 120
close3.x       = (card3.x + 530) - 120
close1.y       = close2.y = close3.y = 130
close1.visible = close2.visible = close3.visible = false


# We need a super layer big enough to hold all the cards
cardContainer                   = new Layer({width: (screenWidth*3), height: screenHeight})
cardContainer.y                 = 0
cardContainer.backgroundColor   = "transparent"
cardContainer.draggable.enabled = true
cardContainer.draggable.speedY  = 0
# The following lines create three states and defines the x position
# this super layer should be placed given its current state.
cardContainer.states.add("card1", {x:0})
cardContainer.states.add("card2", {x:-530})
cardContainer.states.add("card3", {x:-1054})
# This list defines the order in which the states advance
statesOrder = ["card1", "card2", "card3"]
cardContainer.states.next(statesOrder)
cardContainer.states.animationOptions = {
    curve: "spring(500, 30, 0)"
    time: 0.2
}
# All the cards, backcards and close buttons are sub layer of this layer.
# In order to avoid repetition, you could insert all the layers in a array
# and do a for loop here, inserting all the elements.
cardContainer.addSubLayer(backCard1)
cardContainer.addSubLayer(backCard2)
cardContainer.addSubLayer(backCard3)
cardContainer.addSubLayer(card1)
cardContainer.addSubLayer(card2)
cardContainer.addSubLayer(card3)
cardContainer.addSubLayer(close1)
cardContainer.addSubLayer(close2)
cardContainer.addSubLayer(close3)


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 																		  #
#  								EVENT HANDLING      	     			  #
#																		  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# The following two events, are sufficient to handle the super layer's swipe movement
# DragStart saves the inition position of the drag movement
cardContainer.on Events.DragStart, ->
	initialDragPosition = cardContainer.x

# When the drag movement ends, measure the displacement from the initial
# position to the final position. Depending on this difference an
# appropriate action is taken.
cardContainer.on Events.DragEnd, ->
	displacement = (initialDragPosition - cardContainer.x)
	initialState = cardContainer.states.state

	# If the displacement was smaller than 1/8 of the screen, cancel the drag.
	if Math.abs(displacement) < screenWidth / 8
		cardContainer.states.switch(initialState)
	else
		
		# You cannot go from state 'card3' to state 'card1'
		if displacement > 0 and initialState != statesOrder[statesOrder.length-1]
			cardContainer.states.next()

		# You cannot go from state 'card1' to state 'card3'
		else if displacement < 0 and initialState != statesOrder[0]
			cardContainer.states.previous()

		else
			cardContainer.states.switch(initialState)


# The following function handle card turning. It receives a 4 layers
# and checks for click events in the triggerLayer and in the closeLayer.
# In this example, the triggerLayer and frontLayer are the same.
# You may also have one layer only to trigger the turn animation
handleCard = (frontLayer, backLayer, triggerLayer, closeLayer) ->
	triggerLayer.on Events.Click, ->		
		displacement = (initialDragPosition - cardContainer.x)
		# Only turn the card if you are not swiping
		if displacement == 0
			turnFront(frontLayer, backLayer)
			Utils.delay 0.25, ->
				closeLayer.visible = true
				closeLayer.bringToFront()

	closeLayer.on Events.Click, ->
		closeLayer.visible = false
		closeLayer.sendToBack()
		turnBack(frontLayer, backLayer)

# This invokes the handleCard method for all available cards
handleCard(card1, backCard1, card1, close1)
handleCard(card2, backCard2, card2, close2)
handleCard(card3, backCard3, card3, close3)


# Useful methods to improve code reusability
# Receives two layers. The first one is becomes faced down and the
# second one faced up.
turnFront = (frontLayer, backLayer) ->
	animationFront = frontLayer.rotateFront()
	animationBack = backLayer.rotateBack()

# The reverse animation from the turnFront function.
turnBack = (frontLayer, backLayer) ->
	animBack = animationBack.reverse()
	animFront = animationFront.reverse()
	animBack.start()
	animFront.start()

# Now each layer has a new animation called rotateFront and rotateBack
# This is accessible by layer.rotateFront()
Layer::rotateFront = ->
  return this.animate
    properties:
      rotationY:180
      delay: 5
      opacity: 0
    time: 0.4,
    #curve: "spring(400,50,0)"
    curve: "cubic-bezier(0.7, 0.73, 0.17, 1.01)"

Layer::rotateBack = ->
 	return this.animate
 	  properties:
 	    rotationY:0
 	    opacity: 1
 	  time: 0.4,
 	  #curve: "spring(400,50,0)"
 	  curve: "cubic-bezier(0.7, 0.73, 0.17, 1.01)"
