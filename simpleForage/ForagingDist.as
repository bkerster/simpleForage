package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	
	import flash.media.Sound;
	import flash.media.SoundChannel
	
	import flash.text.*
	
	import flash.utils.Timer;
    import flash.ui.Mouse;
    import flash.ui.Keyboard;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import fl.motion.MatrixTransformer;
	import hiScoreClass

	public class ForagingDist extends MovieClip {
		
		//*************************
		// Properties:
		public var clustered:Boolean;
		public var clusteringCondition:String;
		public var numStarCondition:String;
		public var moveTimeCondition:Boolean = true;
		
		public var initx:Number = 0;
		public var inity:Number = 0;
			
		public var speed:Number = 0;
		
		public var up:Boolean = false;
		public var down:Boolean = false;
		public var left:Boolean = false;
		public var right:Boolean = false;
		public var scanMode:Boolean = false;
		public var zoomed:Boolean = false;
		public var noFuel:Boolean = false;
		
		public var zoomX:Number;
		public var zoomY:Number;
		
		public var score:Number = 0;
		public var totalScore:Number = 0;
		public var highScore:Number = 250;
		public var randomHiScore:Number = 250;
		public var clusteredHiScore:Number = 250;
		
		public var hiScoreArray:Array = new Array(10);
		
		private var starField:Sprite = new Sprite();
		private var uiContainer:Sprite = new Sprite();
		
		private var stars:Array = new Array();
		private var overflowStars:Array = new Array();
		private var ship = new Trek();
		private var scoreDisplay = new TextField();
		private var fuelTextDisplay = new TextField();
		
		public var backdrop:Array = new Array();
		public var overflowBackdrop:Array = new Array();
		
		private var squareWi = new SquareW();
		private var squareYi = new SquareY();
		
		public var backGroundSprite:Sprite = new MovieClip();
		public var image:Bitmap;
		
		public var locX:Number;
		public var locY:Number;
		
		//sound channels
		public var thrusterChannel:SoundChannel = new SoundChannel();
		public var coinChannel:SoundChannel = new SoundChannel();
		public var zoomChannel:SoundChannel = new SoundChannel();
		public var buzzChannel:SoundChannel = new SoundChannel();
		
		public var starIndex:Array = new Array();
		public var starForaged:Array = new Array();
		public var starsOut:Array = new Array();
		
		public var nodes:Array = new Array();
		
		public var lastClickedStarIndex:Number = 0;
		public var lastClickedStars:Array = new Array();
		
		public var splicePoint:int = 0;
		
		//global tweens
		public var mcX_tween:Tween;
		public var mcY_tween:Tween;
		
		//fuel stuff
		public var fuel:Number;
		public var startFuel:Number = 300;
		public var fuelDisplay = new TextField();
		public var prevX:Number = (VIEW_XWINDOW / 2);
		public var prevY:Number = (VIEW_YWINDOW / 2);
		public var prevAngle:Number = 90;
		public var fuelBar = new FuelBar();
		public var fuelBG:Shape = new Shape();
		
		public var circle = new Circle();
		public var clicksAllowed:Boolean = true;
		
		public var positionArray:Array = new Array();
		public var frameNumber:Number = 0;
		
		public var scoreEffectFrame:Number = 0;
		
		public var gameEnded:Boolean = false;
		public var framePlusOne:Number = 3;
		
		public var playerName;
		public var trialNum = -1;
		public var currentTrial:Number;
		
		public var randPicker:Array = new Array(1,2,3,4,5,6);
		
		//variable used to march through the instructions, 
		//should be incremented by an OnClick event handler 
		//to move through the instructions
		public var instructionNumber:int = 1; 		
		
		public var restartButton:SimpleButton;
		public var inputField:TextField = new TextField();
		public var instructField:TextField = new TextField();
		
		public var saveField:TextField = new TextField();
		
		public var totalStars:Number = 0;
		
		public var urlLoader:URLLoader = new URLLoader();
		public var hiUrlLoader:URLLoader = new URLLoader();
		
		public var cursorBox = new CursorBox();
		
		//variable to prevent rediving
		public var diveStop:int = 0;
		
		//dive counter and distance counter
		public var diveCount:int = 0;
		public var distanceCount:Number = 0;
		
		public var outputArray:Array = new Array();
			
		public static const VIEW_XWINDOW:Number = 1280;
		public static const VIEW_YWINDOW:Number = 1024;
		public static const SCANNER_RADIUS:Number = 10;
		public static const ENVIRONMENT_XWINDOW:Number = 1280;
		public static const ENVIRONMENT_YWINDOW:Number = 1024;
		public static const SPEED_INCREMENT:Number = 10;
		public static const ZOOM_FACTOR:Number = 15;
			
		//*************************
		// Constructor:
		public function ForagingDist() {
			stage.frameRate = 30;
			
			selectNumStars();
			selectStarDensity();
			if (clusteringCondition == "5") {
				clustered = false;
			}
			else {
				clustered = true;
			}
			if (Math.random() < .5) {
				moveTimeCondition = false;
			}
			
			var chars:Array = new Array("0","1","2","3","4","5","6","7","8","9");
			playerName = chars[(Math.floor(Math.random() * (10)) + 0)] + chars[(Math.floor(Math.random() * (10)) + 0)] + chars[(Math.floor(Math.random() * (10)) + 0)] + chars[(Math.floor(Math.random() * (10)) + 0)] + chars[(Math.floor(Math.random() * (10)) + 0)] + chars[(Math.floor(Math.random() * (10)) + 0)] + chars[(Math.floor(Math.random() * (10)) + 0)];
			
			// draw starbackground and add to starField
			starField.graphics.beginFill(0x000000, 1);
			starField.graphics.drawRect(0, 0, (ENVIRONMENT_XWINDOW + VIEW_XWINDOW), (ENVIRONMENT_YWINDOW + VIEW_YWINDOW));
			starField.graphics.endFill();
			
			//draw instructions, and input text field
			var fieldFormat:TextFormat = new TextFormat();
			fieldFormat.size = 30;
			fieldFormat.color = 0xFFFFFF;
			instructField.defaultTextFormat = fieldFormat;
			instructField.text = "Please type your SONA ID number and then press 'Enter'"
			instructField.autoSize = TextFieldAutoSize.CENTER;
			instructField.x = (VIEW_XWINDOW / 2) - (instructField.width / 2);
			instructField.y = (VIEW_YWINDOW / 2) - 30;
			
			fieldFormat.color = 0x000000;
			fieldFormat.size = 18;
			inputField.defaultTextFormat = fieldFormat;
			inputField.backgroundColor = 0xFFFFFF;
			inputField.background = true;
			inputField.width = 200;
			inputField.height = 30;
			inputField.x = (VIEW_XWINDOW / 2) - (inputField.width / 2);
			inputField.y = (VIEW_YWINDOW / 2) + 10;
			inputField.type = "input";
			inputField.multiline = false;
			inputField.restrict = "A-Za-z0-9";
			
			displayInstructions();

		}
		
		//*************************
		// Event Handling:		
		protected function enterFrameHandler(event:Event):void
		{	
			if (score == totalStars && score > 0) {
				gameOver();
			}
			frameNumber++;
			if (fuel > 0) {
				positionArray[frameNumber] = [ship.x,ship.y,scanMode,score]; //used for printout
				cursorBox.x = mouseX;
				cursorBox.y = mouseY;
				
				//change fuel
				var dist:Number = getDistance(prevX, prevY, ship.x, ship.y);

				if (!noFuel) {
					if (zoomed) {
						fuel -= dist / ZOOM_FACTOR;
						distanceCount += dist / ZOOM_FACTOR;
					}
					else {
						fuel -= dist;
						distanceCount += dist;
						if (getDistance(zoomX, zoomY, ship.x, ship.y) > 3) {
							diveStop = 0;
						}
					}
				}
				updateFuelBar();
				prevX = ship.x;
				prevY = ship.y;
				
				if (frameNumber == scoreEffectFrame) {
					//restore the socre display
					var format:TextFormat = new TextFormat();
					format.color = 0xFFFFFF;
					format.size = 28;
					scoreDisplay.setTextFormat(format);
					scoreDisplay.defaultTextFormat = format;
				}
				// Timing and Write functions here
				//printOut("mouse", mouseStream);
			}
			else {
				if (!gameEnded) {
					fuel = 0;
					gameOver();
				}
			}
			
			noFuel = false;
			//work around to prevent double click read when the games ends 
			//(ship would move straight to the button at beginning of trials)
			if (gameEnded) {
				framePlusOne = frameNumber + 3;
			}
			else {
				if (frameNumber == framePlusOne) {
					stage.addEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
					fuel = startFuel;
					if (trialNum == 0) {
						fuel = startFuel;
					}
					if (trialNum == 1 || trialNum == 3) {
						fuel = 15;
					}
				}
			}
		}

		protected function clickHandler(event:MouseEvent):void
		{
			if (!gameEnded && clicksAllowed) {
				//store starting coords of mouse and ship
				var mX:Number = mouseX;
				var mY:Number = mouseY;
				//if a click occurs: draw the box. 
				//check either collison with the box (no)
				// or check stars in a given area
				//then reduce fuel
				if (mX > 0 && mY > 0 && mX < VIEW_XWINDOW && mY < VIEW_YWINDOW) {
					fuel--;
					if (moveTimeCondition) {
						clicksAllowed = false;
						locX = mX;
						locY = mY;
						moveTime();
					}
					else {
						var foundResource:Boolean = checkCollision(mX, mY);
						drawSquare(foundResource, mX, mY);
					}
				}					
			}
			printOut("Click");
		}

		protected function startExperiment(event:KeyboardEvent):void
		{
			switch( event.keyCode )
			{
				case Keyboard.ENTER:
					
					playerName = inputField.text;

					inputField.removeEventListener(KeyboardEvent.KEY_DOWN, startExperiment);
					removeChild(inputField);
					removeChild(instructField);
					displayInstructions();
					break;
			}
		}
		
		//grabs the players initials when they press enter.
		//need to decide where to store data
		protected function initialsListener(event:KeyboardEvent):void
		{
			switch( event.keyCode )
			{
				case Keyboard.ENTER:
					hiScoreArray[splicePoint].accessInitial = inputField.text.toUpperCase();
					inputField.removeEventListener(KeyboardEvent.KEY_DOWN, initialsListener);
					removeChild(inputField);
					saveScore(); //saves score to disk
					displayHighScore();
					
					break;					
			}
		}
		
		protected function tweenFinishHandler(event:TweenEvent):void
		{
			clicksAllowed = true;
			circle.x = locX;
			circle.Y = locY;
			var foundResource:Boolean = checkCollision(locX, locY);
			drawSquare(foundResource, locX, locY);
			removeChild(circle);
			printOut("land");
		}
		
		protected function tweenScaleHandler(event:TweenEvent):void
		{
			var scaleX_tween:Tween = new Tween(event.target.obj, "width", None.easeNone, 5.25, 2.65, 0.5, true);
			var scaleY_tween:Tween = new Tween(event.target.obj, "height", None.easeNone, 5.25, 2.65, 0.5, true);
		}
		
		//call commands to restart the task
		protected function restartButtonListener(event:MouseEvent):void
		{
			restartButton.removeEventListener(MouseEvent.CLICK, restartButtonListener);
			starField.removeChild(restartButton);
			
			gameEnded = false;
			
			trace("Button TRIAL: " + String(trialNum));
			if (trialNum == -1) {
				//remove the preview nodes. make sure this gets called properly
				trace(nodes.length);
				for (var i = 0; i < nodes.length; i++) {
					starField.removeChild(nodes[i]);
				}
				removeChild(instructField);
				trialNum++;
				trace(trialNum);		
				removeChild(starField);
				init();				
			}
			if (trialNum == 2) {
				if (moveTimeCondition == true) {
					moveTimeCondition = false;
				}
				else {
					moveTimeCondition = true;
				}
				displayInstructions2();
			}
			else {
				trialNum++;
				init();
			}
		}
		
		//called after readstars completes
		//builds the node list from the data
		protected function urlLoader_complete(event:Event):void
		{
			var resources:String = urlLoader.data; 
			var lines:Array = resources.split("\n");
			//remove previously placed nodes and empty the array
			if (trialNum >= 1) {
				for (var count:Number = 0; count < nodes.length; count++) {
					nodes.pop();
				}
			}
			//go through file a line at a time to build the collection of nodes
			//the final line is empty, so skip it
			for (var i:int = 0; i < lines.length - 1; i++) {
				var line:Array = lines[i].split(" ");
				if (Number(line[2]) > 1) {
					nodes[i] = new asteroid2();
				}
				else {
					nodes[i] = new asteroid();
				}
				nodes[i].x = Number(line[0]); //set x location
				nodes[i].y = Number(line[1]); //set y location
				nodes[i].rotation = Math.floor(Math.random()*(1+180+180))-180; 
				
				nodes[i][1] = Number(line[2]); //set resource value
				nodes[i][2] = 0; //set to "unfound" state
				totalStars += Number(line[2]);
				
				if (trialNum >= 0) {
					nodes[i].scaleX = 1 / ZOOM_FACTOR;
					nodes[i].scaleY = 1 / ZOOM_FACTOR;
				}
			}
			scoreDisplay.text = "[ " + score + " ]";
		}
		
		protected function hiScoreUrlLoader_complete(event:Event):void
		{
			var resources:String = hiUrlLoader.data;
			var lines:Array = resources.split("\n");
			
			for (var i:int = 0; i < lines.length; i++){
				var line:Array = lines[i].split(" ");				
				hiScoreArray[i] = new hiScoreClass(line[0], int(line[1]));		
			}
			checkHighScore();
		}
		
		//catches the click event on instructions
		//iterates the instruction number
		//clears out items to make room for the next
		protected function instructionsClickHandler(event:MouseEvent):void
		{
			removeChild(instructField);
			stage.removeEventListener(MouseEvent.CLICK, instructionsClickHandler);
			switch (instructionNumber)
			{
				case 1:
					removeChild(ship);
					break;
				case 2:
					removeChild(fuelBG);
					removeChild(fuelBar);
					var arrow = uiContainer.getChildByName("arrow1");
					uiContainer.removeChild(arrow);								
					break;
				case 3:
					uiContainer.removeChild(squareYi);
					uiContainer.removeChild(squareWi);
					removeChild(uiContainer);
					break;
				case 4:
					
					break;
				case 5:
					
					break;
				case 6:
				
					break;
				case 7:
					displayPreview();
				default:
					
					break;
			}
			
			instructionNumber++;
			displayInstructions();
		}
		
		protected function instructions2Handler(event:MouseEvent):void
		{
			removeChild(instructField);
			stage.removeEventListener(MouseEvent.CLICK, instructions2Handler);
			
			trialNum++;
			init();
		}
		
		protected function hiScoresClickHandler(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.CLICK, hiScoresClickHandler);
			removeChild(instructField);
			removeChild(saveField);
			showDebriefing();
		}
		
		protected function onCompleteHandler(event:Event):void
		{
			saveField.text = "Data Successfully Saved. \nClick to continue."
			saveField.autoSize = TextFieldAutoSize.CENTER;
			saveField.x = (VIEW_XWINDOW / 2) - ( saveField.textWidth / 2 );
			stage.addEventListener(MouseEvent.CLICK, hiScoresClickHandler);
		}
		
		protected function onErrorHandler(event:IOErrorEvent):void {
			
			saveField.text = "ERROR SAVING DATA! ALERT THE EXPERIMENTER IMMEDIATLY"
			saveField.autoSize = TextFieldAutoSize.CENTER;
			saveField.x = VIEW_XWINDOW / 2;						
		}		
		
		//handles the Yellow square animation
		protected function squareYeventHandler(event:Event):void
		{
			if(event.target.currentFrame == event.target.totalFrames)
            {
                event.target.stop();
				stage.removeChild(DisplayObject(event.target));
				event.target.removeEventListener(Event.ENTER_FRAME, squareYeventHandler)
            }

		}
		
		//handles the White square animation
		protected function squareWeventHandler(event:Event):void
		{
			if(event.target.currentFrame == event.target.totalFrames)
            {
                event.target.stop();
				stage.removeChild(DisplayObject(event.target));
				event.target.removeEventListener(Event.ENTER_FRAME, squareWeventHandler)
            }

		}
		
		//*************************
		// Public methods:		
		
		//Initializes the experiment to begin a trial
		public function init():void
		{

			trace("Trial Num: " + String(trialNum) );
			var str:String = "\nStart Trial " + String(trialNum) + " moveTime " + String(moveTimeCondition) + " PLAYER " + playerName + "\n";
			outputArray.push(str);
			
			if (trialNum == 0) {
				backGroundSprite.graphics.beginBitmapFill(new Hubble0(0, 0), null, false);
				fuel = startFuel;
				currentTrial = 0;
			}
			else if (trialNum > 0 ) {

				var selection:int = int(Math.floor(Math.random() * (1+randPicker.length-1-0)) + 0);
				currentTrial = randPicker[selection];
				randPicker.splice(selection, 1)
				trace("Background:" + String(currentTrial));
				
				switch( currentTrial ) {
					case 1:
						backGroundSprite.graphics.beginBitmapFill(new Hubble1(0, 0), null, false);
						break;
					case 2:
						backGroundSprite.graphics.beginBitmapFill(new Hubble2(0, 0), null, false);
						break;
					case 3:
						backGroundSprite.graphics.beginBitmapFill(new Hubble3(0, 0), null, false);
						break;
					case 4:
						backGroundSprite.graphics.beginBitmapFill(new Hubble4(0, 0), null, false);
						break;
					case 5:
						backGroundSprite.graphics.beginBitmapFill(new Hubble5(0, 0), null, false);
						break;
					case 6:
						backGroundSprite.graphics.beginBitmapFill(new Hubble6(0, 0), null, false);
						break;
					default:
						backGroundSprite.graphics.beginBitmapFill(new Hubble1(0, 0), null, false);
						break;
				}
			}
			
			backGroundSprite.graphics.drawRect(0,0,VIEW_XWINDOW,VIEW_YWINDOW);
			backGroundSprite.graphics.endFill();
			starField.addChild(backGroundSprite);

			readStars(currentTrial);

			starField.x = 0;
			starField.y = 0;
			addChild(starField);
			
			//mask to prevent image from leaving the field
			var boardMask:Shape = new Shape();
			boardMask.graphics.beginFill(0xDDDDDD);
			boardMask.graphics.drawRect(0,0, VIEW_XWINDOW, VIEW_YWINDOW);
			boardMask.graphics.endFill();
			starField.addChild(boardMask);
			backGroundSprite.mask = boardMask;
			
			// draw ship and add
			uiContainer.x = 0;
			uiContainer.y = 0;
			addChild(uiContainer);
			uiContainer.addChild(cursorBox);
			
			//initialize score and add text display
			score = 0;
			var scoreFormat:TextFormat = new TextFormat();
			scoreFormat.size = 28;
			scoreDisplay.defaultTextFormat = scoreFormat;
			scoreDisplay.text = "[ " + score + " ]";
			scoreDisplay.autoSize = TextFieldAutoSize.LEFT;
			scoreDisplay.textColor = 0xFFFFFF;
			scoreDisplay.x = 5;
			scoreDisplay.y = 5;
			uiContainer.addChild(scoreDisplay);
			
			// Update screen every frame
			addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			
			if (trialNum > 0 ) {
				fuel = startFuel;
			}
			if (trialNum == 1 || trialNum == 3) {
				instructField.text = "PRACTICE";
				addChild(instructField);
				fuel = 15;
			}
			ship.x = (VIEW_XWINDOW / 2);
			ship.y = (VIEW_YWINDOW / 2);
			
			//intialize the fuel text display (goes next to fuel bar)
			var fuelTextFormat:TextFormat = new TextFormat();
			fuelTextFormat.size = 24;
			fuelTextDisplay.defaultTextFormat = scoreFormat;
			fuelTextDisplay.text = "[ " + fuel + " ]";
			fuelTextDisplay.autoSize = TextFieldAutoSize.RIGHT;
			fuelTextDisplay.textColor = 0xFFFFFF;
			fuelTextDisplay.x = VIEW_XWINDOW - 500;
			fuelTextDisplay.y = 2 ;
			uiContainer.addChild(fuelTextDisplay);

			drawFuelBar();
		}
		
		//reads in stars from a text file based on the trial number
		public function readStars(currentTrial):void
		{
			totalStars = 0;
			var path:String;
			var map_num:Number = (Math.floor(Math.random() * (0 - 999 + 1)) + 0)
			trace("Map Number: " + String(map_num));			
			path = "maps/" + numStarCondition + "stars" + clusteringCondition + String(map_num) + ".txt";
			trace(path);
			
			var str:String = path + " " + String(currentTrial) + "\n";
			outputArray.push(str);
			
			var urlRequest:URLRequest = new URLRequest(path);			
			urlLoader.addEventListener(Event.COMPLETE, urlLoader_complete);			
			urlLoader.load(urlRequest);	
		}
		
		//tests if a resource is at the given location
		//depracated
		public function checkNodeCollision(collider):void
		{
			if (zoomed) {
				var scoreIncrease:Number = 0;
				var nodeHit:Boolean = false;
				for (var i:Number = 0; i < nodes.length; i++) {
					if (ship.hitTestObject(nodes[i])) {
						nodeHit = true;
						var nodeScale_tween = new Tween(nodes[i],"width", None.easeNone, 2.65, 5.25, 0.5, true);
						var nodeYScale_tween = new Tween(nodes[i], "height", None.easeNone, 2.65, 5.25, 0.5, true);
						nodeScale_tween.addEventListener(TweenEvent.MOTION_FINISH, tweenScaleHandler);
						if (nodes[i][2] == 0) {
							nodes[i][2] = 1; //set node as foraged
							score += Number(nodes[i][1]); //increase score
							scoreIncrease += Number(nodes[i][1]);
							scoreDisplay.text = "[ " + score + " ]"
							printOut("Gathered");
						}
					}
				}
				if (nodeHit) {
					buzzChannel.stop();
					var coinSound:Sound;
					switch (scoreIncrease)
					{
						case 0:
							var buzzSound:Sound = new BuzzSound();
							buzzChannel = buzzSound.play();
							break;
						case 1:
							coinSound = new CoinSound();
							coinChannel = coinSound.play();
							break;
						case 2:
							coinSound = new CoinSound2();
							coinChannel = coinSound.play();
							break;
						case 3:
							coinSound = new CoinSound3();
							coinChannel = coinSound.play();
							break;
						case 4:
							coinSound = new CoinSound4();
							coinChannel = coinSound.play();
							break;
						case 5:
							coinSound = new CoinSound6();
							coinChannel = coinSound.play();
							break;
						case 6:
							coinSound = new CoinSound6();
							coinChannel = coinSound.play();
							break;
						case 7:
							coinSound = new CoinSound7();
							coinChannel = coinSound.play();
							break;
						case 8:
							coinSound = new CoinSound8();
							coinChannel = coinSound.play();
							break;
						default:
							coinSound = new CoinSound9();
							coinChannel = coinSound.play();
							break;
					}
				}
			}
		}
				
		public function checkCollision(mX:Number, mY:Number):Boolean
		{
			var scanWidth:Number = 15;
			var scanRadius:Number = scanWidth / 2;
			var scoreIncrease:int = 0;
			var found:Array = new Array();

			//checks if its inside the square.
			for (var i:int = 1; i < nodes.length; i++) {
				if ( (nodes[i].x > (mX - scanRadius)) && (nodes[i].x <= (mX + scanRadius)) && (nodes[i].y > (mY - scanRadius)) && (nodes[i].y <= (mY + scanRadius) ) && nodes[i][1] > 0 ) {
					//check to make sure I'm getting the correct values
					scoreIncrease += nodes[i][1]
					nodes[i][1] = 0;
					found.push(i);
				}
			}
		
			if (scoreIncrease > 0) {
				buzzChannel.stop();
				var coinSound:Sound;
				switch (scoreIncrease)
				{
					case 0:
						var buzzSound:Sound = new BuzzSound();
						buzzChannel = buzzSound.play();
						break;
					case 1:
						coinSound = new CoinSound();
						coinChannel = coinSound.play();
						break;
					case 2:
						coinSound = new CoinSound2();
						coinChannel = coinSound.play();
						break;
					case 3:
						coinSound = new CoinSound3();
						coinChannel = coinSound.play();
						break;
					case 4:
						coinSound = new CoinSound4();
						coinChannel = coinSound.play();
						break;
					case 5:
						coinSound = new CoinSound6();
						coinChannel = coinSound.play();
						break;
					case 6:
						coinSound = new CoinSound6();
						coinChannel = coinSound.play();
						break;
					case 7:
						coinSound = new CoinSound7();
						coinChannel = coinSound.play();
						break;
					case 8:
						coinSound = new CoinSound8();
						coinChannel = coinSound.play();
						break;
					default:
						coinSound = new CoinSound9();
						coinChannel = coinSound.play();
						break;
				}
				for (i = found.length; i >= 0; i--) {
					nodes.splice(found[i], 1);
				}
				//Change the score Display on score
				var format:TextFormat = new TextFormat();
				format.color = 0xFFFF00;
				format.size = 46;
				scoreDisplay.setTextFormat(format); 
				scoreDisplay.defaultTextFormat = format;
				scoreEffectFrame = frameNumber + 7; //change the size and color for 5 frames
			}
			score += scoreIncrease;
			scoreDisplay.text = "[ " + score + " ]";
			if (scoreIncrease > 0 ) {
				return true;
			}
			return false;
		}
		
		//find the distance between a pair of points
		public function getDistance(x1:Number,y1:Number, x2:Number,y2:Number):Number
		{
			var x:Number = (x2-x1) * (x2-x1);
			var y:Number = (y2-y1) * (y2-y1);
			var dist:Number = Math.sqrt(x + y);
			//trace(dist);
			return dist;
		}
		
		//angular distance
		public function getAngle(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{    
			var radians:Number = Math.atan2(y1-y2, x1-x2);
			return rad2deg(radians); 
		}
		
		public function rad2deg(rad:Number):Number
		{   
			return rad * (180 / Math.PI);
		}
		
		//zooms in around the ship's current location
		//deprecated
		public function zoomIn():void
		{
			zoomChannel.stop();
			zoomX = ship.x;
			zoomY = ship.y;
			stopShip();
			
			printOut("ZoomIn");
			
			for (var i = 0; i < nodes.length; i++) {
				backGroundSprite.addChild(nodes[i]);
			}
			
			scaleAroundPoint(backGroundSprite, ship.x, ship.y, ZOOM_FACTOR, ZOOM_FACTOR);
			ship.x = VIEW_XWINDOW / 2;
			ship.y = VIEW_YWINDOW / 2;
			noFuel = true;
			var zoomInSound:Sound = new ZoomInSound();
			zoomChannel = zoomInSound.play(10);
			
			//change ship size
			var scaleX_shipTween:Tween = new Tween(ship, "scaleX", None.easeNone, 1, 2, 0.3, true);
			var scaleY_shipTween:Tween = new Tween(ship, "scaleY", None.easeNone, 1, 2, 0.3, true);
			fuel -= 70;
			
		}
		
		//scales and moves an object around a given point
		public static function scaleAroundPoint(objToScale:DisplayObject, regX:int, regY:int, scaleX:Number, scaleY:Number):void{
            if (!objToScale){
                return;
            }
            var transformedVector:Point = new Point( (regX-objToScale.x)*scaleX, (regY-objToScale.y)*scaleY );
            
            objToScale.x = regX-( transformedVector.x);
            objToScale.y = regY-( transformedVector.y);
            objToScale.scaleX = objToScale.scaleX*(scaleX);
            objToScale.scaleY = objToScale.scaleY*(scaleY);
		}
		
		//zooms the screen back out and hides the resources
		//deprecated
		public function zoomOut():void
		{
			for (var i = 0; i < nodes.length; i++) {
				nodes[i].height = 2.65;
				nodes[i].width = 2.64;
				backGroundSprite.removeChild(nodes[i]);
			}
			
			var shipX:int = int(zoomX - (VIEW_XWINDOW / ZOOM_FACTOR / 2) + (ship.x / ZOOM_FACTOR))
			var shipY:int = int(zoomY - (VIEW_YWINDOW / ZOOM_FACTOR / 2) + (ship.y / ZOOM_FACTOR))
			backGroundSprite.width = ENVIRONMENT_XWINDOW;
			backGroundSprite.height = ENVIRONMENT_YWINDOW;
			backGroundSprite.x = 0;
			backGroundSprite.y = 0;

			stopShip();
			ship.x = shipX;
			ship.y = shipY;
			//check for people venturing off the map
			if (shipX < 0) {
				ship.x = 0;
			}
			else if (shipX > VIEW_XWINDOW) {
				ship.x = VIEW_XWINDOW;
			}
			if (shipY < 0) {
				ship.y = 0;
			}
			else if (shipY > VIEW_YWINDOW) {
				ship.y = VIEW_YWINDOW;
			}
			noFuel = true;
			var zoomOutSound:Sound = new ZoomOutSound();
			zoomChannel = zoomOutSound.play(10);
			
			//change ship size
			var scaleX_shipTween:Tween = new Tween(ship, "scaleX", None.easeNone, 2, 1, 0.3, true);
			var scaleY_shipTween:Tween = new Tween(ship, "scaleY", None.easeNone, 2, 1, 0.3, true);
			
			printOut("ZoomOut");
		}
		
		//if the ship is moving it is stopped, and collision is checked
		//deprecated
		public function stopShip():void
		{
			if (mcX_tween != null) {
				if (mcX_tween.isPlaying){
					thrusterChannel.stop();
					mcX_tween.stop();
					mcY_tween.stop();
					checkNodeCollision(ship);
				}
			}
		}

		public function drawFuelBar():void
		{
			var fuelPercent:int = int((fuel / startFuel) * 100 );
			fuelBar.width = 400;
			fuelBar.height = 10;
			fuelBar.x = VIEW_XWINDOW-420;
			fuelBar.y = 10;
			
			fuelBG.graphics.beginFill(0x000000);
			fuelBG.graphics.drawRect(VIEW_XWINDOW-425,5,410, 20);
			fuelBG.graphics.endFill();
			addChild(fuelBG);
			addChild(fuelBar);
		}
		
		public function updateFuelBar():void
		{
			var fuelPercent:Number = (fuel / startFuel);
			fuelBar.width = 400 * fuelPercent;
			
			fuelTextDisplay.text = "[ " + fuel + " ]";;
		}
		
		//displays an image that shows how resources may appear before the start of the practice trial
		//also checks that a good filename is used
		public function displayPreview():Boolean
		{
			var fileName:String = playerName + "Trial" + String(trialNum);	
			var logName:String = "Log" + fileName + ".txt"
		
			starField.addChild(backGroundSprite);
			starField.x = 0;
			starField.y = 0;
			addChild(starField);
			
			//draw the nodes
			for (var i = 0; i < nodes.length; i++) {
				starField.addChild(nodes[i]);
				nodes[i].scaleX = 0.3;
				nodes[i].scaleY = 0.3
			}
			instructField.text = "JUST AN\n\nEXAMPLE";
			addChild(instructField);
			trace("Preview");
			
			restartGameButton(); 
			//stage.addEventListener(KeyboardEvent.KEY_DOWN,endPreviewListener);
			return true;
		}
		
		//Does some cleanup and shows finishing text when fuel is exhausted
		public function gameOver():void
		{
			totalScore += score;
			trace("game over");
			stopShip();
			if (zoomed) {
				zoomOut();
			}
			zoomed = false;
			thrusterChannel.stop()
			removeChild(fuelBar);
			gameEnded = true;
			uiContainer.removeChild(cursorBox);
			
			if (trialNum == 1 || trialNum == 3) {
				removeChild(instructField);
			}
			
			if (clicksAllowed == false) {
				removeChild(circle);
				clicksAllowed = true;
			}
			
			// remove event handlers
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, clickHandler);
			removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
			
			trace("Removed event Listeners");
			
			outputArray.push("FINISHED\n");
			//draw the restart game button
			if (trialNum < 4) {
				restartGameButton();
			}
			else {
				if (clustered) {
					highScore = clusteredHiScore;
				}
				else {
					highScore = randomHiScore;
				}
				
				//revert back to a plain screen

				removeChild(starField);
				removeChild(uiContainer);
				
				readHiScore();			
			}
		}
		
		// draws a restart game button which can start the next trial
		public function restartGameButton():void
		{
			restartButton = new RestartButton();
			if (trialNum > 0) {
				backGroundSprite.graphics.beginFill(0x000000, 1);
				backGroundSprite.graphics.drawRect(0,0,VIEW_XWINDOW,VIEW_YWINDOW);
				backGroundSprite.graphics.endFill();
				
				instructField.text = "Good Job!\n You found " + score + " planets.";
				addChild(instructField);
			}
			
			restartButton.x = VIEW_XWINDOW / 2;
			restartButton.y = VIEW_YWINDOW - 200;
			restartButton.hitTestState = restartButton.upState;
			starField.addChild(restartButton);
			restartButton.addEventListener(MouseEvent.MOUSE_UP, restartButtonListener)
		}
		
		public function readHiScore():void
		{
			//get hi score file name			
			var fileName:String = clusteringCondition + "-" + numStarCondition + "-hiScore.txt";
			trace("hi score filename: " + fileName);
			
			var urlRequest:URLRequest = new URLRequest(fileName);
			hiUrlLoader.addEventListener(Event.COMPLETE, hiScoreUrlLoader_complete);
			hiUrlLoader.load(urlRequest);
		}
		
		//checks the high score. calls get initials if there is a new high score
		public function checkHighScore():void
		{
			trace("Checking high score");
			trace("Number of scores " + String(hiScoreArray.length));
			
			//trim hi scores
			while (hiScoreArray.length > 10) {
				hiScoreArray.pop();
			}
			
			var newHighScore:Boolean = false;
			for (var i:int = 0; i < hiScoreArray.length; i++){
				trace("Accessing Score");
				trace(hiScoreArray[i].accessScore);
				if (totalScore > hiScoreArray[i].accessScore) {
					var scr:hiScoreClass = new hiScoreClass("", totalScore);
					newHighScore = true;
					hiScoreArray.splice(i, 0, scr);
					hiScoreArray.pop();
					splicePoint = i;
					trace("Number of scores after" + String(hiScoreArray.length));
					break;
				}
				
			}
			
			var fieldFormat:TextFormat = new TextFormat();
			fieldFormat.align = TextFormatAlign.CENTER;
			fieldFormat.size = 24;
			fieldFormat.color = 0xFFFFFF;
			//instructionDisplayFormat.align = TextFormatAlign.CENTER;
			
			instructField.defaultTextFormat = fieldFormat;
			instructField.text = "Your total score is " + totalScore + "\n The highest total score so far is " + highScore;
			instructField.autoSize = TextFieldAutoSize.CENTER;
			instructField.x = (VIEW_XWINDOW / 2) - (instructField.width / 2);
			instructField.y = (VIEW_YWINDOW / 2) - 30;
			if (newHighScore)
			{
				getInitials();
			}
			else
			{
				displayHighScore();
			}
			addChild(instructField);
		}
		
		//displays intructions
		//iterates through with each click
		public function displayInstructions():void
		{

			switch (instructionNumber)
			{
				case 1:
					var fieldFormat:TextFormat = new TextFormat();
					fieldFormat.align = TextFormatAlign.CENTER;
					instructField.defaultTextFormat = fieldFormat;
					instructField.text = "You have been placed in charge of the USS Stargazer.\n The Stargazer is a peaceful ship whose mission is to explore space for new worlds,\n as a source of resources for the United Federation of planets.";
					addChild(instructField);
					//add image of the ship, possibly of the ship moving
					ship.x = VIEW_XWINDOW / 2;
					ship.y = (VIEW_YWINDOW / 2) - 75;
					addChild(ship);
					stage.addEventListener(MouseEvent.CLICK, instructionsClickHandler);
					//for the preview later
					readStars(0);					
					break;
				case 2:
					instructField.text = "You explore space by sending out probes.\nEach probe can only scan a small subsection of space,\n and you have a limited supply.\n";
					addChild(instructField);
					//add image of a resource
					var resource = new asteroid();					
					//show the fuel bar
					drawFuelBar();
					//point to it
					var arrow = new Arrow();
					arrow.x = VIEW_XWINDOW - 200;
					arrow.y = 50;
					arrow.name = "arrow1";
					uiContainer.addChild(arrow);
					addChild(uiContainer);
					stage.addEventListener(MouseEvent.CLICK, instructionsClickHandler);
					break;
				case 3:
					//instructField.text = "Probes are deployed by clicking anywhere in space.\n They will scan the area of space indicated around your mouse cursor.\n Each time you scan, a small white box will appear for a short time\n demonstrating the area that was scanned.\n If you find a planet the box will appear yellow instead,\n and the number of planets found will be added to your score.\n Try to find as many planets as you can before running out of probes.\n\n Note: Please turn on your computer's sound"
					instructField.text = "One probe is deployed each time you click on a location in space.\n The probe will scan the area indicated by your mouse cursor \n If a probe finds no planets, a white box will appear in the cursor area.\n If one or more planets are found, a yellow box will appear instead, \nand one or more chimes will sound and the number of planets found will be added to your score.\n Try to find as many planets as you can before running out of probes.\n\nNote: Planet locations are NOT related to the background image."
					addChild(instructField);
					squareWi.gotoAndPlay(1);
					squareWi.x = 1070;
					squareWi.y = 570;
					squareYi.gotoAndPlay(1);
					squareYi.x = 1070;
					squareYi.y = 605;
					uiContainer.addChild(squareYi);
					uiContainer.addChild(squareWi);
					addChild(uiContainer);					
					stage.addEventListener(MouseEvent.CLICK, instructionsClickHandler);
					break;
				case 4: 
					if (moveTimeCondition) {
						instructField.text = "You will play the game twice.\n The first time probes will require a small amount of time to travel based on the distance between clicks. \nThe second time probes will travel instantly. \n You will have a short practice trial before each full trial.";
					}
					else {
						instructField.text = "You will play the game twice.\n The first time probes will deploy as fast as you can click \nThe second time probes will have a travel time based on how far apart you clicked. \n You will have a short practice trial before each full trial.";
					}
					addChild(instructField);
					
					stage.addEventListener(MouseEvent.CLICK, instructionsClickHandler);
					break;
				case 5:
					instructField.text = "The Federation recognizes its best!\n Your score across all 3 trials will be tallied and compared to other participants.\n With skill, and a bit of luck YOU could be immortalized on the Leaderboards!";
					addChild(instructField);
					stage.addEventListener(MouseEvent.CLICK, instructionsClickHandler);
					break;
				case 6:
					instructField.text = "Please turn on your computer's sound";
					addChild(instructField);
					stage.addEventListener(MouseEvent.CLICK, instructionsClickHandler);
					break;
				case 7:
					if (clusteringCondition == "1")
					{
						instructField.text = "While you play planets will be distributed in a very clustered pattern. \n\nThe next screen will be an example of how clustered planets look.\n\n";
						//display an example of clustered resources
					}
					else if (clusteringCondition == "3")
					{
						instructField.text = "While you play planets will be distributed in a somewhat clustered pattern. \n\nThe next screen will be an example of how clustered planets look.\n\n";
						//display an example of clustered resources
					}
					else
					{
						instructField.text = "While you play planets will be distributed in a random pattern. \n\nThe next screen will be an example of how random planets may appear. \n\n";
						//display an example of random resources
					}
					addChild(instructField);
					//add child resource
					stage.addEventListener(MouseEvent.CLICK, instructionsClickHandler);
					
					break;
				default:
					break;
			}
		}
		
		//displays instructions about the new condition mid-experiment
		public function displayInstructions2():void
		{
			if (moveTimeCondition == true) {
				instructField.text = "In the next trial the probes will deploy differently.\nThere will be a delay before you can deploy another probe based on the distance between deployments.\nYou will have a short practice trial to see the difference";
			}
			else {
				instructField.text = "In the next trial the probes will deploy differently.\nProbes can be deployed instantly regardless of distance.\nYou will have a short practice trial to see the difference";
			}
			addChild(instructField);
			stage.addEventListener(MouseEvent.CLICK, instructions2Handler);
		}
		
		
		//shows the debriefing
		public function showDebriefing():void
		{
			instructField.text = "Experiment Complete. \n\n Copy and paste the text below into the Turk HIT webpage in order to recieve credit for your work";
			
			var fieldFormat:TextFormat = new TextFormat();
			fieldFormat.size = 24;
			
			var nameField:TextField = new TextField();
			nameField.defaultTextFormat = fieldFormat;
			
			nameField.autoSize = TextFieldAutoSize.CENTER;
			nameField.border = true;
			nameField.background = true;
			nameField.backgroundColor = 0xFFFFFF;
			nameField.borderColor = 0xFFFFFF;
			nameField.selectable = true;
			nameField.y = 275;
			nameField.x = 1280 / 2;
			nameField.text = playerName;
			trace(playerName);
			
			fieldFormat.size = 18;
			var debriefField:TextField = new TextField();
			debriefField.defaultTextFormat = fieldFormat;
			debriefField.autoSize = TextFieldAutoSize.CENTER;
			debriefField.y = 400;
			debriefField.x = (1280 / 2) - 400;
			debriefField.textColor = 0xFFFFFF;
			debriefField.wordWrap = true;
			debriefField.width = 800;
			debriefField.height = 600;
			debriefField.text = "Cognitive Science is the broad interdisciplinary study of the mind. This includes all aspects of cognition from language to perception and action. We are interested in the basic act of foraging for resources in an environment. We believe that there may be a connection between the basic act of foraging for resources in an environment and other higher level cognitive processes, such as memory and visual search. By examining how people forage in a virtual environment we hope to be able to better understand these higher level processes as well."

			addChild(instructField);
			addChild(nameField);
			addChild(debriefField);
		}
		
		public function getInitials():void
		{
			inputField.restrict = "A-z0-9";
			inputField.maxChars = 3;
			inputField.text = "";
			addChild(inputField);
			stage.focus = inputField;
			inputField.addEventListener(KeyboardEvent.KEY_DOWN, initialsListener);
			
			instructField.text = "You got a high score! Enter your initials!";
			addChild(instructField);		
		}
		
		public function displayHighScore( ):void
		{		
			saveData();
			var str:String = "Your score was: " + totalScore + "\n\n\nHigh Scores:\n\n";
			
			instructField.text = str +
					"01. " + hiScoreArray[0].accessInitial + "\t\t" + String(hiScoreArray[0].accessScore) + "\n\n" +
					"02. " + hiScoreArray[1].accessInitial + "\t\t" + String(hiScoreArray[1].accessScore) + "\n\n" + 
					"03. " + hiScoreArray[2].accessInitial + "\t\t" + String(hiScoreArray[2].accessScore) + "\n\n" + 
					"04. " + hiScoreArray[3].accessInitial + "\t\t" + String(hiScoreArray[3].accessScore) + "\n\n" + 
					"05. " + hiScoreArray[4].accessInitial + "\t\t" + String(hiScoreArray[4].accessScore) + "\n\n" + 
					"06. " + hiScoreArray[5].accessInitial + "\t\t" + String(hiScoreArray[5].accessScore) + "\n\n" + 
					"07. " + hiScoreArray[6].accessInitial + "\t\t" + String(hiScoreArray[6].accessScore) + "\n\n" + 
					"08. " + hiScoreArray[7].accessInitial + "\t\t" + String(hiScoreArray[7].accessScore) + "\n\n" + 
					"09. " + hiScoreArray[8].accessInitial + "\t\t" + String(hiScoreArray[8].accessScore) + "\n\n" + 
					"10. " + hiScoreArray[9].accessInitial + "\t\t" + String(hiScoreArray[9].accessScore);
			
			instructField.y = 150;
			
			//text field used to display saving status. Should appear underneath the Hi Scores
			var fieldFormat:TextFormat = new TextFormat();
			fieldFormat.size = 24;
			fieldFormat.color = 0xFFFFFF;
			saveField.defaultTextFormat = fieldFormat;
			saveField.text = "Now Saving Your Data... This May Take a Few Moments.\nPlease Wait..."
			saveField.autoSize = TextFieldAutoSize.CENTER;
			saveField.x = VIEW_XWINDOW / 2;
			saveField.y = VIEW_YWINDOW - 175;
			
			//save field will be edited by the data save handler
			
			addChild(saveField);
			addChild(instructField);
			//going to need an event handler here to move from here to debriefing
			
		}
		
		public function printOut(flavor:String):void
		{			
				var outstr:String = " ";
				outstr = flavor + " " + String(frameNumber) + " " + String(mouseX) + " " + String(mouseY) + " " + String(score) + " " + String(fuel) + "\n"				
				outputArray.push(outstr);		
		}
		
		public function saveData(  ):void
		{
			var outputUrlLoader:URLLoader = new URLLoader();
			var outputVars:URLVariables = new URLVariables();
			var outputurl:String = "savewf.php";
			var outputUrlRequest:URLRequest = new URLRequest(outputurl);
		
			outputVars.outText = new String();
			for (var i:Number = 0; i < outputArray.length; i++) {
				outputVars.outText += outputArray[i];
			}
			trace(outputVars.outText);
			outputVars.filename = "Log" + clusteringCondition + "-" + numStarCondition + "-" + playerName + ".txt";
			
			outputUrlRequest.data = outputVars;
			outputUrlRequest.method = URLRequestMethod.POST;
			outputUrlLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			outputUrlLoader.load(outputUrlRequest);
			outputUrlLoader.addEventListener(Event.COMPLETE, onCompleteHandler);
			outputUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler);			
		}
		
		//saves the hiScore list
		
		//note that the score save has no event handlers
		//we are blindly trusting that if the data saves 
		//the scores will save too.
		public function saveScore( ):void
		{
			var outputUrlLoader:URLLoader = new URLLoader();
			var outputVars:URLVariables = new URLVariables();
			var outputurl:String = "saveScore.php";
			var outputUrlRequest:URLRequest = new URLRequest(outputurl);
			
			outputVars.outText = new String('');
			for (var i:Number = 0; i < hiScoreArray.length; i++) {
				outputVars.outText += hiScoreArray[i].accessInitial + " " + String(hiScoreArray[i].accessScore) + "\n";
				trace(hiScoreArray[i].accessInitial + " " + String(hiScoreArray[i].accessScore) + "\n");
			}
			outputVars.filename = clusteringCondition + "-" + numStarCondition + "-hiScore.txt";
			
			outputUrlRequest.data = outputVars;
			outputUrlRequest.method = URLRequestMethod.POST;
			outputUrlLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			outputUrlLoader.load(outputUrlRequest);
		}
		
		public function selectNumStars():void
		{
			var rand:int = Math.floor(Math.random()*(1+3-1))+1;
			switch (rand) {
				case 1:
					numStarCondition = "0100";
					break;
				case 2:
					numStarCondition = "0600";
					break;
				case 3:
					numStarCondition = "1100";
					break;
			}
		}
		
		public function selectStarDensity():void
		{
			var rand:int = Math.floor(Math.random()*(1+3-1))+1;
			switch (rand) {
				case 1:
					clusteringCondition = "1";
					break;
				case 2:
					clusteringCondition = "3";
					break;
				case 3:
					clusteringCondition = "5";
					break;
			}
		}
		
		public function drawSquare( found:Boolean, mX:Number, mY:Number ):void
		{
			if (found) {				
				// private var squareW = new SquareW();
				var squareY = new SquareY();
				stage.addChild(squareY);
				squareY.x = mX;
				squareY.y = mY;
				squareY.gotoAndPlay(1);
				
				squareY.addEventListener(Event.ENTER_FRAME, squareYeventHandler);
			}
			else {				
				var squareW = new SquareW();
				stage.addChild(squareW);
				squareW.x = mX;
				squareW.y = mY;
				squareW.gotoAndPlay(1);
				
				squareW.addEventListener(Event.ENTER_FRAME, squareWeventHandler);
			}
		}
		
		public function moveTime( ):void
		{
			addChild(circle);
			var timespan = getDistance(circle.x, circle.y, locX, locY) / 30;
			mcX_tween = new Tween(circle,"x", None.easeNone, circle.x, locX, timespan);
			mcY_tween = new Tween(circle,"y", None.easeNone, circle.y, locY, timespan);
			
			mcX_tween.addEventListener(TweenEvent.MOTION_FINISH, tweenFinishHandler);
		}
		
	}
}