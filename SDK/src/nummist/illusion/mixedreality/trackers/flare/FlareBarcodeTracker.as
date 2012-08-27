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


package nummist.illusion.mixedreality.trackers.flare
{
	import alternativa.engine3d.core.Object3D;
	
	import cmodule.libFlareTracker.CLibInit;
	
	import flash.display.Stage;
	import flash.utils.ByteArray;
	
	import nummist.illusion.core.ILoaderDelegate;
	import nummist.illusion.core.Loader;
	import nummist.illusion.core.Logger;
	import nummist.illusion.core.StringUtils;
	import nummist.illusion.mixedreality.sensors.AbstractVisualSensor;
	import nummist.illusion.mixedreality.trackers.AbstractTracker;
	import nummist.illusion.mixedreality.trackers.ITrackerDelegate;
	import nummist.illusion.mixedreality.trackers.MarkerEvent;
	import nummist.illusion.mixedreality.trackers.MarkerPool;
	import nummist.illusion.mixedreality.trackers.MarkerPoolIterator;
	
	
	/**
	 * An AbstractTracker subclass that wraps flare&#42;tracker, the barcode
	 * tracker from Imagination Computer Services GmbH.
	 * <br /><br />
	 * To avoid memory leaks, invoke the <code>stop()</code> method once this
	 * object is no longer in use.
	 * 
	 * @see AbstractTracker
	 * @see FlareBarcodeFeatureSet
	 * @see IFlareDataMatrixDelegate
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8FGEUKnjEeG8rNJMqBg6NQ
	 */
	public class FlareBarcodeTracker extends AbstractTracker
		implements ILoaderDelegate
	{
		private static const MARKER_UNDEFINED:int  = 0;
		private static const MARKER_SIMPLE_ID:int = 1;
		private static const MARKER_BCH:int = 2;
		private static const MARKER_TEMPLATE:int = 3;
		private static const MARKER_FRAME:int = 4;
		private static const MARKER_DATA_MATRIX:int = 6;
		
		
		private var dataMatrixDelegate_:IFlareDataMatrixDelegate;
		private var featureSet_:FlareBarcodeFeatureSet;
		private var dataPath_:String;
		private var licenseFilename_:String;
		
		private var loader_:Loader;
		private var cLibInit_:CLibInit;
		private var nativeTracker_:*;
		private var nativeBuffer_:ByteArray;
		private var nativeImagePointer_:uint;
		
		private var simpleIDMarkerPoolsStart_:int = -1;
		private var simpleIDMarkerPoolsEnd_:int = -1;
		private var bchMarkerPoolsStart_:int = -1;
		private var bchMarkerPoolsEnd_:int = -1;
		private var templateMarkerPoolsStart_:int = -1;
		private var templateMarkerPoolsEnd_:int = -1;
		private var frameMarkerPoolsStart_:int = -1;
		private var frameMarkerPoolsEnd_:int = -1;
		private var dataMatrixMarkerPoolsStart_:int = -1;
		private var dataMatrixMarkerPoolsEnd_:int = -1;
		
		
		/**
		 * Creates a FlareBarcodeTracker object.
		 * 
		 * @param delegate A delegate that is provided the opportunity to
		 * populate the MarkerPool objects when they are created and when they
		 * are asked for more markers than they have. Additionally, if the
		 * delegate implements the IFlareDataMatrixDelegate interface, it is
		 * provided the opportunity to handle the message decoded from any
		 * data matrix barcode when the barcode is newly found.
		 * 
		 * @param sensor The supplier of pixel data and projection data.
		 * 
		 * @param stage The stage.
		 * 
		 * @param scene3D The 3D node wherein markers are placed.
		 * 
		 * @param featureSet The set of barcode feature definitions.
		 * 
		 * @param autoStart A value of <code>true</code> means this object will
		 * <code>start()</code> immediately.
		 * 
		 * @param dataPath The path to the folder containing the
		 * flare&#42;tracker license and image files for any template markers.
		 * If this argument is omitted or <code>null</code>, it defaults to
		 * <code>"data/"</code>.
		 * 
		 * @param licenseFilename The path to the flare&#42;nft license file,
		 * relative to dataPath. If this argument is omitted or
		 * <code>null</code>, it defaults to <code>"flareTracker.lic"</code>.
		 * 
		 * @throws ArgumentError if <code>delegate</code>, <code>sensor</code>,
		 * <code>scene3D</code>, or <code>featureSet</code> is
		 * <code>null</code>.
		 * 
		 * @flowerModelElementId _8FbbgKnjEeG8rNJMqBg6NQ
		 */
		public function FlareBarcodeTracker
		(
			delegate:ITrackerDelegate,
			sensor:AbstractVisualSensor,
			stage:Stage,
			scene3D:Object3D,
			featureSet:FlareBarcodeFeatureSet,
			autoStart:Boolean=true,
			dataPath:String="data/",
			licenseFilename:String="flareTracker.lic"
		)
		{
			dataMatrixDelegate_ = delegate as IFlareDataMatrixDelegate;
			featureSet_ = featureSet;
			dataPath_ = (dataPath ? dataPath : "data/");
			licenseFilename_ = (licenseFilename ? licenseFilename : "flareTracker.lic");
			
			if (featureSet_)
			{
				super(delegate, sensor, stage, scene3D, autoStart);
			}
			else
			{
				throw new ArgumentError("featureSet must be non-null");
			}
		}
		
		
		/**
		 * The index of the first MarkerPool object that corresponds to a
		 * simple ID barcode. If there is no such MarkerPool object, the value
		 * is -1 instead.
		 */
		public function get simpleIDMarkerPoolsStart():int
		{
			return simpleIDMarkerPoolsStart_;
		}
		
		/**
		 * One more than the index of the last MarkerPool object that
		 * corresponds to a simple ID barcode. If there is no such MarkerPool
		 * object, the value is -1 instead.
		 */
		public function get simpleIDMarkerPoolsEnd():int
		{
			return simpleIDMarkerPoolsEnd_;
		}
		
		/**
		 * The index of the first MarkerPool object that corresponds to a BCH
		 * barcode. If there is no such MarkerPool object, the value is -1
		 * instead.
		 */
		public function get bchMarkerPoolsStart():int
		{
			return bchMarkerPoolsStart_;
		}
		
		/**
		 * One more than the index of the last MarkerPool object that
		 * corresponds to a BCH barcode. If there is no such MarkerPool object,
		 * the value is -1 instead.
		 */
		public function get bchMarkerPoolsEnd():int
		{
			return bchMarkerPoolsEnd_;
		}
		
		/**
		 * The index of the first MarkerPool object that corresponds to a
		 * template barcode. If there is no such MarkerPool object, the value
		 * is -1 instead.
		 */
		public function get templateMarkerPoolsStart():int
		{
			return templateMarkerPoolsStart_;
		}
		
		/**
		 * One more than the index of the last MarkerPool object that
		 * corresponds to a tracker barcode. If there is no such MarkerPool
		 * object, the value is -1 instead.
		 */
		public function get templateMarkerPoolsEnd():int
		{
			return templateMarkerPoolsEnd_;
		}
		
		/**
		 * The index of the first MarkerPool object that corresponds to a frame
		 * barcode. If there is no such MarkerPool object, the value is -1
		 * instead.
		 */
		public function get frameMarkerPoolsStart():int
		{
			return frameMarkerPoolsStart_;
		}
		
		/**
		 * One more than the index of the last MarkerPool object that
		 * corresponds to a frame barcode. If there is no such MarkerPool
		 * object, the value is -1 instead.
		 */
		public function get frameMarkerPoolsEnd():int
		{
			return frameMarkerPoolsEnd_;
		}
		
		/**
		 * The index of the first MarkerPool object that corresponds to a data
		 * matrix barcode. If there is no such MarkerPool object, the value is
		 * -1 instead.
		 */
		public function get dataMatrixMarkerPoolsStart():int
		{
			return dataMatrixMarkerPoolsStart_;
		}
		
		/**
		 * One more than the index of the last MarkerPool object that
		 * corresponds to a data matrix barcode. If there is no such MarkerPool
		 * object, the value is -1 instead.
		 */
		public function get dataMatrixMarkerPoolsEnd():int
		{
			return dataMatrixMarkerPoolsEnd_;
		}
		
		
		override public function start():void
		{
			super.start();
			
			cLibInit_ = new CLibInit();
			
			loader_ = new Loader
			(
				this,
				StringUtils.absolutePath(dataPath_, stage_)
			);
			loader_.loadBinary(licenseFilename_);
		}
		
		override public function stop():void
		{
			super.stop();
			
			if (loader_)
			{
				// Cancel the remaining load tasks.
				loader_.close();
				
				// Release the loader.
				loader_ = null;
			}
			
			// Release the native resources.
			cLibInit_ = null;
			nativeTracker_ = null;
			nativeBuffer_ = null;
			nativeImagePointer_ = 0;
			
			// Release the marker pools.
			markerPools.fixed = false;
			markerPools.splice(0, markerPools.length);
			markerPools.fixed = true;
		}
		
		
		override protected function updateTrackedMarkers
		(
			markerPoolIterators:Vector.<MarkerPoolIterator>,
			data:ByteArray
		)
		:void
		{
			// Wait until flare*tracker is fully initialized.
			if (!nativeBuffer_)
			{
				return;
			}
			
			// Write the pixels to the native buffer.
			nativeBuffer_.position = nativeImagePointer_;
			nativeBuffer_.writeBytes(data);	
			
			// Update the native tracker and get the number of markers found.
			var numMarkersTracked:uint = nativeTracker_.update();
			
			// Move the native buffer's pointer to the tracker results.
			nativeBuffer_.position = nativeTracker_.getTrackerResultPtr();
			
			// Iterate over all tracked markers.
			for (var i:uint = 0; i < numMarkersTracked; i++)
			{
				// Read the marker's type.
				var markerType:int = nativeBuffer_.readInt();
				
				// Read the marker's ID.
				var markerID:int = nativeBuffer_.readInt();
				
				// Adjust the ID to align it with the marker pool index.
				if (markerType == MARKER_SIMPLE_ID)
				{
					markerID += simpleIDMarkerPoolsStart_;
				}
				else if (markerType == MARKER_BCH)
				{
					markerID += bchMarkerPoolsStart_;
				}
				else if (markerType == MARKER_TEMPLATE)
				{
					markerID += templateMarkerPoolsStart_;
				}
				else if (markerType == MARKER_FRAME)
				{
					markerID += frameMarkerPoolsStart_;
				}
				else if (markerType == MARKER_DATA_MATRIX)
				{
					markerID += dataMatrixMarkerPoolsStart_;
				}
				else
				{
					// The marker type is unknown.
					
					// Continue to the next marker.
					continue;
				}
				
				// Try to get the marker from the pool.
				var marker:Object3D = markerPoolIterators[markerID].nextMarker();
				
				if (!marker)
				{
					// No marker is available in the pool.
					
					// Notify the delegate that the marker pool has excess
					// demand.
					delegate_.onMarkerPoolHasExcessDemand(this, markerID, markerPools[markerID]);
					
					// Continue to the next tracking result.
					// It might draw from another pool.
					continue;
				}
				
				// Update the marker's matrix.
				marker.matrix = FlareUtils.matrix(nativeBuffer_);
				
				if (marker.parent != scene3D_)
				{
					// The marker is newly found.
					
					// Add the marker to the 3D scene.
					scene3D_.addChild(marker);
					
					// Notify the marker that it has been found.
					marker.dispatchEvent(new MarkerEvent
					(
						MarkerEvent.FOUND,
						markerPoolIterators[markerID].markerPool
					));
					
					if
					(
						markerType == MARKER_DATA_MATRIX &&
						dataMatrixDelegate_
					)
					{
						// Dispatch the data matrix's message to the delegate.
						dataMatrixDelegate_.onDataMatrixMessage
						(
							this,
							markerID,
							nativeTracker_.getDataMatrixMessage(i)
						);
					}
				}
			}
		}
		
		
		/**
		 * Part of the ILoaderDelegate implementation.
		 * <br /><br />
		 * Do not invoke this method; it is intended for use by an internal
		 * Loader object only.
		 * 
		 * @throws Error always.
		 */
		public function onLoadError(loader:Loader, filename:String, errorEventType:String):void
		{
			// Release the native tracker and related resources.
			stop();
			
			throw new Error
			(
				"failed to load \"" + loader.basePath + filename + "\": " +
				errorEventType
			);
		}
		
		/**
		 * Part of the ILoaderDelegate implementation.
		 * <br /><br />
		 * Do not invoke this method; it is intended for use by an internal
		 * Loader object only.
		 * 
		 * @throws Error if flare*tracker finds an invalid license or fails to
		 * initialize.
		 */
		public function onLoadComplete(loader:Loader, filename:String, data:*):void
		{
			if (filename == licenseFilename_)
			{
				cLibInit_.supplyFile("flareTracker.lic", data);
				
				var visualSensor:AbstractVisualSensor =
					sensor_ as AbstractVisualSensor;
				
				// Generate the camera configuration and supply it to the
				// native tracker.
				cLibInit_.supplyFile
				(
					"data/cam.ini",
					FlareUtils.rawCamConfig(visualSensor)
				);
				
				nativeTracker_ = cLibInit_.init();
				nativeTracker_.setLogger(this, log, 5);
				
				// Initialize the native tracker.
				if (!nativeTracker_.initTracker
				(
					stage_,
					visualSensor.width,
					visualSensor.height,
					"data/cam.ini"
				))
				{
					stop();
					throw new Error("flare*tracker failed to initialize");
				}
				
				// Get the native buffer.
				var namespace:Namespace = new Namespace("cmodule.libFlareTracker");
				nativeBuffer_ = (namespace::gstate).ds; // accessible despite compiler warning
				
				// Get the offset to the image buffer.
				nativeImagePointer_ = nativeTracker_.getImageBufferPtr();
				
				// Determine how marker pool indices correspond to marker
				// types, and tell the native tracker to look for each marker
				// type that is in use.
				
				var markerPoolsEnd:uint = 0;
				
				if (featureSet_.numSimpleIDs > 0)
				{
					simpleIDMarkerPoolsStart_ = markerPoolsEnd;
					markerPoolsEnd += featureSet_.numSimpleIDs;
					simpleIDMarkerPoolsEnd_ = markerPoolsEnd;
					
					nativeTracker_.addMarkerDetector
					(
						MARKER_SIMPLE_ID,
						featureSet_.simpleIDBorderRatio,
						featureSet_.simpleIDMillimeters
					);
				}
				
				if (featureSet_.numBCHs > 0)
				{
					bchMarkerPoolsStart_ = markerPoolsEnd;
					markerPoolsEnd += featureSet_.numBCHs;
					bchMarkerPoolsEnd_ = markerPoolsEnd;
					
					nativeTracker_.addMarkerDetector
					(
						MARKER_BCH,
						featureSet_.bchBorderRatio,
						featureSet_.bchMillimeters
					);
				}
				
				if (featureSet_.templateFilenames.length > 0)
				{
					templateMarkerPoolsStart_ = markerPoolsEnd;
					markerPoolsEnd += featureSet_.templateFilenames.length;
					templateMarkerPoolsEnd_ = markerPoolsEnd;
					
					nativeTracker_.addMarkerDetector
					(
						MARKER_TEMPLATE,
						featureSet_.templateBorderRatio,
						featureSet_.templatePatternSize
					);
				}
				
				if (featureSet_.numFrames > 0)
				{
					frameMarkerPoolsStart_ = markerPoolsEnd;
					markerPoolsEnd += featureSet_.numFrames;
					frameMarkerPoolsEnd_ = markerPoolsEnd;
					
					nativeTracker_.addMarkerDetector
					(
						MARKER_FRAME,
						featureSet_.frameBorderRatio,
						featureSet_.frameMillimeters
					);
				}
				
				if (featureSet_.numDataMatrices > 0)
				{
					dataMatrixMarkerPoolsStart_ = markerPoolsEnd;
					markerPoolsEnd += featureSet_.numDataMatrices;
					dataMatrixMarkerPoolsEnd_ = markerPoolsEnd;
					
					nativeTracker_.addMarkerDetector
					(
						MARKER_DATA_MATRIX,
						featureSet_.dataMatrixBorderRatio,
						0 // unused
					);
				}
				
				// Unfix the number of marker pools.
				markerPools.fixed = false;
				
				// Create the marker pools.
				for (var i:uint = 0; i < markerPoolsEnd; i++)
				{
					markerPools.push(new MarkerPool());
				}
				
				// Fix the number of marker pools.
				markerPools.fixed = true;
				
				// Load the image files used by template markers.
				loader_.loadBinaries(featureSet_.templateFilenames);
			}
			else
			{
				// Supply the template marker's image to the native tracker.
				cLibInit_.supplyFile(filename, data);
				
				// Tell the native tracker to look for the template marker.
				nativeTracker_.addTemplateMarker
				(
					featureSet_.templateFilenames.indexOf(filename),
					featureSet_.templatePatternSize,
					filename
				);
			}
			
			if (loader_.numLoadsPending > 0)
			{
				return;
			}
			
			cLibInit_ = null;
			
			// Release the loader.
			loader_ = null;
			
			// Notify the delegate that the marker pools have been created and
			// tracking has started.
			delegate_.onTrackerStarted(this, markerPools);
		}
		
		
		
		private function log(level:uint, message:String):void
		{
			Logger.mainLogger.log("flare*tracker", level, message);
		}
	}
}