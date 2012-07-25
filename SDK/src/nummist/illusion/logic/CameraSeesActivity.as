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


package nummist.illusion.logic
{
	import flash.events.ActivityEvent;
	import flash.media.Camera;
	
	
	/**
	 * An object that can generate a Boolean representation of itself based on
	 * activity events fired by a specified camera.
	 * 
	 * @see ActivityEvent
	 * @see Camera.setMotionLevel()
	 * 
	 * @author Joseph Howse
	 */
	public class CameraSeesActivity implements ILogicalStatement
	{
		private var camera_:Camera;
		private var cameraSeesActivity_:Boolean;
		
		
		/**
		 * Creates a CameraSeesActivity object, which listens to a specified
		 * camera for activity events.
		 * 
		 * @param camera The camera that may fire activity events.
		 * 
		 * @throws ArgumentError if camera is <code>null</code>
		 */
		public function CameraSeesActivity(camera:Camera)
		{
			if (!camera)
			{
				throw new ArgumentError("camera must be non-null");
			}
			
			camera_ = camera;
			
			
			camera_.addEventListener
			(
				ActivityEvent.ACTIVITY, // type
				onActivity, // listener
				false, // useCapture
				0, // priority
				true // useWeakReference
			);
		}
		
		/**
		 * A boolean representation of this object. A value of
		 * <code>true</code> means the camera is detecting activity.
		 */
		public function toBoolean():Boolean
		{
			return cameraSeesActivity_;
		}
		
		
		private function onActivity(event:ActivityEvent):void
		{
			cameraSeesActivity_ = event.activating;
		}
	}
}