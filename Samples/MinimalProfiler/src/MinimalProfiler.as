/*

Copyright (c) 2012 Joseph Howse

This software is provided 'as-is', without any express or implied warranty. In
no event will the author be held liable for any damages arising from the use
of this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim
that you wrote the original software. If you use this software in a product,
an acknowledgment in the product documentation would be appreciated but is
not required.
2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

Joseph Howse
josephhowse@nummist.com

*/


package
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.GeoSphere;
	
	import com.sociodox.theminer.*;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
	import nummist.illusion.mixedreality.arviewports.ARViewportUsingStage;
	import nummist.illusion.mixedreality.pixelfeeds.PixelFeedFromDisplayObject;
	import nummist.illusion.mixedreality.trackers.AbstractTracker;
	import nummist.illusion.mixedreality.trackers.DebugTracker;
	import nummist.illusion.mixedreality.trackers.ITrackerDelegate;
	import nummist.illusion.mixedreality.trackers.MarkerEvent;
	import nummist.illusion.mixedreality.trackers.MarkerPool;
	
	
	[SWF(width='640', height='480', frameRate='120')]
	public class MinimalProfiler extends Sprite implements ITrackerDelegate
	{
		private const PROFILE_WITH_THE_MINER:Boolean = true;
		private const ARTIFICIALLY_INDUCE_LAG:Boolean = false;
		
		
		private var stageFrameRate_:Number;
		private var background_:Shape;
		private var stage3D_:Stage3D;
		private var pixelFeed_:PixelFeedFromDisplayObject;
		private var arViewport_:ARViewportUsingStage;
		private var tracker_:DebugTracker;
		private var lastMilliseconds_:int;
		
		
		public function MinimalProfiler()
		{
			if (stage)
			{
				onAddedToStage();
			}
			else
			{
				// Listen for being added to the 2D stage.
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}
		
		
		private function onAddedToStage(event:Event = null):void
		{
			if (hasEventListener(Event.ADDED_TO_STAGE))
			{
				removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
			
			// Configure the 2D stage.
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Store the 2D stage's frame rate for use in pausing/unpausing.
			stageFrameRate_ = stage.frameRate;
			
			// Get the 3D stage.
			stage3D_ = stage.stage3Ds[0];
			
			if (PROFILE_WITH_THE_MINER && Capabilities.isDebugger)
			{
				// Integrate TheMiner profiling tools.
				addChild(new TheMiner());
			}
			else
			{
				// Disable the propagation of mouse events, which are unused.
				stage.mouseChildren = false;
			}
			
			// Create the background and fill it with a color that the debug
			// tracker will interpret as xyz coordinates: (0, 64, 127).
			background_ = new Shape();
			background_.graphics.beginFill(0x80c0ff);
			background_.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			background_.graphics.endFill();
			
			// Create the pixel feed that draws data from the shape.
			pixelFeed_ = new PixelFeedFromDisplayObject
			(
				background_, // source
				1.2566370614359172, // fov: 72 degrees
				1, // width
				1 // height
			);
			
			// Create the AR viewport.
			arViewport_ = new ARViewportUsingStage(stage3D_, pixelFeed_);
			
			// Add the AR viewport to the 2D scene.
			addChild(arViewport_);
			
			// Listen for and request the 3D stage's graphics context.
			stage3D_.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D_.requestContext3D();
			
			// Listen for keystrokes.
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onContextCreate(event:Event):void
		{
			stage3D_.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			
			// Create the tracker.
			tracker_ = new DebugTracker(this, pixelFeed_, stage, arViewport_.scene3D);
			
			// Listen for frame updates.
			if (ARTIFICIALLY_INDUCE_LAG)
			{
				addEventListener(Event.EXIT_FRAME, raiseMarker);
			}
			else
			{
				addEventListener(Event.ENTER_FRAME, raiseMarker);
			}
			
			// Initialize the time.
			lastMilliseconds_ = getTimer();
		}
		
		
		public function onTrackerStarted
		(
			tracker:AbstractTracker,
			markerPools:Vector.<MarkerPool>
		)
		:void
		{
			// Create the marker.
			var marker:GeoSphere = new GeoSphere
			(
				25, // radius
				2, // segments
				false, // reverse
				new FillMaterial(0xffff80) // material
			);
			
			// Upload the marker's resources to the 3D context.
			for each (var resource:Resource in marker.getResources())
			{
				resource.upload(stage3D_.context3D);
			}
			
			markerPools[0].markers.push(marker);
		}
		
		public function onMarkerPoolHasExcessDemand
		(
			tracker:AbstractTracker,
			markerPoolIndex:uint,
			markerPool:MarkerPool
		)
		:void
		{
			// Do nothing, such that the supply of markers is inelastic.
		}
		
		
		private function raiseMarker(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, raiseMarker);
			
			// Update the time.
			var milliseconds:int = getTimer();
			var deltaMilliseconds:int = milliseconds - lastMilliseconds_;
			lastMilliseconds_ = milliseconds;
			
			// Fill the background with a color that the debug tracker will
			// interpret as xyz coordinates: (0, 0, 127).
			background_.graphics.beginFill(0x8080ff);
			background_.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			background_.graphics.endFill();
			
			// Pause the 2D stage.
			stage.frameRate = 0.0001;
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == 32) // spacebar
			{
				// Show or hide the Alternativa3D profiling diagram.
				arViewport_.showProfilingDiagram = !arViewport_.showProfilingDiagram;
			}
			else if (event.keyCode == 80) // 'p'
			{
				// Unpause/repause the 2D stage.
				if (stage.frameRate == stageFrameRate_)
				{
					stage.frameRate = 0.0001;
				}
				else
				{
					stage.frameRate = stageFrameRate_;
				}
			}
		}
	}
}