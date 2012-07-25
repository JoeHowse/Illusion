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


package nummist.illusion.mixedreality.flare
{
	import alternativa.engine3d.core.Object3D;
	
	import cmodule.libFlareNFT.CLibInit;
	
	import flash.utils.ByteArray;
	
	import nummist.illusion.core.ILoaderDelegate;
	import nummist.illusion.core.Loader;
	import nummist.illusion.core.Logger;
	import nummist.illusion.core.StringUtils;
	import nummist.illusion.mixedreality.AbstractTracker;
	import nummist.illusion.mixedreality.ITrackerDelegate;
	import nummist.illusion.mixedreality.MarkerEvent;
	import nummist.illusion.mixedreality.MarkerPool;
	import nummist.illusion.mixedreality.MarkerPoolIterator;
	import nummist.illusion.mixedreality.PixelFeed;
	
	
	/**
	 * An AbstractTracker subclass that wraps flare&#42;nft, the natural
	 * feature tracker from Imagination Computer Services GmbH.
	 * 
	 * @see AbstractTracker
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8F9nAKnjEeG8rNJMqBg6NQ
	 */
	public class FlareNaturalFeatureTracker extends AbstractTracker
		implements ILoaderDelegate
	{
		private var virtualButtonDelegate_:IFlareVirtualButtonDelegate;
		private var multiTargets_:Boolean;
		private var dataPath_:String;
		private var licenseFilename_:String;
		private var featureSetFilename_:String;
		
		private var loader_:Loader;
		private var cLibInit_:CLibInit;
		private var nativeTracker_:*;
		private var nativeBuffer_:ByteArray;
		private var nativeImagePointer_:uint;
		
		
		/**
		 * Creates a FlareNaturalFeatureTracker object.
		 * 
		 * @param delegate A delegate that is provided the opportunity to
		 * populate the MarkerPool objects when they are created and when they
		 * are asked for more markers than they have. Additionally, if the
		 * delegate implements the IFlareVirtualButtonDelegate interface, it is
		 * provided the opportunity to handle virtual button presses and
		 * releases.
		 * 
		 * @param pixelFeed The supplier of bitmap and projection data.
		 * 
		 * @param scene3D The 3D node wherein markers are placed.
		 * 
		 * @param autoStart A value of <code>true</code> means this object will
		 * <code>start()</code> immediately if the PixelFeed object's source is
		 * onstage, and automatically whenever the PixelFeed object's source is
		 * added to the stage. Regardless, this object will <code>stop()</code>
		 * whenever the PixelFeed object's source is removed from the stage.
		 * 
		 * @param multiTargets False means that at most one marker, from all
		 * pools, can be considered found at any given time. This limitation
		 * may improve performance.
		 * 
		 * @param dataPath The path to the folder containing the flare&#42;nft
		 * license, feature set, data, and image files. If this argument is
		 * omitted or <code>null</code>, it defaults to <code>"data/"</code>.
		 * 
		 * @param licenseFilename The path to the flare&#42;nft license file,
		 * relative to dataPath. If this argument is omitted or
		 * <code>null</code>, it defaults to <code>"flareNFT.lic"</code>.
		 * 
		 * @param featureSetFilename The path to the flare&#42;nft feature set
		 * file, relative to dataPath. Other paths are read from this file and
		 * are interpreted as being relative to dataPath. The file's entries
		 * should be in ascending order of marker ID, and marker IDs should be
		 * consecutive, starting at 0. If this argument is omitted or
		 * <code>null</code>, it defaults to <code>"featureSet.ini"</code>.
		 * 
		 * @throws ArgumentError if <code>delegate</code>,
		 * <code>pixelFeed</code>, or <code>scene3D</code> is
		 * <code>null</code>.
		 */
		public function FlareNaturalFeatureTracker
		(
			delegate:ITrackerDelegate,
			pixelFeed:PixelFeed,
			scene3D:Object3D,
			autoStart:Boolean = true,
			multiTargets:Boolean = true,
			dataPath:String = "data/",
			licenseFilename:String = "flareNFT.lic",
			featureSetFilename:String = "featureSet.ini"
		)
		{
			virtualButtonDelegate_ = delegate as IFlareVirtualButtonDelegate;
			multiTargets_ = multiTargets;
			dataPath_ = (dataPath ? dataPath : "data/");
			licenseFilename_ = (licenseFilename ? licenseFilename : "flareNFT.lic");
			featureSetFilename_ = (featureSetFilename ? featureSetFilename : "featureSet.ini");
			
			super(delegate, pixelFeed, scene3D, autoStart);
		}
		
		
		/**
		 * Adds a virtual button, which is a region (associated with a
		 * specified marker ID) that is considered "pressed" whenever it starts
		 * being occluded, and "released" whenever it stops being occluded. The
		 * region has the specified coordinates in terms of pixels (in the
		 * image file associated with the specified marker ID).
		 * 
		 * @param markerID The marker ID and the index of its MarkerPool
		 * object.
		 * 
		 * @param xLeft The region's left coordinate in pixels.
		 * 
		 * @param yTop The region's top coordinate in pixels.
		 * 
		 * @param xRight The region's right coordinate in pixels.
		 * 
		 * @param yBottom The region's bottom coordinate in pixels.
		 * 
		 * @param minCoverageProportionArea The proportion of the region, by
		 * area, that needs to be covered for the button to be considered
		 * "pressed". The valid range is (0, 1], with a default value of 0.7.
		 * 
		 * @param minCoverageProportionTime The proportion of the time, during
		 * an observation period of <code>delay</code> seconds, that the region
		 * has to be occluded for the button to be considered "pressed". The
		 * valid range is (0, 1], with a default value of 0.8.
		 *
		 * @param delay The "ideal" length in seconds of the observation period
		 * of the button's state. (The actual period will be longer than the
		 * ideal period if the actual frame rate drops below the ideal frame
		 * rate.) The shorter the period, the faster each button interaction
		 * will be recognized as a "press" or "release". However, if the period
		 * is too short, non-interactions may be mistakenly recognized as
		 * interactions. The default value is 0.25.
		 * 
		 * @return The ID of the virtual button, or -1 if the creation fails.
		 * 
		 * @throws ArgumentError if <code>xLeft</code> is not less than
		 * <code>xRight</code>, <code>yTop</code> is not less than
		 * <code>yBottom</code>, <code>minCoverageProportionArea</code> is not
		 * in the range (0, 1], or <code>minCoverageProportionTime</code> is
		 * not in the range (0, 1].
		 * 
		 * @throws Error if this FlareNaturalFeatureTracker object is not
		 * currently started, or its delegate does not implement
		 * IFlareVirtualButtonDelegate.
		 * 
		 * @see IFlareVirtualButtonDelegate
		 */
		public function addVirtualButton
		(
			markerID:uint,
			xLeft:Number,
			yTop:Number,
			xRight:Number,
			yBottom:Number,
			minCoverageProportionArea:Number = 0.7,
			minCoverageProportionTime:Number = 0.8,
			delay:Number = 0.25
		)
		:int
		{
			if (xLeft >= xRight)
			{
				throw new ArgumentError("xLeft must be less than xRight");
			}
			
			if (yTop >= yBottom)
			{
				throw new ArgumentError("yTop must be less than yBottom");
			}
			
			if (minCoverageProportionArea <= 0 || minCoverageProportionArea > 1)
			{
				throw new ArgumentError("minCoverageArea must be in the range (0, 1]");
			}
			
			if (minCoverageProportionTime <= 0 || minCoverageProportionTime > 1)
			{
				throw new ArgumentError("minCoverageTime must be in the range (0, 1]");
			}
			
			if (!nativeTracker_)
			{
				throw new Error("addVirtualButton must be called in the onTrackerStarted callback or later");
			}
			
			if (!virtualButtonDelegate_)
			{
				throw new Error("the delegate must implement IFlareVirtualButtonDelegate");
			}
			
			var delayFrames:uint = Math.max(1, delay * stage.frameRate);
			var minCoverageTimeFrames:uint = Math.max(1, minCoverageProportionTime * delayFrames);
			
			// Register the virtual button with the native tracker.
			return nativeTracker_.addButton
			(
				markerID,
				xLeft,
				yTop,
				xRight,
				yBottom,
				minCoverageProportionArea,
				minCoverageTimeFrames,
				delayFrames
			);
		}
		
		
		override public function start():void
		{
			super.start();
			
			cLibInit_ = new CLibInit();
			
			loader_ = new Loader
			(
				this,
				StringUtils.absolutePath(dataPath_, stage)
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
			while (markerPools.length > 0)
			{
				markerPools.pop();
			}
			markerPools.fixed = true;
		}
		
		
		override protected function updateTrackedMarkers
		(
			markerPoolIterators:Vector.<MarkerPoolIterator>,
			pixels:ByteArray
		)
		:void
		{
			// Wait until flare*nft is fully initialized.
			if (!nativeBuffer_)
			{
				return;
			}
			
			// Write the pixels to the native buffer.
			nativeBuffer_.position = nativeImagePointer_;
			nativeBuffer_.writeBytes(pixels);	
			
			// Update the native tracker and get the number of markers found.
			var numMarkersTracked:uint = nativeTracker_.update();
			
			// Move the native buffer's pointer to the tracker results.
			nativeBuffer_.position = nativeTracker_.getTrackerResultPtr();
			
			// Iterate over all tracked markers.
			for (var i:uint = 0; i < numMarkersTracked; i++)
			{
				// Skip the bytes that are reserved for future use.
				nativeBuffer_.readInt();
				
				// Read the marker's ID.
				var markerID:int = nativeBuffer_.readInt();
				
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
				}
			}
		}
		
		
		/**
		 * Part of the ILoaderDelegate implementation. Do not invoke this
		 * method; it is intended for use by an internal Loader object only.
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
		 * Part of the ILoaderDelegate implementation. Do not invoke this
		 * method; it is intended for use by an internal Loader object only.
		 * 
		 * @throws Error if flare*nft finds an invalid license file, fails to
		 * initialize, or fails to load the feature set.
		 */
		public function onLoadComplete(loader:Loader, filename:String, data:*):void
		{
			if (filename == licenseFilename_)
			{
				cLibInit_.supplyFile("flareNFT.lic", data);
				
				loader_.loadBinary(featureSetFilename_);
				
				return;
			}
			
			if (filename == featureSetFilename_)
			{
				cLibInit_.supplyFile("data/" + featureSetFilename_, data);
				
				// Parse the names of the other required files.
				
				// TODO: Handle the case of a .swf feature set file.
				
				var lines:Array = (data.toString()).split("\n");
				var lowercaseImageFileExtension:String = ".pgm";
				for(var i:uint = 0; i < lines.length; i++)
				{
					var line:String = lines[i];
					var p:int = line.search("=") + 1;
					if (p <= 1)
					{
						continue;
					}
					var otherFilename:String = StringUtils.trim(line.substr(p));
					
					if (line.search(/database\s*=/) == 0)
					{
						// Load the database files.
						loader_.loadBinaries
						(
							otherFilename + ".set",
							otherFilename + "_0.spil",
							otherFilename + "_1.spil",
							otherFilename + "_2.spil"
						); // TODO: Other number suffixes?
					}
					else if (line.search(/target-ext\s*=/) == 0)
					{
						// Remember the file extension for subsequent image
						// files.
						lowercaseImageFileExtension = "." + otherFilename.toLowerCase();
					}
					else if (line.search(/target\d*-name\s*=/) == 0)
					{
						// Load the image file.
						loader_.loadBinary(otherFilename + lowercaseImageFileExtension);
						
						// Unfix the number of marker pools.
						markerPools.fixed = false;
						
						// Create the marker pool corresponding to the image.
						markerPools.push(new MarkerPool());
						
						// Fix the number of marker pools.
						markerPools.fixed = true;
					}
				}
				
				return;
			}
			
			var lowercaseFileExtension:String =
				StringUtils.lowercaseFileExtension(filename);
			if
			(
				lowercaseFileExtension != ".set" &&
				lowercaseFileExtension != ".spil" &&
				lowercaseFileExtension != ".pgm"
			)
			{
				// The file is presumably a bitmap but not a .pgm.
				// flare*nft requires images to be in .pgm format.
				
				// Convert the data.
				data = FlareUtils.rawPGM(data);
				
				// Convert the file extension.
				if (lowercaseFileExtension == "")
				{
					filename += ".pgm"
				}
				else
				{
					filename = filename.substring(0, filename.lastIndexOf(".")) + ".pgm";
				}
			}
			cLibInit_.supplyFile("data/" + filename, data);
			
			if (loader_.numLoadsPending > 0)
			{
				return;
			}
			
			// Release the loader.
			loader_ = null;
			
			// Generate the camera configuration and supply it to the native
			// tracker.
			cLibInit_.supplyFile
			(
				"data/cam.ini",
				FlareUtils.rawCamConfig(pixelFeed_)
			);
			
			nativeTracker_ = cLibInit_.init();
			cLibInit_ = null;
			nativeTracker_.setLogger(this, log, 5);
			
			// Initialize the native tracker.
			if (!nativeTracker_.initTracker
			(
				stage,
				pixelFeed_.width,
				pixelFeed_.height,
				multiTargets_,
				stage.frameRate, // value seems not to matter
				"data/cam.ini"
			))
			{
				stop();
				throw new Error("flare*nft failed to initialize");
			}
			
			// Load the feature set from file.
			if (!nativeTracker_.loadTargets("data/" + featureSetFilename_))
			{
				stop();
				throw new Error("flare*nft failed to load the feature set");
			}
			
			// Get the native buffer.
			var namespace:Namespace = new Namespace("cmodule.libFlareNFT");
			nativeBuffer_ = (namespace::gstate).ds; // accessible despite compiler warning
			
			// Get the offset to the image buffer.
			nativeImagePointer_ = nativeTracker_.getImageBufferPtr();
			
			if (virtualButtonDelegate_)
			{
				// Register the delegate as the handler of virtual button
				// presses and releases.
				nativeTracker_.setButtonHandler(this, onVirtualButtonEvent);
			}
			
			// Notify the delegate that the marker pools have been created and
			// tracking has started.
			delegate_.onTrackerStarted(this, markerPools);
		}
		
		
		private function log(level:uint, message:String):void
		{
			Logger.mainLogger.log("flare*nft", level, message);
		}
		
		private function onVirtualButtonEvent
		(
			markerID:uint,
			buttonID:uint,
			press:Boolean
		)
		:void
		{
			virtualButtonDelegate_.onVirtualButtonEvent
			(
				this,
				markerID,
				buttonID,
				press
			);
		}
	}
}