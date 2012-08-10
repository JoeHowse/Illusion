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
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	
	import nummist.illusion.graphics.SceneUtils;
	
	
	/**
	 * A pairing of a 3D viewport and a 2D background.
	 * 
	 * @flowerModelElementId _hxKcYNnZEeG6Ia5yiOlRVA
	 */
	public class AbstractARViewport extends Sprite
	{
		/**
		 * The Object3D instance that is the root of the 3D viewport's scene.
		 * Typically, this object is used as an argument in constructing
		 * AbstractTracker subclass instances.
		 */
		public const scene3D:Object3D = new Object3D();
		
		
		protected var stage3D_:Stage3D;
		protected var camera3D_:Camera3D;
		protected var showProfilingDiagram_:Boolean = false;
		protected var isAnyMeshOnScreen_:Boolean = false;
		
		
		/**
		 * Creates an AbstractARViewport object.
		 * <br /><br />
		 * Do not invoke this constructor; it is intended for use by subclasses
		 * only.
		 */
		public function AbstractARViewport()
		{
			super();
		}
		
		
		/**
		 * A value of <code>true</code> means that profiling data such as FPS,
		 * CPU usage, and memory usage are displayed in the upper right corner
		 * of the 2D stage.
		 */
		public function get showProfilingDiagram():Boolean
		{
			return showProfilingDiagram_;
		}
		/**
		 * Repositions and resizes the 3D viewport and its background to the
		 * specified cooridinates and dimensions.
		 * 
		 * @param newX The new x coordinate in pixels.
		 * @param newY The new y coordinate in pixels.
		 * @param newWidth The new width in pixels.
		 * @param newHeight The new height in pixels.
		 * 
		 * @throws ArgumentError if any argument is negative.
		 * 
		 * @flowerModelElementId _hx74cdnZEeG6Ia5yiOlRVA
		 */
		public function setFrame
		(newX:Number, newY:Number, newWidth:Number, newHeight:Number
		)
		:void
		{
			if (newX < 0)
			{
				throw new ArgumentError("x value must be non-negative");
			}
			
			if (newY < 0)
			{
				throw new ArgumentError("y value must be non-negative");
			}
			
			if (newWidth < 0)
			{
				throw new ArgumentError("width value must be non-negative");
			}
			
			if (newHeight < 0)
			{
				throw new ArgumentError("height value must be non-negative");
			}
			
			super.x = newX;
			super.y = newY;
			super.width = newWidth;
			super.height = newHeight;
		}
		
		public function set showProfilingDiagram(newShowProfilingDiagram:Boolean):void
		{
			if (newShowProfilingDiagram && !showProfilingDiagram_)
			{
				showProfilingDiagram_ = true;
				addChild(camera3D_.diagram);
			}
			else if (!newShowProfilingDiagram && showProfilingDiagram)
			{
				showProfilingDiagram_ = false;
				removeChild(camera3D_.diagram);
			}
		}
		
		
		/**
		 * @flowerModelElementId _hx8fhNnZEeG6Ia5yiOlRVA
		 */
		override public function set x(newX:Number):void
		{
			setFrame(newX, y, width, height);
		}
		
		/**
		 * @flowerModelElementId _hx9GkdnZEeG6Ia5yiOlRVA
		 */
		override public function set y(newY:Number):void
		{
			setFrame(x, newY, width, height);
		}
		
		/**
		 * @flowerModelElementId _hx9GlNnZEeG6Ia5yiOlRVA
		 */
		override public function set width(newWidth:Number):void
		{
			setFrame(x, y, newWidth, height);
		}
		
		/**
		 * @flowerModelElementId _hx9totnZEeG6Ia5yiOlRVA
		 */
		override public function set height(newHeight:Number):void
		{
			setFrame(x, y, width, newHeight);
		}
		
		
		/**
		 * @flowerModelElementId _hx-UsdnZEeG6Ia5yiOlRVA
		 */
		protected function render3D():void
		{
			if (SceneUtils.sceneContainsClass(scene3D, Mesh))
			{
				// There is at least one mesh in the 3D scene.
				
				// Redraw the 3D scene.
				camera3D_.render(stage3D_);
				
				isAnyMeshOnScreen_ = true;
			}
			else if (isAnyMeshOnScreen_)
			{
				// There is no mesh in the 3D scene but there is at least one
				// mesh rendered onscreen from last frame.
				
				// Redraw the 3D scene.
				camera3D_.render(stage3D_);
				
				// Do not redraw the 3D scene again until it contains at least
				// one mesh.
				isAnyMeshOnScreen_ = false;
			}
		}
	}
}