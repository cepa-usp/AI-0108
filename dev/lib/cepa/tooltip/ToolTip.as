package cepa.tooltip
{	
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.accessibility.AccessibilityProperties;
	import flash.accessibility.Accessibility;
	import flash.text.TextFormat;
	
	/**
	 * TOOLTIP CEPA
	 * @author CEPA
	 * @version 1.0
	 */
	public class  ToolTip extends Sprite
	{
		public static const DISTANCE:int = 25; //	ESPAÇAMENTO DE BORDA PARA LIMITAR O TOOLTIP
		public static const DISTANCEY:int = 15; //	ESPAÇAMENTO DE BORDA PARA LIMITAR O TOOLTIP
		
		private var _text:String;
		private var _textSize:uint;
		private var _color:uint;
		private var _alpha:Number;
		private var _font:String;
		private var _boxSize:uint;
		private var _box:Sprite;
		private var _object:DisplayObject;// = new Object();
		private var _bottom:int; // 	LADO DE BAIXO DO QUADRADO (FORMA DO TOOLTIP)
		private var _right:int; //		LADO DIREITO DO QUADRADO (FORMA DO TOOLTIP)
		private var invert:Boolean = false; //	SE VERDADEIRO O TOOLTIP ESTÁ NA POSIÇÃO SUPERIOR ESQUERDA DO CURSOR. SE FALSO ESTÁ NA POSIÇÃO INFERIOR DIREITA.
		private var _visible:Boolean = false; //	VISIBILIDADE DO TOOLTIP
		private var _timeToShow:Number;
		private var _timeToHide:Number;
		private var textField:TextField;
		/**
		 * MÉTODO CONSTRUTOR
		 * 
		 * @param	object : OBJETO QUE ATIVA O APARECIMENTO DO TOOLTIP CASO O CURSOR REPOUSE SOBRE ELE
		 * @param	text : TEXTO QUE APARECE DENTRO DO TOOLTIP
		 * @param	textSize : TAMANHO DA FONTE DO 'text'
		 * @param	alpha : ALFA DO TOOLTIP
		 * @param	boxSize : LARGURA MÁXIMA DO TOOLTIP. QUANDO FOR ATINGIDA, O TEXTO TERÁ MULTIPLAS LINHAS
		 * @param	font : FONTE DO TEXTO
		 * @param	color : COR DA CAIXA DO TOOLTIP
		 */

		public function ToolTip (object:DisplayObject , text:String = "tooltip default", textSize:uint = 10, alpha:Number = 0.8, boxSize:uint = 100 , timeToShow:Number = 2, timeToHide:Number = 2, font:String = "verdana", color:uint = 0xffd647) 
		{
			_text = text;
			_textSize = textSize;
			_boxSize = boxSize;
			_color = color;
			_alpha = alpha;
			_font = font;
			_object = object;
			_timeToShow = timeToShow;
			_timeToHide = timeToHide;
			
			textField = new TextField();			
			
			draw();
			this.alpha = 0;
			this.visible = false;
			
			
			_object.addEventListener(MouseEvent.MOUSE_OVER, show);
			_object.addEventListener(MouseEvent.MOUSE_OUT, hide);
			
			//O TOOLTIP NÃO VAI APARECER QUANDO O USUÁRIO CLICAR NO BOTÃO
			_object.addEventListener(MouseEvent.MOUSE_DOWN, click);
			_object.accessibilityProperties =  new AccessibilityProperties();
			_object.accessibilityProperties.description = text;			
			
		}
		
		/**
		 * O texto do tooltip
		 */
		public function get text () : String
		{
			return _text;
		}
		
		/**
		 * @private
		 */
		public function set text (text:String) : void
		{
			_text = text;
			textField = new TextField();
			draw();
		}
		
		/**
		 * ESSA FUNÇÃO APENAS ESCONDE O TOOLTIP QUANDO O USUÁRIO CLICA NO BOTÃO
		 * @param	e : EVENTO DO MOUSE
		 */
		private function click(e:MouseEvent):void {
			hide(null);
		}
		
		/**
		 * MÉTODO QUE DESENHA O TOOLTIP
		 */
		private function draw():void 
		{
			var textFormat:TextFormat = new TextFormat();
			var shadow:DropShadowFilter = new DropShadowFilter(4, 45, 0x000000, 0.3);
			
			textFormat.font = _font;
			textFormat.size = _textSize;
			textFormat.color = 0x000000;
			
			textField.backgroundColor = 0xFF0000;
			textField.selectable = false;
			textField.defaultTextFormat = textFormat;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = _text;
			
			if (textField.textWidth + 5 < _boxSize) {
				textField.width = textField.textWidth + 5;
			}
			else {
				textField.width = _boxSize;
			}
			
			textField.wordWrap = true;
			
			if (_box != null) removeChild(_box);
			_box = new Sprite();
			
			_box.graphics.beginFill(_color, 1);
			//_box.graphics.drawRoundRect(0, 0, textField.width, textField.height, 10, 10);
			_box.graphics.drawRect(0, 0, textField.width, textField.height);
			_box.graphics.endFill();
			
			textField.x = 0;
			textField.y = 0;
			
			_box.addChild(textField);
			addChild(_box);

			_box.filters = [shadow];
		}
		
		/**
		 * MÉTODO QUE TORNA O TOOLTIP VISÍVEL
		 * @param	e : EVENTO DO MOUSE
		 */
		private function show (e:MouseEvent) : void
		{
			DisplayObject(_object).stage.addChild(this);
			this.visible = true;
			_visible = true;
			moving(null);
			visible = true;
			calcPosition();
			Actuate.tween(this, 0.7 , { alpha:_alpha } );
			//_alphaTween = new Tween(this, "alpha", Strong.easeIn, 0, _alpha, _timeToShow, true);
			_object.addEventListener(MouseEvent.MOUSE_MOVE, moving);
		}
		
		/**
		 * MÉTODO QUE TORNA O TOOLTIP INVISÍVEL
		 * @param	e : EVENTO DO MOUSE
		 */
		private function hide (e:MouseEvent) : void
		{
			_visible = false;

			Actuate.tween(this, 0.7, { alpha:0 } );
			//_alphaTween = new Tween(this, "alpha", Strong.easeOut, this.alpha, 0, _timeToHide, true);
			//_alphaTween.addEventListener(TweenEvent.MOTION_FINISH, function (e:TweenEvent) : void {
				visible = _visible;
				this.visible = false;
			//});
			_object.removeEventListener(MouseEvent.MOUSE_MOVE, moving);	
		}
		
		/**
		 * MÉTODO QUE MOVE O TOOLTIP DE ACORDO COM O MOVIMENTO DO CURSOR
		 * @param	e : EVENTO DO MOUSE
		 */
		private function moving (e:MouseEvent) : void
		{
			if (!invert) {
				x = stage.mouseX + DISTANCE;
				y = stage.mouseY;
			}
			else {
				this.x = stage.mouseX - this.width - DISTANCE;
				this.y = stage.mouseY - this.height;
			}
			
			calcPosition();
		}
		
		/**
		 * MÉTODO QUE CALCULA OS LIMITES DE DESLOCAMENTO DO TOOLTIP, CRIANDO UMA BORDA COM AS DIMENSÕES DO PALCO
		 * MENOS UM ESPAÇAMENTO 'DISTANCE'. O BOOLEANO 'invert' PODE SER ALTERADO CASO O TOOLTIP ESTEJA MUITO 
		 * PRÓXIMO DO CANTO INFERIOR DIREITO DO PALCO.
		 */
		private function calcPosition () : void
		{
			_bottom = this.y + this.height + DISTANCE;
			_right = this.x + this.width + DISTANCE;
			
			if (_right > stage.stageWidth && !invert) {
				this.x = stage.mouseX - this.width - DISTANCE;
			}
			
			if (_bottom > stage.stageHeight && !invert) {
				this.y = stage.stageHeight - this.height;
			}
			
			if (_right > stage.stageWidth && _bottom > stage.stageHeight && !invert) invert = true;
			if(invert && _right < (stage.stageWidth - 150) && _bottom < (stage.stageHeight - 150)) invert = false;
		}
		
	}
	
}