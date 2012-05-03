package 
{
	import cepa.AI;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Arthur Tofani
	 */
	public class Main extends Sprite 
	{
		public var ai:AI;
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			ai = new AI(this);
			ai.container.setAboutScreen(new AboutScreen());			
			ai.container.setInfoScreen(new InstScreen());
			
			loadLO();
		}

		private function loadLO():void {
			var my_Loader:Loader = new Loader();
			var my_url:URLRequest=new URLRequest("v1/0108.swf");
			my_Loader.contentLoaderInfo.addEventListener(Event.COMPLETE, finishLoading);
			my_Loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			my_Loader.load(my_url);

		}
		private function finishLoading(loadEvent:Event):void {
			ai.container.addChild(loadEvent.currentTarget.content);
		}

		private function errorHandler(e:Event):void 
		{
			
		}
	}	
	
}