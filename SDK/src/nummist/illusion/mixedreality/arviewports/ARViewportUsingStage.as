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


package nummist.illusion.mixedreality.arviewports
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.View;
	
	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import nummist.illusion.mixedreality.sensors.VisualSensorFromDisplayObject;
	
	
	/**
	 * A pairing of a 3D viewport and a 2D background, based on a
	 * VisualSensorFromDisplayObject instance's projection data and its source
	 * of pixel data. The 3D and 2D content are both displayed via Stage.
	 * 
	 * @see VisualSensorFromDisplayObject
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _8HXVMKnjEeG8rNJMqBg6NQ
	 */
	public class ARViewportUsingStage extends AbstractARViewport
	{
		private var background_:DisplayObject;
		private var mirrored_:Boolean = false;
		
		
		/**
		 * Creates an ARViewportUsingStage object that uses the specified
		 * Stage3D object for rendering (though not display), and the specified
		 * VisualSensorFromDisplayObject instance to get the 3D field of view
		 * (FOV) and the 2D background. Optionally, near and far clipping
		 * depths can be specified as well. If unspecified, they default to 1
		 * and 10000. Optionally, the 3D rendering's antialias level can be
		 * specified. It defaults to 4.
		 * 
		 * @param stage3D The 3D stage.
		 * 
		 * @param visualSensor The visual sensor.
		 * 
		 * @param nearClipping The 3D projection's near clipping depth.
		 * 
		 * @param farClipping The 3D projection's far clipping depth.
		 * 
		 * @param antialiasLevel The antialias level to apply in 3D rendering.
		 * 
		 * @throws ArgumentError if any argument is <code>null</code>.
		 * 
		 * @flowerModelElementId _8Hnz4anjEeG8rNJMqBg6NQ
		 */
		public function ARViewportUsingStage
		(
			stage3D:Stage3D,
			visualSensor:VisualSensorFromDisplayObject,
			nearClipping:Number = 1,
			farClipping:Number = 10000,
			antialiasLevel:int = 4
		)
		{
			super();
			
			if (!stage3D)
			{
				throw new ArgumentError("stage3D must be non-null");
			}
			
			if (!visualSensor)
			{
				throw new ArgumentError("visualSensor must be non-null");
			}
			
			stage3D_ = stage3D;
			
			// Get the the visual sensor's source for use as the viewport's
			// background.
			background_ = visualSensor.source;
			
			// Create the 3D camera.
			camera3D_ = new Camera3D(nearClipping, farClipping);
			
			// Set the 3D camera's FOV based on the visual sensor.
			camera3D_.fov = visualSensor.diagonalFOV;
			
			// Configure the 3D camera to render to a texture in the 2D
			// context. This texture's background is transparent, so the visual
			// sensor's source shows through as if part of the 3D scene.
			camera3D_.view = new View
			(
				background_.width, // width
				background_.height, // height
				true, // renderToBitmap
				0x000000, // backgroundColor
				0, // backgroundAlpha
				antialiasLevel // antiAlias
			);
			
			// Hide the AlternativaPlatform logo.
			camera3D_.view.hideLogo();
			
			// Add the background and 3D viewport to the 2D scene.
			addChild(background_);
			addChild(camera3D_.view);
			
			// Add the 3D camera to the 3D scene.
			scene3D.addChild(camera3D_);
			
			// Listen for frame updates to the visual sensor's source. The
			// listener has the lowest possible priority value, such that other
			// listeners' results (including tracking results) tend to be
			// available without a frame lag.
			visualSensor.source.addEventListener
			(
				Event.EXIT_FRAME, // type
				onSourceExitFrame, // listener
				false, // useCapture
				int.MIN_VALUE, // priority
				true // useWeakReference
			);
		}
		
		
		/**
		 * A value of <code>true</code> means that the 3D viewport and its
		 * background (the visual sensor's source) are rendered with a
		 * horizontal flip, as if seen in a mirror. Changing this property's
		 * value has the side-effect of overwriting any previous transformation
		 * of the background. Note that in any case, transformations are
		 * irrelevant to the way that a visual sensor uses its source.
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
		 * @flowerModelElementId _hxo9gNnZEeG6Ia5yiOlRVA
		 */
		override public function setFrame
		(newX:Number, newY:Number, newWidth:Number, newHeight:Number
		)
		:void
		{
			if (mirrored_ && newWidth != width)
			{
				// Recreate and reapply the mirror matrix, which is
				// width-dependent, in order to avoid the possibility of
				// cumulative rounding errors.
				mirror();
			}
			
			super.setFrame(newX, newY, newWidth, newHeight);
		}
		
		
		/**
		 * @flowerModelElementId _8HssYqnjEeG8rNJMqBg6NQ
		 */
		private function onSourceExitFrame(event:Event):void
		{
			render3D();
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
	}
}