# This imports all the layers for "UI" into UIFromSketch
UIFromSketch = Framer.Importer.load "imported/UI"
Framer.Defaults.Animation = {
    curve: "spring(800,30,0)"
}

# Variables to control the interactions
screenHeight        = 1136
screenWidth         = 640
animationFront      = false
animationBack       = false
initialDragPosition = 0

# Imported UI elements
background  = UIFromSketch.background
card1       = UIFromSketch.cardOne	   # Each card is 485 x 793
card2       = UIFromSketch.cardTwo     # Each card is 485 x 793
card3       = UIFromSketch.cardThree   # Each card is 485 x 793
backCard1   = UIFromSketch.backOne
backCard2   = UIFromSketch.backTwo
backCard3   = UIFromSketch.backThree  	   # Each card is 485 x 793
close1      = UIFromSketch.closeOne
close2      = UIFromSketch.closeTwo
close3      = UIFromSketch.closeThree

greenButton = UIFromSketch.greenButton
aquaButton  = UIFromSketch.aquaButton
blueButton  = UIFromSketch.blueButton

# Initialization of UI elements
background.x = background.y = 0
backCard1.x = 75
backCard2.x = 605
backCard3.x = 1135
card1.x = 70
card2.x = 600
card3.x = 1130
close1.x = card2.x - 120
close2.x = card3.x - 120
close3.x = (card3.x + 530) - 120
close1.visible = close2.visible = close3.visible = false
card1.y = card2.y = card3.y = 80
backCard1.y = backCard2.y = backCard3.y = 85
close1.y = close2.y = close3.y = 130
backCard1.opacity = backCard2.opacity = backCard3.opacity = 0;
backCard1.rotationY = backCard2.rotationY = backCard3.rotationY = 180

# Creation of super layers
horizontalCardContainer = new Layer
	width: 2300
	height: screenHeight
	y: 0
	backgroundColor: "transparent"

# Horizontal container that hold all the cards
horizontalCardContainer.backgroundColor = "transparent"
horizontalCardContainer.draggable.enabled = true
horizontalCardContainer.draggable.speedY = 0
horizontalCardContainer.states.add("card1", {x:0})
horizontalCardContainer.states.add("card2", {x:-530})
horizontalCardContainer.states.add("card3", {x:-1054})
horizontalCardContainer.states.next(["card1", "card2", "card3"])
horizontalCardContainer.states.animationOptions = {
    curve: "spring(500, 30, 0)"
    time: 0.2
}
horizontalCardContainer.addSubLayer(backCard1)
horizontalCardContainer.addSubLayer(backCard2)
horizontalCardContainer.addSubLayer(backCard3)
horizontalCardContainer.addSubLayer(card1)
horizontalCardContainer.addSubLayer(card2)
horizontalCardContainer.addSubLayer(card3)
horizontalCardContainer.addSubLayer(close1)
horizontalCardContainer.addSubLayer(close2)
horizontalCardContainer.addSubLayer(close3)

# The following two events, handle the card's drag movement
# DragStart saves the inition position of the drag movement
horizontalCardContainer.on Events.DragStart, ->
	initialDragPosition = horizontalCardContainer.x

# When the drag movement ends, measure the displacement.
# Depending on the displacement and appropriate action is taken.
horizontalCardContainer.on Events.DragEnd, ->
	displacement = (initialDragPosition - horizontalCardContainer.x)
	initialState = horizontalCardContainer.states.state

	# If the displacement was smaller than 1/8 of the screen, cancel the drag.
	if Math.abs(displacement) < screenWidth / 8
		horizontalCardContainer.states.switch(initialState)
	else
		
		# You cannot go from state 'card3' to state 'card1'
		if displacement > 0 and initialState != "card3"
			horizontalCardContainer.states.next()

		# You cannot go from state 'card1' to state 'card3'
		else if displacement < 0 and initialState != "card1"
			horizontalCardContainer.states.previous()

		else
			horizontalCardContainer.states.switch(initialState)

# Useful methods
# Generic method to turn a card to the front
turnFront = (frontLayer, backLayer) ->
	animationFront = frontLayer.rotateFront()
	animationBack = backLayer.rotateBack()

# Generic method to turn a card to its back
turnBack = (frontLayer, backLayer) ->
	animBack = animationBack.reverse()
	animFront = animationFront.reverse()
	animBack.start()
	animFront.start()
	
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

# This function receives a 4 layers and checks all the interaction events
# In this example, the closeLayer and the backLayer are the same.
# Ideally, you should have a layer only for the X button and use as closeLayer
handleCard = (frontLayer, backLayer, triggerLayer, closeLayer) ->
	triggerLayer.on Events.Click, ->		
		displacement = (initialDragPosition - horizontalCardContainer.x)
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
handleCard(card1, backCard1, aquaButton, close1)
handleCard(card2, backCard2, blueButton, close2)
handleCard(card3, backCard3, greenButton, close3)