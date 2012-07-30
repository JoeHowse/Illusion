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
	import alternativa.engine3d.lights.DirectionalLight;
	import alternativa.engine3d.objects.Mesh;
	
	import com.sociodox.theminer.*;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.Camera;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import flashx.textLayout.formats.TextAlign;
	
	import nummist.illusion.graphics.SceneUtils;
	import nummist.illusion.graphics.materials.DisplayObjectMaterial;
	import nummist.illusion.graphics.models.ExternalModelPrefab;
	import nummist.illusion.graphics.models.ExternalModelPrefabLoader;
	import nummist.illusion.graphics.models.IExternalModelPrefabLoaderDelegate;
	import nummist.illusion.logic.CameraSeesActivity;
	import nummist.illusion.mixedreality.ARViewportUsingStage;
	import nummist.illusion.mixedreality.ARViewportUsingStageVideo;
	import nummist.illusion.mixedreality.AbstractARViewport;
	import nummist.illusion.mixedreality.AbstractPixelFeed;
	import nummist.illusion.mixedreality.AbstractTracker;
	import nummist.illusion.mixedreality.ITrackerDelegate;
	import nummist.illusion.mixedreality.MarkerEvent;
	import nummist.illusion.mixedreality.MarkerPool;
	import nummist.illusion.mixedreality.PixelFeedFromCamera;
	import nummist.illusion.mixedreality.PixelFeedFromDisplayObject;
	import nummist.illusion.mixedreality.flare.FlareBarcodeFeatureSet;
	import nummist.illusion.mixedreality.flare.FlareBarcodeTracker;
	import nummist.illusion.mixedreality.flare.FlareNaturalFeatureTracker;
	import nummist.illusion.mixedreality.flare.IFlareDataMatrixDelegate;
	import nummist.illusion.mixedreality.flare.IFlareVirtualButtonDelegate;
	
	
	[SWF(width='640', height='480', frameRate='30')]
	public class IllusionSampleFlash
	extends
		Sprite
	implements
		IExternalModelPrefabLoaderDelegate,
		ITrackerDelegate,
		IFlareDataMatrixDelegate,
		IFlareVirtualButtonDelegate
	{
		private const PROFILE_WITH_THE_MINER:Boolean = false;
		private const ACCELERATE_WITH_STAGE_VIDEO:Boolean = true;
		
		private var stage3D_:Stage3D;
		private var pixelFeed_:AbstractPixelFeed;
		private var arViewport_:AbstractARViewport;
		private var flareBarcodeTracker_:FlareBarcodeTracker;
		private var flareNaturalFeatureTracker_:FlareNaturalFeatureTracker;
		private var applePrefab_:ExternalModelPrefab;
		private var chalicePrefab_:ExternalModelPrefab;
		private var rotatingMarkers_:Vector.<Object3D> = new Vector.<Object3D>();
		private var lastMilliseconds_:int;
		
		
		public function IllusionSampleFlash()
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
			
			// Create the video camera.
			var videoCamera:Camera = Camera.getCamera();
			
			if (!videoCamera)
			{
				// There is no video camera available.
				
				// Display an error message.
				
				var textFormat:TextFormat = new TextFormat();
				textFormat.align = TextAlign.JUSTIFY;
				textFormat.font = "Comic Sans";
				textFormat.size = 16;
				textFormat.color = 0xcc0000;
				
				var textField:TextField = new TextField();
				textField.width = 320;
				textField.wordWrap = true;
				textField.borderColor = 0xcc0000;
				textField.text =
					"No webcam found. Plug in a webcam, close other webcam " +
					"apps such as Skype, and then refresh this page.";
				textField.setTextFormat(textFormat);
				textField.x = 320 - 0.5 * textField.textWidth;
				textField.y = 240 - 0.5 * textField.textHeight;
				
				addChild(textField);
				
				// Do not set up anything else.
				return;
			}
			
			// Get the 3D stage.
			stage3D_ = stage.stage3Ds[0];
			
			// Configure the video camera.
			videoCamera.setMode(640, 480, 30); // 640x480 @ 30 FPS
			videoCamera.setQuality(0, 100); // uncompressed (less CPU usage)
			
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
			
			if (ACCELERATE_WITH_STAGE_VIDEO && stage.stageVideos.length > 0)
			{
				var stageVideo:StageVideo = stage.stageVideos[0];
				
				// Create the pixel feed that draws data from the camera.
				pixelFeed_ = new PixelFeedFromCamera(videoCamera);
				
				// Create the AR viewport.
				arViewport_ = new ARViewportUsingStageVideo
				(
					stageVideo,
					stage3D_,
					pixelFeed_ as PixelFeedFromCamera
				);
			}
			else
			{
				// Create and configure the video.
				var video:Video = new Video(videoCamera.width, videoCamera.height);
				video.attachCamera(videoCamera);
				video.opaqueBackground = 0x000000; // no transparency
				video.deblocking = 1; // no deblocking filter (less CPU usage)
				video.smoothing = false;
				
				// Create the pixel feed that draws data from the video.
				pixelFeed_ = new PixelFeedFromDisplayObject(video);
				
				// Create and configure the AR viewport.
				arViewport_ = new ARViewportUsingStage
				(
					stage3D_,
					pixelFeed_ as PixelFeedFromDisplayObject
				);
				(arViewport_ as ARViewportUsingStage).mirrored = true;
			}
			
			// Add the AR viewport to the 2D scene.
			addChild(arViewport_);
			
			// Get the 3D scene from the AR viewport.
			var scene3D:Object3D = arViewport_.scene3D;
			
			// Add lights to the 3D scene.
			scene3D.addChild(SceneUtils.newThreePointLighting());
			
			// Listen for and request the 3D stage's graphics context.
			stage3D_.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D_.requestContext3D();
			
			// Listen for keystrokes.
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onContextCreate(event:Event):void
		{
			stage3D_.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			
			// Create the model loader.
			var externalModelPrefabLoader:ExternalModelPrefabLoader =
				new ExternalModelPrefabLoader(this, "data");
			
			// Load the models.
			externalModelPrefabLoader.loadExternalModelPrefabs
			(
				"apple.3ds",
				"chalice.3ds"
			);
			
			// Listen for frame updates.
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			// Initialize the time.
			lastMilliseconds_ = getTimer();
		}
		
		
		public function onLoadExternalModelPrefabError
		(
			loader:ExternalModelPrefabLoader,
			filename:String,
			errorEventType:String
		)
		:void
		{
			throw new Error
			(
				"Failed to load \"" + loader.basePath + filename + "\": " +
				errorEventType
			);
		}
		
		public function onLoadExternalModelPrefabComplete
		(
			loader:ExternalModelPrefabLoader,
			filename:String,
			externalModelPrefab:ExternalModelPrefab
		)
		:void
		{
			if (filename == "apple.3ds")
			{
				// Store the apple model.
				applePrefab_ = externalModelPrefab;
				
				// Set the apple model's scale.
				applePrefab_.scale = 2.5;
				
				// Load the resources for the apple model.
				applePrefab_.loadResources(stage3D_.context3D);
			}
			else // filename == "chalice.3ds"
			{
				// Store the chalice model.
				chalicePrefab_ = externalModelPrefab;
				
				// Set the chalice model's scale.
				chalicePrefab_.scale = 1000;
				
				// Load the resources for the chalice model.
				chalicePrefab_.loadResources(stage3D_.context3D);
			}
			
			if (loader.numLoadsPending > 0)
			{
				// The other model is still loading.
				
				// Wait for the other model to load.
				return;
			}
			
			// Both models have loaded.
			
			// Create and configure the barcode tracker's feature set.
			var flareBarcodeFeatureSet:FlareBarcodeFeatureSet = new FlareBarcodeFeatureSet();
			flareBarcodeFeatureSet.numSimpleIDs = 2;
			flareBarcodeFeatureSet.numBCHs = 2;
			flareBarcodeFeatureSet.numFrames = 2;
			// TODO: Template and data matrix markers.
			
			// Create the barcode tracker.
			flareBarcodeTracker_ = new FlareBarcodeTracker(this, pixelFeed_, stage, arViewport_.scene3D, flareBarcodeFeatureSet);
			
			// Create the natural feature tracker.
			flareNaturalFeatureTracker_ = new FlareNaturalFeatureTracker(this, pixelFeed_, stage, arViewport_.scene3D);
		}
		
		public function onTrackerStarted
		(
			tracker:AbstractTracker,
			markerPools:Vector.<MarkerPool>
		)
		:void
		{
			// Add either an apple or a chalice to each marker pool.
			for (var i:uint = 0; i < markerPools.length; i++)
			{
				var marker:Object3D;
				if (i % 2 == 0)
				{
					marker = applePrefab_.newObject3D();
				}
				else
				{
					marker = chalicePrefab_.newObject3D();
				}
				marker.addEventListener(MarkerEvent.LOST, onMarkerLost);
				markerPools[i].markers.push(marker);
			}
			
			if (tracker == flareNaturalFeatureTracker_)
			{
				// Set up a 48x48 pixel virtual button in the center of each
				// physical marker.
				
				// The Austria physical marker is 480x256.
				flareNaturalFeatureTracker_.addVirtualButton(0, 216, 104, 264, 152, 0.7, 0.8, 0.25);
				
				// The Vienna physical marker is 480x288.
				flareNaturalFeatureTracker_.addVirtualButton(1, 216, 120, 264, 168, 0.7, 0.8, 0.25);
				
				// The Graz physical marker is 336x480.
				flareNaturalFeatureTracker_.addVirtualButton(2, 144, 216, 192, 264, 0.7, 0.8, 0.25);
			}
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
		
		public function onDataMatrixMessage
		(
			tracker:FlareBarcodeTracker,
			markerID:uint,
			message:String
		)
		:void
		{
			// TODO
		}
		
		public function onVirtualButtonEvent
		(
			tracker:FlareNaturalFeatureTracker,
			markerID:uint,
			buttonID:uint,
			press:Boolean
		)
		:void
		{
			if (!press)
			{
				// The virtual button was released.
				
				// Do nothing.
				return;
			}
			
			// The virtual button was pressed.
			
			// Get the marker corresponding to the virtual button.
			var marker:Object3D = tracker.markerPools[markerID].markers[0];
			
			var i:int = rotatingMarkers_.indexOf(marker);
			if (i == -1)
			{
				// The marker was not rotating.
				
				// Start rotating the marker.
				rotatingMarkers_.push(marker);
			}
			else
			{
				// The marker was rotating.
				
				// Stop rotating the marker.
				rotatingMarkers_.splice(i, 1);
			}
		}
		
		
		private function onMarkerLost(event:MarkerEvent):void
		{
			var marker:Object3D = event.target as Object3D;
			
			var i:int = rotatingMarkers_.indexOf(marker);
			if (i != -1)
			{
				// The marker was rotating.
				
				// Stop rotating the marker.
				rotatingMarkers_.splice(i, 1);
			}
		}
		
		private function onEnterFrame(event:Event):void
		{
			// Update the time.
			var milliseconds:int = getTimer();
			var deltaMilliseconds:int = milliseconds - lastMilliseconds_;
			lastMilliseconds_ = milliseconds;
			
			for each (var marker:Object3D in rotatingMarkers_)
			{
				// Rotate the marker at 45 degrees per second.
				marker.getChildAt(0).rotationZ += deltaMilliseconds * 0.00025 * Math.PI;
			}
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			if (event.keyCode == 32) // spacebar
			{
				// Show or hide the Alternativa3D profiling diagram.
				arViewport_.showProfilingDiagram = !arViewport_.showProfilingDiagram;
			}
		}
	}
}