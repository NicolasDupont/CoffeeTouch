class Analyser
	## Create an analyser object with total number of fingers and an array of all fingers as attribute
	constructor: (@totalNbFingers, @targetElement) ->
		@fingersArray = {} ## Hash with fingerId: fingerGestureObject
		@fingers = [] ## Array with all fingers		
		@firstAnalysis = true ## To know if we have to init the informations which will be returned
		@informations = {} ## All informations which will be send with the event gesture
		@informations.global = {} ## Informations corresponding to all fingers
		date = new Date()
		@informations.global.timeStart = date.getTime()
	## Notify the analyser of a gesture (gesture name, fingerId and parameters of new position etc)
	notify: (fingerID, gestureName, @eventObj) ->
		@informations.global.rotation = @eventObj.global.rotation 
		@informations.global.scale = @eventObj.global.scale
		date = new Date()
		@informations.global.timeElasped = date.getTime() - @informations.global.timeStart
		
		if @fingersArray[fingerID]?
			@fingersArray[fingerID].update gestureName, @eventObj
		else
			@fingersArray[fingerID] =  new FingerGesture(fingerID, gestureName, @eventObj)
			@fingers.push @fingersArray[fingerID]
		
		## Analyse event only when it receives the information from each fingers of the gesture.
		@analyse @totalNbFingers if _.size(@fingersArray) is @totalNbFingers
	
	analyse: (nbFingers) ->
		@init() if @firstAnalysis
		@gestureName = []
		@gestureName.push finger.gestureName for finger in @fingers
		@triggerDrag()
		@targetElement.trigger @gestureName, @informations
		@generateGrouppedFingerName()
		@triggerFixed()
		@triggerFlick()
		
	init: ->
		## Sort fingers. Left to Right and Top to Bottom
		@fingers = @fingers.sort (a,b) ->
			return a.params.startY - b.params.startY if Math.abs(a.params.startX - b.params.startX) < 15
			return a.params.startX - b.params.startX
		@informations.global.nbFingers = @fingers.length
		## For each finger, assigns to the information's event the information corresponding to this one.
		for i in [0..@fingers.length - 1]
			switch i
				when 0 then @informations.first = @fingers[0].params
				when 1 then @informations.second = @fingers[1].params
				when 2 then @informations.third = @fingers[2].params
				when 3 then @informations.fourth = @fingers[3].params
				when 4 then @informations.fifth = @fingers[4].params
		@firstAnalysis = false
	
	triggerDrag: -> 
		if @gestureName.contains "drag"
			@triggerDragDirections()
			if @gestureName.length > 1
				@triggerPinchOrSpread()
				@triggerRotation()

	triggerFixed: ->
		if @gestureName.length > 1 and @gestureName.contains "fixed"
			dontTrigger = false
			gestureName = []
			for finger in @fingers
				if finger.gestureName == "drag" and finger.params.dragDirection == "unknown"
					dontTrigger = true
					break
				if finger.gestureName == "drag" then gestureName.push finger.params.dragDirection else gestureName.push "fixed"
			if !dontTrigger
				@targetElement.trigger gestureName, @informations
			
	triggerFlick: ->
		if @gestureName.contains "dragend"
			gestureName1 = []
			gestureName2 = []
			dontTrigger = false
			for finger in @fingers
				if finger.params.dragDirection == "unknown" then dontTrigger = true
				if finger.isFlick
					gestureName1.push "flick:#{finger.params.dragDirection}"
					gestureName2.push "flick"
				else
					gestureName1.push finger.params.dragDirection
					gestureName2.push finger.params.dragDirection
			if !dontTrigger
				@targetElement.trigger gestureName1, @informations
				@targetElement.trigger gestureName2, @informations

	triggerDragDirections: ->
		gestureName = []
		gestureName.push finger.params.dragDirection for finger in @fingers
		@targetElement.trigger gestureName, @informations if !gestureName.contains "unknown"
		
	triggerRotation: -> 
		if !@lastRotation?
			@lastRotation = @informations.global.rotation
		rotationDirection = ""
		if @informations.global.rotation > @lastRotation then rotationDirection = "rotate:cw" else rotationDirection = "rotate:ccw"	
		@lastRotation = @informations.global.rotation
		@targetElement.trigger rotationDirection, @informations
		@targetElement.trigger "rotate", @informations

	triggerPinchOrSpread: ->
		# The scale is already sent in the event Object
		# @informations.global.scale = @calculateScale()
		## Spread and Pinch detection
		if @informations.global.scale < 1.1
			@targetElement.trigger "#{digit_name(@fingers.length)}:pinch", @informations
			@targetElement.trigger "pinch", @informations
		else if @informations.global.scale > 1.1
			@targetElement.trigger "#{digit_name(@fingers.length)}:spread", @informations
			@targetElement.trigger "spread", @informations

	generateGrouppedFingerName: -> 
		gestureName = [] 
		gestureNameDrag = []
		triggerDrag = false
		gestures = 
			tap: 0
			doubletap: 0
			fixed: 0
			fixedend: 0
			drag: 0
			dragend: {n: 0, fingers: []}
			dragDirection:
				up: 0
				down: 0
				left: 0
				right: 0
				drag: 0
		
		for finger in @fingers
			switch finger.gestureName
				when "tap" then gestures.tap++
				when "doubletap" then gestures.doubletap++
				when "fixed" then gestures.fixed++
				when "fixedend" then gestures.fixedend++
				when "dragend" 
					gestures.dragend.n++
					gestures.dragend.fingers.push finger
				when "drag"
					gestures.drag++
					switch finger.params.dragDirection
						when "up" then gestures.dragDirection.up++
						when "down" then gestures.dragDirection.down++
						when "right" then gestures.dragDirection.right++
						when "left" then gestures.dragDirection.left++
		for gesture of gestures
			## For the flick, I consider that if two drag end has been done at the same time and one of them is
			## a flick, both of them where flick
			if gesture == "dragend" and gestures[gesture].n > 0
				for finger in gestures[gesture].fingers
					if finger.isFlick
						gestureName.push "#{digit_name(gestures[gesture].n)}:flick" 
						gestureNameDrag.push "#{digit_name(gestures[gesture].n)}:flick:#{finger.params.dragDirection}"
						break
			else if gesture == "dragDirection"
				for gestureDirection of gestures[gesture]
					if gestures[gesture][gestureDirection] > 0
						gestureNameDrag.push "#{digit_name(gestures[gesture][gestureDirection])}:#{gestureDirection}" 
						triggerDrag = true
			else if gestures[gesture] > 0
				gestureName.push "#{digit_name(gestures[gesture])}:#{gesture}"
				gestureNameDrag.push "#{digit_name(gestures[gesture])}:#{gesture}" if gesture != "drag"

		@targetElement.trigger gestureName, @informations if gestureName.length > 0
		@targetElement.trigger gestureNameDrag, @informations if triggerDrag
				
window.onload = ->
	$("blue").onGesture "all", (name, event) ->
		$('debug').innerHTML = "#{name}<br />" + $('debug').innerHTML
