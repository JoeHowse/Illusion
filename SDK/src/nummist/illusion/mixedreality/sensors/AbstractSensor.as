package nummist.illusion.mixedreality.sensors
{
	import flash.utils.ByteArray;
	
	import nummist.illusion.logic.ILogicalStatement;
	
	
	/**
	 * A producer of pixel sensor data, as used by AbstractTracker subclasses
	 * and other ISensorSubscriber implementations.
	 * 
	 * @see AbstractTracker
	 * 
	 * @see ISensorSubscriber
	 * 
	 * @author Joseph Howse
	 * @flowerModelElementId _aH6bwO_BEeGbQeQC2EWusw
	 */
	public class AbstractSensor
	{
		/**
		 * A condition that must be true in order for the sensor data to be
		 * updated. If the condition is <code>null</code> (the default), the
		 * sensor data is updated at every opportunity.
		 */
		public var redrawCondition:ILogicalStatement;
		
		
		protected const subscribers_:Vector.<ISensorSubscriber> =
			new Vector.<ISensorSubscriber>();
		protected var data_:ByteArray;
		
		
		/**
		 * A handle to the latest sensor data with its pointer rewound to index
		 * 0. The data is current at the time when subscribers receive a call
		 * to <code>onSensorDataUpdated</code>.
		 * 
		 * @see ISensorSubscriber
		 */
		public function get data():ByteArray
		{
			// Rewind the file pointer.
			data_.position = 0;
			
			return data_;
		}
		
		
		/**
		 * Start notifying the specified object about updates to the sensor
		 * data.
		 * 
		 * @param subscriber The subscriber.
		 */
		public function addSubscriber(subscriber:ISensorSubscriber):void
		{
			subscribers_.push(subscriber);
		}
		
		/**
		 * If the specified object is being notified about updates to the
		 * sensor data, stop notifying it.
		 * 
		 * @param subscriber The subscriber.
		 */
		public function removeSubscriber(subscriber:ISensorSubscriber):void
		{
			var i:int = subscribers_.indexOf(subscriber);
			if (i != -1)
			{
				subscribers_.splice(i, 1);
			}
		}
		
		/**
		 * Stop notifying all objects about updates to the sensor data.
		 */
		public function removeAllSubscribers():void
		{
			subscribers_.splice(0, subscribers_.length);
		}
		
		
		/**
		 * Notify subscribers that the sensor data has been updated.
		 * 
		 * @flowerModelElementId _hyIFsNnZEeG6Ia5yiOlRVA
		 */
		protected function dispatchUpdateNotice():void
		{
			for each (var subscriber:ISensorSubscriber in subscribers_)
			{
				subscriber.onSensorDataUpdated(this);
			}
		}
	}
}