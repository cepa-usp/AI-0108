package cepa.ai
{
	import cepa.tooltip.ToolTip;
	import com.adobe.protocols.dict.Database;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.pipwerks.SCORM;
	import flash.display.DisplayObject;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Arthur Tofani
	 */
	public class AIContainer extends Sprite
	{
		public static const SHADOW_FILTER:DropShadowFilter = new DropShadowFilter(3, 45, 0x000000, 1, 5, 5);
		public static const DISABLE_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
                       0.2225, 0.7169, 0.0606, 0, 0,
                       0.2225, 0.7169, 0.0606, 0, 0,
                       0.2225, 0.7169, 0.0606, 0, 0,
                       0.0000, 0.0000, 0.0000, 1, 0
        ]);		
		private var layerUI:Sprite = new Sprite();
		private var ai:AI;
		private var margin:int = 25;
		private var _optionButtons:MenuBotoes = new MenuBotoes()
		private var _messageLabel:TextoExplicativo = new TextoExplicativo();
		private var aboutScreen:Sprite;
		private var border:Sprite = new Sprite();
		private var infoScreen:Sprite;
		
		public function AIContainer(stagesprite:Sprite, ai:AI)
		{	
			stagesprite.addChild(this);
			this.ai = ai;
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			this.scrollRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);			
			createUI();
			setAboutScreen(new AboutScreen());
			bindMenuButtons();
			adjustBorder();
		}
		
		public function disableComponent(display:*):void {
			try {
				display.alpha = 0.5;
				display.mouseEnabled = false;
				display.filters = [DISABLE_FILTER];
			} catch (e:Error) {
				//nada
				trace(e.getStackTrace());
			}
		}
		
		public function adjustBorder():void {
			var b:Borda = new Borda();			
			b.scale9Grid = new Rectangle(20, 20, b.width - 40, b.height - 40);
			b.width = this.stage.stageWidth;
			b.height = this.stage.stageHeight;
			border.addChild(b);
			
		}
		
		public function setAboutScreen(sprite:Sprite):void {
			if(aboutScreen!=null) layerUI.removeChild(aboutScreen);
			aboutScreen = sprite;
//			var bt:CloseButton = new CloseButton();
			//aboutScreen.addChild(bt);
			aboutScreen.x = 700 / 2;
			aboutScreen.y = 688 / 2 + 88;
			//bt.x = aboutScreen.width - 30;
			//bt.y = 30;
			aboutScreen.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { closeScreen(aboutScreen) } );				
			optionButtons.btCreditos.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				openScreen(aboutScreen);
			});
			
			layerUI.addChild(aboutScreen);
			layerUI.addChild(border);
			aboutScreen.alpha = 0;
			aboutScreen.visible = false;

			closeScreen2(aboutScreen);
		}
		public function setInfoScreen(sprite:Sprite):void {
			if(infoScreen!=null) layerUI.removeChild(infoScreen);
			infoScreen = sprite;
			var bt:CloseButton = new CloseButton();
			infoScreen.x = 700 / 2;
			infoScreen.y = 688 / 2 + 6;

			bt.x = infoScreen.width - 30;
			bt.y = 30;
			infoScreen.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void{closeScreen(infoScreen)});	
			optionButtons.btOrientacoes.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				openScreen(infoScreen);
			});
			layerUI.addChild(infoScreen);
			layerUI.addChild(border);
			infoScreen.alpha = 0;
			infoScreen.visible = false;
			closeScreen2(infoScreen);
			
			 
		}
		public function closeScreen(spriteScreen:Sprite):void {
			Actuate.tween(spriteScreen, 0.6, { alpha:0, scaleX:0.01, scaleY:0.01 } ).onComplete(function():void {
				spriteScreen.visible = false;
			});
		}
		private function closeScreen2(spriteScreen:Sprite):void {
			
				//spriteScreen.alpha = 0;
				spriteScreen.visible = false;
				
			
		}		
		public function openScreen(spriteScreen:Sprite):void {
			spriteScreen.scaleX = 0.01;
			spriteScreen.scaleY = 0.01;
			spriteScreen.alpha = 0;
			spriteScreen.visible = true;
			Actuate.tween(spriteScreen, 0.6, { alpha:1, scaleX:1, scaleY:1 } );
		}

		
		public function createUI():void {
			addChild(layerUI);
			// prepare message label
			//messageLabel.scrollRect = 
			messageLabel.width = stage.stageWidth;
			layerUI.addChild(messageLabel);
			messageLabel.x = 0;
			messageLabel.y = stage.stageHeight - messageLabel.height - 17;
			
			setMessageTextValue(" teste de texto");
			
			// prepare option buttons
			layerUI.addChild(optionButtons);
			optionButtons.filters = [SHADOW_FILTER];
			optionButtons.x = stage.stageWidth - margin - optionButtons.width;
			optionButtons.y = stage.stageHeight - margin - optionButtons.height;			
			makeButton(optionButtons.btTutorial);
			addTooltip(optionButtons.btTutorial, "Tutorial")
			makeButton(optionButtons.btReset);
			addTooltip(optionButtons.btReset, "Reset")
			makeButton(optionButtons.btOrientacoes);
			addTooltip(optionButtons.btOrientacoes, "Orientações");
			
			makeButton(optionButtons.btCreditos);
			addTooltip(optionButtons.btCreditos, "Créditos");
			
		}
		
		private function addTooltip(spr:Sprite, tx:String) {
			new ToolTip(spr, tx);
		}
		
		private function makeButton(spr:Sprite):void {
			spr.buttonMode = true;
			spr.mouseChildren = false;
			spr.mouseEnabled = true;
			spr.scaleX = 1;
			spr.scaleY = 1;
			spr.addEventListener(MouseEvent.MOUSE_OVER, highlightButton);
			spr.addEventListener(MouseEvent.MOUSE_OUT, unHighlightButton);
		}
		
		private function unHighlightButton(e:MouseEvent):void 
		{
			Actuate.tween(e.target, 0.4, { scaleX:1.0, scaleY:1.0 } );
		}
		
		private function highlightButton(e:MouseEvent):void 
		{
			Actuate.tween(e.target, 0.4, {scaleX:1.2, scaleY:1.2 });
		}
		
		public function bindMenuButtons():void {
			// exibir mensagem quando passar mouse nos botoes do menu
			
			// mandar reset pros AI.observers.onResetClick e onTutorialClick
			optionButtons.btTutorial.addEventListener(MouseEvent.CLICK, ai.onTutorialClick);
			optionButtons.btReset.addEventListener(MouseEvent.CLICK, ai.onResetClick);
		}
		
		
		
		
		public function setMessageTextValue(tx:String):void {
			messageLabel.texto.text = tx;
		}
		
		public function setMessageTextVisible(value:Boolean):void {
			Actuate.tween(optionButtons, 0.8, { y:(value?this.height:0)});
		}
		
		public function setOptionsMenuVisible(value:Boolean):void {
			Actuate.tween(optionButtons, 0.8, { alpha:(value?(this.height - messageLabel.height):this.height)});
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{			
			if (child is AIObserver) {
				ai.addObserver(AIObserver(child));
			}
			var c:DisplayObject =  super.addChild(child);
			setChildIndex(layerUI, numChildren - 1);
			return c;
		}
		
		public function get messageLabel():TextoExplicativo 
		{
			return _messageLabel;
		}
		
		public function set messageLabel(value:TextoExplicativo):void 
		{
			_messageLabel = value;
		}
		
		public function get optionButtons():MenuBotoes 
		{
			return _optionButtons;
		}
		
		public function set optionButtons(value:MenuBotoes):void 
		{
			_optionButtons = value;
		}

	}

}