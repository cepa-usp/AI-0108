package 
{
	import cepa.AI;
	import cepa.AIObserver;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import tutorial.CaixaTexto;
	import tutorial.Tutorial;
	
	/**
	 * ...
	 * @author Arthur Tofani
	 */
	public class Main extends Sprite implements AIObserver
	{
		public var ai:AI;
		public var tutor:Tutorial = new Tutorial();
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function createTutorial() {
			/**
			 * Balão #1 (apontando para o menu de funções):
				Escolha a função que deve ser exibida.

				Balão #2 (apontando para o ponto B):
				Arraste os pontos A e B para alterar os limites de integração.

				Balão #3 (apontando para o check-box da área):
				Escolha o que você quer ver: a área, a aproximação por baixo (soma inferior) e/ou a soma superior.
			 */
				
			 tutor.adicionarBalao("Escolha a função que deve ser exibida.", new Point(590, 460), CaixaTexto.BOTTOM, CaixaTexto.RIGHT);
			 tutor.adicionarBalao("Arraste os pontos A e B para alterar os limites de integração.", new Point(263, 380), CaixaTexto.BOTTOM, CaixaTexto.CENTER);
			 tutor.adicionarBalao("Escolha o que você quer ver: a área, a aproximação por baixo (soma inferior) e/ou a soma superior.", new Point(320, 468), CaixaTexto.BOTTOM, CaixaTexto.RIGHT);
			 
			 
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			createTutorial();
			ai = new AI(this);
			ai.addObserver(this);
			var botbar:BottomBar = new BottomBar();
			botbar.y = 451;
			botbar.x = 112;
			ai.container.addChild(botbar);
			ai.container.messageLabel.visible = false;
			ai.container.setAboutScreen(new AboutScreen());						
			ai.container.setInfoScreen(new InstScreen());
			
			//ai.container.optionButtons.y = ai.container.optionButtons.y - 140;
			
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
		
		/* INTERFACE cepa.AIObserver */
		
		public function onResetClick() 
		{
			trace("reset");
		}
		
		public function onScormFetch() 
		{
			trace("scorm fetch");
		}
		
		public function onScormSave() 
		{
			trace("scorm save");
		}
		
		public function onTutorialClick() 
		{
			tutor.iniciar(stage);
		}
	}	
	
}