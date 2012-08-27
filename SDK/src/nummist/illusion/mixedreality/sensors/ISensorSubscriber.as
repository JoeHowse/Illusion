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


package nummist.illusion.mixedreality.sensors
{
	/**
	 * A subscriber providing a callback to a one or more AbstactSensor
	 * subclass instances.
	 * 
	 * @see AbstractSensor
	 * 
	 * @author Joseph Howse
	 * 
	 * @flowerModelElementId _hyRPoNnZEeG6Ia5yiOlRVA
	 */
	public interface ISensorSubscriber
	{
		/**
		 * Handles the event that updated data is availble from the
		 * specified sensor. Typically, this callback will fetch a handle to
		 * the data from <code>sensor.data</code>.
		 * 
		 * @param sensor The sensor.
		 * 
		 * @see AbstractSensor.data
		 */
		function onSensorDataUpdated(sensor:AbstractSensor):void;
	}
}