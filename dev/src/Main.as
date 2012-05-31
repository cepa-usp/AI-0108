package 
{
	import cepa.ai.AI;
	import cepa.ai.AIObserver;
	import cepa.tooltip.ToolTip;
	import cepa.tutorial.CaixaTexto;
	import cepa.tutorial.Tutorial;
	import flash.display.Loader;
	import cepa.ai.AIContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
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
		
		private function createTutorial():void {
			/**
			 * Balão #1 (apontando para o menu de funções):
				Escolha a função que deve ser exibida.

				Balão #2 (apontando para o ponto B):
				Arraste os pontos A e B para alterar os limites de integração.

				Balão #3 (apontando para o check-box da área):
				Escolha o que você quer ver: a área, a aproximação por baixo (soma inferior) e/ou a soma superior.
			 */
			
			 tutor.adicionarBalao("Escolha a função que deve ser exibida.", new Point(540, 460), CaixaTexto.BOTTOM, CaixaTexto.RIGHT);
			 tutor.adicionarBalao("Arraste os pontos a e b para alterar os limites de integração.", new Point(277, 380), CaixaTexto.BOTTOM, CaixaTexto.CENTER);
			 tutor.adicionarBalao("Escolha o que você quer ver: a área, a aproximação por baixo (soma inferior) e/ou a soma superior.", new Point(317, 506), CaixaTexto.BOTTOM, CaixaTexto.RIGHT);
			 tutor.adicionarBalao("Altere o número de elementos de área", new Point(475, 495), CaixaTexto.RIGHT, CaixaTexto.LAST);
			 
			 
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			createTutorial();
			ai = new AI(this);
			ai.addObserver(this);
			var botbar:BottomBar = new BottomBar();
			botbar.filters = [AIContainer.SHADOW_FILTER];
			botbar.y = 451;
			botbar.x = 122;
			ai.container.addChild(botbar);
			ai.container.messageLabel.visible = false;
			ai.container.setAboutScreen(new AboutScreen());					
			
			ai.container.setInfoScreen(new InstScreen());
			
			
			ai.container.optionButtons.y = 344;
			ai.container.optionButtons.x += 7;
			ai.container.optionButtons.y += 35;
			//ai.container.optionButtons.y = ai.container.optionButtons.y - 140;
			
			loadLO();
			//ai.container.optionButtons.btReset.enabled = false;
			ai.container.disableComponent(ai.container.optionButtons.btReset)
			//ai.container.optionButtons.btReset.alpha = 0.6;
			
			new ToolTip(ai.container.optionButtons.btOrientacoes, "Orientações");
			new ToolTip(ai.container.optionButtons.btTutorial, "Tutorial");
			new ToolTip(ai.container.optionButtons.btCreditos, "Créditos");
			
			tutor.iniciar(stage);
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
			//
		}
		
		/* INTERFACE cepa.AIObserver */
		
		public function onResetClick():void 
		{
		//	loadLO();
		}
		
		public function onScormFetch():void
		{
			trace("scorm fetch");
		}
		
		public function onScormSave():void
		{
			trace("scorm save");
		}
		
		public function onTutorialClick():void
		{
			tutor.iniciar(stage);
		}
	}	
	
}