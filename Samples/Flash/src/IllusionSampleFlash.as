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
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.media.Camera;
	import flash.media.Video;
	
	import nummist.illusion.graphics.lights.LightingUtils;
	import nummist.illusion.graphics.materials.DisplayObjectMaterial;
	import nummist.illusion.graphics.models.ExternalModelPrefab;
	import nummist.illusion.graphics.models.ExternalModelPrefabLoader;
	import nummist.illusion.graphics.models.IExternalModelPrefabLoaderDelegate;
	import nummist.illusion.mixedreality.ARViewport;
	import nummist.illusion.mixedreality.AbstractTracker;
	import nummist.illusion.mixedreality.ITrackerDelegate;
	import nummist.illusion.mixedreality.MarkerPool;
	import nummist.illusion.mixedreality.PixelFeed;
	import nummist.illusion.mixedreality.flare.FlareBarcodeFeatureSet;
	import nummist.illusion.mixedreality.flare.FlareBarcodeTracker;
	import nummist.illusion.mixedreality.flare.FlareNaturalFeatureTracker;
	import nummist.illusion.mixedreality.flare.IFlareDataMatrixDelegate;
	import nummist.illusion.mixedreality.flare.IFlareVirtualButtonDelegate;
	
	
	[SWF(width='640', height='480', frameRate='60')]
	public class IllusionSampleFlash
	extends
		Sprite
	implements
		IExternalModelPrefabLoaderDelegate,
		ITrackerDelegate,
		IFlareDataMatrixDelegate,
		IFlareVirtualButtonDelegate
	{
		private var stage3D_:Stage3D;
		private var pixelFeed_:PixelFeed;
		private var arViewport_:ARViewport;
		private var flareBarcodeTracker_:FlareBarcodeTracker;
		private var flareNaturalFeatureTracker_:FlareNaturalFeatureTracker;
		private var applePrefab_:ExternalModelPrefab;
		private var chalicePrefab_:ExternalModelPrefab;
		
		
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
			
			// Get the 3D stage.
			stage3D_ = stage.stage3Ds[0];
			
			// Create and configure the video camera.
			var videoCamera:Camera = Camera.getCamera();
			videoCamera.setMode(640, 480, 60); // 640x480 @ 60 FPS
			
			// Create and configure the video.
			var video:Video = new Video(videoCamera.width, videoCamera.height);
			video.attachCamera(videoCamera);
			
			// Create the pixel feed that draws data from the video.
			pixelFeed_ = new PixelFeed(video);
			
			// Create and configure the AR viewport.
			arViewport_ = new ARViewport(stage3D_, pixelFeed_);
			arViewport_.showProfilingDiagram = true;
			arViewport_.mirrored = true;
			
			// Add the AR viewport to the 2D scene.
			addChild(arViewport_);
			
			// Get the 3D scene from the AR viewport.
			var scene3D:Object3D = arViewport_.scene3D;
			
			// Add lights to the 3D scene.
			scene3D.addChild(LightingUtils.newThreePointLighting());
			
			// Listen for and request the 3D stage's graphics context.
			stage3D_.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
			stage3D_.requestContext3D();
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
			//flareBarcodeFeatureSet.numDataMatrices = 2;
			
			// Create the barcode tracker.
			flareBarcodeTracker_ = new FlareBarcodeTracker(this, pixelFeed_, arViewport_.scene3D, flareBarcodeFeatureSet);
			
			// Create the natural feature tracker.
			flareNaturalFeatureTracker_ = new FlareNaturalFeatureTracker(this, pixelFeed_, arViewport_.scene3D);
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
				if (i % 2 == 0)
				{
					markerPools[i].markers.push(applePrefab_.newObject3D());
				}
				else
				{
					markerPools[i].markers.push(chalicePrefab_.newObject3D());
				}
			}
			
			if (tracker == flareNaturalFeatureTracker_)
			{
				// Set up virtual buttons.
				flareNaturalFeatureTracker_.addVirtualButton(0, 420,  70, 460, 110); // Vienna on the Austria map
				flareNaturalFeatureTracker_.addVirtualButton(2, 110, 150, 150, 190); // left face of the Graz clock tower
				flareNaturalFeatureTracker_.addVirtualButton(2, 165, 140, 210, 200); // right face of the Graz clock tower
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
			alert("The data matrix says:\n" + message);
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
			
			if (markerID == 0)
			{
				alert("You hid Vienna on the map of Austria.");
			}
			else // markerID == 2
			{
				if (buttonID == 0)
				{
					alert("You hid the left face of the Graz clock tower.");
				}
				else // buttonID == 1
				{
					alert("You hid the right face of the Graz clock tower.");
				}
			}
		}
		
		
		private static function alert(message:String):void
		{
			ExternalInterface.call("alert", message);
		}
	}
}