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


package nummist.illusion.mixedreality
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.View;
	
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.StageVideo;
	
	
	/**
	 * A pairing of a 3D viewport and a 2D background, based on a
	 * PixelFeedFromCamera instance's projection data and its source of pixel
	 * data. The 3D content is displayed via Stage and the 2D content is
	 * displayed via StageVideo.
	 * <br /><br />
	 * The reason for displaying the 3D content via Stage is that Stage3D lacks
	 * support for background transparency (as of Flash 11.4 Beta 1).
	 * 
	 * @see PixelFeedFromCamera
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _hxt2ANnZEeG6Ia5yiOlRVA
	 */
	public class ARViewportUsingStageVideo extends AbstractARViewport
	{
		private var videoCamera_:Camera;
		private var stageVideo_:StageVideo;
		
		
		/**
		 * Creates an ARViewportUsingStageVideo object that uses the specified
		 * StageVideo object for rendering and display, the specified Stage3D
		 * object for rendering (though not display), and the specified
		 * PixelFeedFromDisplayObject instance to get the 3D field of view
		 * (FOV) and the 2D background. Optionally, near and far clipping
		 * depths can be specified as well. If unspecified, they default to 1
		 * and 10000. Optionally, the 3D rendering's antialias level can be
		 * specified. It defaults to 4.
		 * 
		 * @param stageVideo The video stage.
		 * 
		 * @param stage3D The 3D stage.
		 * 
		 * @param pixelFeed The pixel feed.
		 * 
		 * @param nearClipping The 3D projection's near clipping depth.
		 * 
		 * @param farClipping The 3D projection's far clipping depth.
		 * 
		 * @param antialiasLevel The antialias level to apply in 3D rendering.
		 * 
		 * @throws ArgumentError if any argument is <code>null</code>.
		 */
		public function ARViewportUsingStageVideo
		(
			stageVideo:StageVideo,
			stage3D:Stage3D,
			pixelFeed:PixelFeedFromCamera,
			nearClipping:Number = 1,
			farClipping:Number = 10000,
			antialiasLevel:int = 4
		)
		{
			super();
			
			if (!stageVideo)
			{
				throw new ArgumentError("stageVideo must be non-null");
			}
			
			if (!stage3D)
			{
				throw new ArgumentError("stage3D must be non-null");
			}
			
			if (!pixelFeed)
			{
				throw new ArgumentError("pixelFeed must be non-null");
			}
			
			stageVideo_ = stageVideo;
			stage3D_ = stage3D;
			
			// Get the pixel feed's source for use as the video stage's source.
			videoCamera_ = pixelFeed.source;
			
			// Configure the video stage.
			stageVideo_.attachCamera(videoCamera_);
			stageVideo_.viewPort = new Rectangle(0, 0, videoCamera_.width, videoCamera_.height);
			
			// Create the 3D camera.
			camera3D_ = new Camera3D(nearClipping, farClipping);
			
			// Set the 3D camera's FOV based on the pixel feed.
			camera3D_.fov = pixelFeed.diagonalFOV;
			
			// Configure the 3D camera to render to a texture in the 2D
			// context. This texture's background is transparent, so the pixel
			// feed's source shows through as if part of the 3D scene.
			camera3D_.view = new View
			(
				videoCamera_.width, // width
				videoCamera_.height, // height
				true, // renderToBitmap
				0x000000, // backgroundColor
				0, // backgroundAlpha
				antialiasLevel // antiAlias
			);
			
			// Hide the AlternativaPlatform logo.
			camera3D_.view.hideLogo();
			
			// Add the 3D viewport to the 2D scene.
			addChild(camera3D_.view);
			
			// Add the 3D camera to the 3D scene.
			scene3D.addChild(camera3D_);
			
			// Listen for frame updates to the pixel feed's source.
			pixelFeed.source.addEventListener
			(
				Event.VIDEO_FRAME, // type
				onSourceVideoFrame, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
		}
		
		
		override public function setFrame
		(
			newX:Number,
			newY:Number,
			newWidth:Number,
			newHeight:Number
		)
		:void
		{
			super.setFrame(newX, newY, newWidth, newHeight);
			
			// Resize the viewport of the video stage.
			stageVideo_.viewPort = new Rectangle(newX, newY, newWidth, newHeight);
		}
		
		
		private function onSourceVideoFrame(event:Event):void
		{
			render3D();
		}
	}
}