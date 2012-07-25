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
	import alternativa.engine3d.objects.Mesh;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	
	/**
	 * A pairing of a 3D viewport and a 2D background, based on a PixelFeed
	 * object's projection data and its source of pixel data.
	 * 
	 * @see PixelFeed
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8HXVMKnjEeG8rNJMqBg6NQ
	 */
	public class ARViewport extends Sprite
	{
		private const scene3D_:Object3D = new Object3D();
		private var background_:DisplayObject;
		private var stage3D_:Stage3D;
		private var camera3D_:Camera3D;
		private var showProfilingDiagram_:Boolean = false;
		private var mirrored_:Boolean = false;
		private var isAnyMeshOnScreen_:Boolean = false;
		
		
		/**
		 * Creates an ARViewport object that uses the specified Stage3D object
		 * for rendering, and the specified PixelFeed object to get the 3D
		 * field of view (FOV) and the 2D background. Optionally, near and far
		 * clipping depths can be specified as well. If unspecified, they
		 * default to 1 and 10000. Optionally, the 3D rendering's antialias
		 * level can be specified. It defaults to 4.
		 * 
		 * @param stage3D The Stage3D object.
		 * 
		 * @param pixelFeed The PixelFeed object.
		 * 
		 * @param nearClipping The 3D projection's near clipping depth.
		 * 
		 * @param farClipping The 3D projection's far clipping depth.
		 * 
		 * @param antialiasLevel The antialias level to apply in 3D rendering.
		 * 
		 * @flowerModelElementId _8Hnz4anjEeG8rNJMqBg6NQ
		 */
		public function ARViewport
		(
			stage3D:Stage3D,
			pixelFeed:PixelFeed,
			nearClipping:Number = 1,
			farClipping:Number = 10000,
			antialiasLevel:int = 4
		)
		{
			super();
			
			stage3D_ = stage3D;
			
			// Get the the pixel feed's source for use as the viewport's
			// background.
			background_ = pixelFeed.source;
			
			// Create the 3D camera.
			camera3D_ = new Camera3D(nearClipping, farClipping);
			
			// Set the 3D camera's FOV based on the pixel feed.
			camera3D_.fov = pixelFeed.diagonalFOV;
			
			// Configure the 3D camera to render to a texture in the 2D
			// context. This texture's background is transparent, so the pixel
			// feed's source shows through as if part of the 3D scene.
			camera3D_.view = new View
			(
				background_.width, // width
				background_.height, // height
				true, // renderToBitmap
				0, // backgroundColor
				0, // backgroundAlpha
				antialiasLevel // antiAlias
			);
			
			// Hide the AlternativaPlatform logo.
			camera3D_.view.hideLogo();
			
			// Add the background and 3D scene to the 2D scene.
			addChild(background_);
			addChild(camera3D_.view);
			
			// Add the 3D camera to the 3D scene.
			scene3D_.addChild(camera3D_);
			
			// Listen for frame updates.
			addEventListener
			(
				Event.EXIT_FRAME, // type
				onExitFrame, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
		}
		
		
		/**
		 * The Object3D instance that is the root of the 3D viewport's scene.
		 * Typically, this object is used as an argument in constructing
		 * AbstractTracker subclass instances.
		 */
		public function get scene3D():Object3D
		{
			return scene3D_;
		}
		
		/**
		 * A value of <code>true</code> that profiling data such as FPS, CPU
		 * usage, and memory usage are displayed in the upper right corner of
		 * the 2D stage.
		 */
		public function get showProfilingDiagram():Boolean
		{
			return showProfilingDiagram_;
		}
		
		public function set showProfilingDiagram(newShowProfilingDiagram:Boolean):void
		{
			if (newShowProfilingDiagram && !showProfilingDiagram_)
			{
				showProfilingDiagram_ = true;
				addChildAt(camera3D_.diagram, 2);
			}
			else if (!newShowProfilingDiagram && showProfilingDiagram)
			{
				showProfilingDiagram_ = false;
				removeChild(camera3D_.diagram);
			}
		}
		
		/**
		 * A value of <code>true</code> that the 3D viewport and its background
		 * (the PixelFeed object's source) are rendered with a horizontal flip,
		 * as if seen in a mirror. Changing this property's value has the
		 * side-effect of overwriting any previous transformation of the
		 * background. Note that in any case, transformations are irrelevant to
		 * the way that a PixelFeed object uses its source.
		 */
		public function get mirrored():Boolean
		{
			return mirrored_;
		}
		
		public function set mirrored(newMirrored:Boolean):void
		{
			if (newMirrored && !mirrored_)
			{
				mirrored_ = true;
				mirror();
			}
			else if (!newMirrored && mirrored_)
			{
				mirrored_ = false;
				var matrix:Matrix = new Matrix();
				background_.transform.matrix = matrix;
				camera3D_.view.transform.matrix = matrix;
			}
		}
		
		/**
		 * Resizes the 3D viewport and its background (the PixelFeed object's
		 * source) to the specified dimensions.
		 * 
		 * @param newWidth The new width in pixels.
		 * @param newHeight The new height in pixels.
		 */
		public function resize(newWidth:Number, newHeight:Number):void
		{
			// Resize the 3D camera's viewport.
			camera3D_.view.width = newWidth;
			camera3D_.view.height = newHeight;
			
			// Resize the viewport's background.
			background_.width = newWidth;
			background_.height = newHeight;
			
			if (mirrored_)
			{
				// Recreate and reapply the mirror matrix, which is
				// width-dependent.
				mirror();
			}
		}
		
		
		
		/**
		 * @flowerModelElementId _8HssYqnjEeG8rNJMqBg6NQ
		 */
		private function onExitFrame(event:Event):void
		{
			if (isAnyMeshIn(scene3D_))
			{
				// There is at least one mesh in the 3D scene.
				
				// Redraw the 3D scene.
				camera3D_.render(stage3D_);
				
				isAnyMeshOnScreen_ = true;
			}
			else if (isAnyMeshOnScreen_)
			{
				// There is no mesh in the 3D scene but there is at least one
				// mesh rendered on screen from last frame.
				
				// Redraw the 3D scene.
				camera3D_.render(stage3D_);
				
				isAnyMeshOnScreen_ = false;
			}
		}
		
		
		/**
		 * @flowerModelElementId _8HtTcKnjEeG8rNJMqBg6NQ
		 */
		private function mirror():void
		{
			// Create and apply the mirror matrix, which is width-dependent.
			var mirrorMatrix:Matrix = background_.transform.matrix;
			mirrorMatrix.a = -1;
			mirrorMatrix.tx = background_.width;
			background_.transform.matrix = mirrorMatrix;
			camera3D_.view.transform.matrix = mirrorMatrix;
		}
		
		private function isAnyMeshIn(object3D:Object3D):Boolean
		{
			if (object3D is Mesh)
			{
				return true;
			}
			for (var i:uint; i < object3D.numChildren; i++)
			{
				if (isAnyMeshIn(object3D.getChildAt(i)))
				{
					return true;
				}
			}
			return false;
		}
	}
}