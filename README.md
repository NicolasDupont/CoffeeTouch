# CoffeeTouch.js

CoffeeTouch.js is a multi-touch JavaScript library that allows you to create and handle easily your own multi-touch gestures.

It defines a naming convention to describe gestures and provides functions to handle them.


## Benefits

Some libraries already exist to handle multi-touch gestures like these ones:
- [jQuery Mobile](http://jquerymobile.com/),
- [Hammer.js](http://eightmedia.github.com/hammer.js/),
- [Scripty2](http://scripty2.com/),
- [Dojox Gesture](http://dojotoolkit.org/reference-guide/1.7/dojox/gesture.html#dojox-gesture),
- [Touchy](https://github.com/HotStudio/touchy),
- [TouchSwipe](http://labs.rampinteractive.co.uk/touchSwipe/demos/).

But all those libraries suffer from the same limitation: the developer can only listen to predefined gestures, not create his own ones.
Moreover, some of them come with many other features, they are heavy and library dependent.

So, benefits of CoffeTouch.js are the following:
- No dependencies.
- Lightweight.
- Easy to use.
- Allows developper to define his own gestures.

[Exhaustive list of JavaScript Libraries which deal with touch events.](https://github.com/bebraw/jswiki/wiki/Touch)

## Compatibility

As this library is for handle multi-touch gestures it does not work on desktop browsers. It was tested on following plateforms:
* iOS 4+
* Android 4.1+

# Getting Started

Include CoffeeTouch.js in your web page and you're done. 

```HTML
<script src="CoffeeTouch.js"></script>
````

## Listening to a gesture

### Examples

```JavaScript
document.getElementById("#whiteboard").onGesture("tap", function (event){
  alert("#whiteboard element has been tapped with one finger");
});
```
```JavaScript
document.getElementById("#whiteboard").onGesture("doubletap", function (event){
  alert("#whiteboard element has been double tapped with one finger");
});
```
```JavaScript
document.getElementById("#whiteboard").onGesture("doubletap, doubletap", function (event){
  alert("#whiteboard element has been double tapped with two fingers");
});
```

## Naming convention to describe gestures

A gesture is composed of one or more actions and an action is mapped to a finger.

### Action names
Here is an exhaustive list of all possible actions with which you can construct gestures:

* __Tap__: when the user taps on the screen
  - `tap`: single tap
  - `doubletap`: double tap, like a double click
* __Hold__: when the user holds his finger on the screen:
  - `fixed`: press and hold finger on the screen
  - `fixedend`: release finger after holding it.
* __Drag__: when the user moves his finger on the screen:
  - `drag`: any directional draging action
  - `up`: dragging finger upwards
  - `right`: dragging finger to the right
  - `down`: dragging finger downwards
  - `left`: dragging finger to the left
  - `dragend`: dragging finished (user remove finger from the screen)

#### Defined gestures
CoffeeTouch.js comes with some common predefined gestures which are:

* __Pinch__: when the user brings his fingers closer or spreads them.
  - `pinch`: bring fingers closer
  - `spread`: spread fingers
* __Flick__: when the user drags quickly on the screen
  - `flick`: a quick drag
  - `flick:direction`: flick in a particular direction (direction can be: `left`, `top`, `right`, `bottom`)
* __Rotation__: when the user rotates his fingers
  - `rotate`: any rotation
  - `rotate:cw`: clockwise rotation
  - `rotate:ccw`: counterclockwise rotation

### Defining a gesture

Gesture names are action names separated by a comma. Every action is mapped to specific fingers touching the screen. First action will be mapped to the first finger, etc. (see [Fingers order convention](#fingers-order-convention) to understand how each finger is mapped to an action). That way, you can compose any kind of gestures. Example:

* `up,up,up` means that three fingers are going upwards.
* `up,down,up` means that the first finger is going upwards, the second is going downwards, and the third going upwards.

For `pinch`, `spread` and `rotation`, you can specify the number of fingers used by the user.

Example:
* `three:pinch`: pinch with three fingers
* `three:rotate`: rotate with three fingers

### Fingers order convention

Fingers are ordered in the Western reading direction (`left` to `right`, `up` to `down`):
* If the gesture starts horizontally, fingers will be ordered from left to right.
* If the gesture starts vertically, fingers will be ordered from top to bottom.

You can listen to gestures with more or less precision. If you listen to a `drag` gesture, every move of a finger will execute your callback function. But if you listen to a `left` gesture, your callback function will be executed only if the finger is moving to the left.

**Notice that order is considered in the gesture name.** So a gesture description `left,right` is different from `right,left`. `left,right` represents a gesture where the first finger is going to the left and the second is going to the right. `right,left` is the opposite, the first finger is going to the right and the second is going to the left.

# Configuration

## Options

You can pass a hash of options as the third parameter.

The options are:

* `preventDefault` (defaults to `false`): prevent default behavior of browsers. For example, a double tap in iOS is a zoom, if `preventDefault` is set to `true`, it won't zoom.
* `flickSpeed` in `px/ms` (defaults to `0.5`): minimum speed of the fingers movement to trigger the flick.
* `flickTimeElapsed` in `ms` (defaults to `100`): minimum finger contact time for the gesture to be considered as a `flick`.


## Event information object

When the `onGesture` function is called, an `event` hash is passed as parameter.

**event**:

* `rotation`: rotation value in degrees
* `scale`: scale factor between fingers (only defined for gestures with two or more fingers)
* `nbFingers`: number of fingers for the gesture
* `timeStart`: time when the gesture started
* `timeElapsed`: time elapsed from the beginning of the gesture (in ms)
* `fingers[nbFingers]`: _Each finger has its own informations._
	- `startX`: initial X position
	- `startY`: initial Y position
	- `x`: actual X position
	- `y`: actual Y position
	- `timeStart`: time when the finger has touched the screen
	- `timeElapsed`: time elapsed from the beginning of the touch (in ms)
	- `panX`: distance moved in X
	- `panY`: distance moved in Y
	- `speed`: speed of the finger
	- `gestureName`: name of the gesture (_tap, doubletap, fixed or drag_)
	- `dragDirection`: direction of the drag (if there is one) - _up, down, righ or left_

## Provided functions

All functions are added to the Element’s prototype.

**myElement.onGesture(gestureDescription, callback):**

Calls `callback` when `gestureDescription` is executed on `myElement`

```JavaScript
// Listening to a `tap`
$("#whiteboard").onGesture("tap", function(event) {
  alert("#whiteboard element has been tapped with one finger");
});
```

**myElement.unbindGesture(gestureDescription, callback):**

Stop executing `callback` when `gestureDescription` is executed on `myElement`. [TODO] what happen if the callback is not already binded?

```JavaScript
var alertTap = function() {
  alert("I've been tapped");
}
// Listen to tap
$("#whiteboard").onGesture("tap", alertTap);
// When #whiteboard is tapped, `alertTap` function is called.

// Unbind `alertTap` function
$("#whiteboard").unbindGesture("tap", alertTap);
// `alertTap` won't be called if #whiteboard is tapped.
```

**myElement.makeGesture(gestureDescription):**

Triggers `gestureDescription` on `myElement`, can be used to simulate gesture.

```JavaScript
var alertTap = function() {
  alert("I've been tapped");
}
// Listen to tap
$("#whiteboard").onGesture("tap", alertTap);
// When #whiteboard is tapped, `alertTap` function is called.

// Simulate `tap` gesture
$("#whiteboard").makeGesture("tap");
// `alertTap` is called
```

### Listening to all gestures

If you want to listen to all gesture events, listen to the `all` gesture, and the callback function will be called with two arguments:

1. `name`: [TODO] explain
2. `event`: [TODO] explain

Example:

```JavaScript
// Listening to all events
$("#whiteboard").onGesture("all", function (name, event){
  alert(name + ' has been made on #whiteboard element');
});
```


# Examples

You can test the library online with your multitouch device:

- [Try some basic gestures](http://ndpnt.github.io/CoffeeTouch.js/examples/all/).
- [Compose your own gesture and test it!](http://ndpnt.github.io/CoffeeTouch.js/examples/try/).
- [Canvas example](http://ndpnt.github.io/CoffeeTouch.js/examples/canvas/).
It's a drawing canvas in which you can do:
    - Double tap with one finger to create a point
    - Tap with two fingers to create two points
    - Flick down with three fingers to clear the canvas
    - Tap with three fingers to validate your drawing
    - Spread/Pinch with two fingers to change the radius of selected point
    - Spread/Pinch with three fingers to change the radius of unselected points

# Issues
Discovered a bug? Please [create an issue](https://github.com/NicolasDupont/CoffeeTouch.js/issues).

# Motivation

This project began for the need of the company [Structure Computation](http://www.structure-computation.com/) to create a Web Application that allows to manipulate object in 3D visualization on iPad.

# Contributors

- Nicolas Dupont
- [Nima Izadi](https://nimz.co)

### Participated in creation

- Raphaël Bellec
- Nicolas Fernandez
- Pierre Corsini

# License

The code for this software is distributed under the MIT License.
