package cepa.ai 
{
	import cepa.scorm.ScormComm;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Arthur Tofani
	 */
	public class AI 
	{
		private var _container:AIContainer;
		private var _scorm:ScormComm = new ScormComm();
		private var _observers:Vector.<AIObserver> = new Vector.<AIObserver>();
		public function AI(stagesprite:Sprite) 
		{
			container = new AIContainer(stagesprite, this);
		}
		
		public function addObserver(obs:AIObserver):void {
			observers.push(obs);
		}
		
		public function onTutorialClick(e:Event):void 
		{
			for each(var obs:AIObserver in observers) obs.onTutorialClick();
		}
		public function onResetClick(e:Event):void 
		{
			for each (var obs:AIObserver in observers) obs.onResetClick();
		}		
		
		public function get container():AIContainer 
		{
			return _container;
		}
		
		public function set container(value:AIContainer):void 
		{
			_container = value;
		}
		
		public function get scorm():ScormComm 
		{
			return _scorm;
		}
		
		public function set scorm(value:ScormComm):void 
		{
			_scorm = value;
		}
		
		public function get observers():Vector.<AIObserver> 
		{
			return _observers;
		}
		
	}

}