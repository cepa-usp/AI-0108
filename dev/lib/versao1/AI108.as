package 
{
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import fl.events.ComponentEvent;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;

	
	public class AI108 extends Sprite
	{
		//--------------------------------------------------
		// Membros públicos (interface).
		//--------------------------------------------------
		
		/**
		 * Cria um novo objeto desta classe.
		 */
		public function AI108 ()
		{
			init();
		}
		
		/**
		 * Restaura a CONFIGURAÇÃO inicial (padrão).
		 */
		public function reset ()
		{
			
		}
		
		//--------------------------------------------------
		// Membros privados.
		//--------------------------------------------------
		
		private const VIEWPORT:Rectangle = new Rectangle(0, 0, 700, 600);
		
		private var graph:SimpleGraph;
		private var style1:DataStyle;
		private var tweenMenu:Tween;
		private var funcoes:Array;
		private var graphFunction:GraphFunction;
		private var areasMaximas:Array;
		private var areasMinimas:Array;
		private var pontoA:MovieClip;
		private var pontoB:MovieClip;
		private var funcaoAtual:int;
		private var pontoArraste:MovieClip;
		private var showMaximo:CheckBox;
		private var showMinimo:CheckBox;
		private var opcoes:ComboBox;
		private var integrais:Array;
		private var integral:Integral;
		private var pontosIniciais:Array;
		private var limitesGrafico:Array;
		private var somaMaximo:TextField;
		private var somaMinimo:TextField;
		private var showTotal:CheckBox;
		private var somaTotal:TextField;
		private var areaTotal:Sprite;
		
		/**
		 * @private
		 * Inicialização (CRIAÇÃO DE OBJETOS) independente do palco (stage).
		 */
		private function init () : void
		{
			scrollRect = VIEWPORT;
			
			if (stage) stageDependentInit();
			else addEventListener(Event.ADDED_TO_STAGE, stageDependentInit);

		}
		
		/**
		 * @private
		 * Inicialização (CRIAÇÃO DE OBJETOS) dependente do palco (stage).
		 */
		private function stageDependentInit (event:Event = null) : void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, stageDependentInit);
			
		
			
			addCheckComboBox();
			
			initFunctions();
			configGraph();
			addFunction();
			//configuraPontos();
			
			
			
			addListenersGerais();
		}
		
		private function addCheckComboBox():void
		{
			showMaximo = new CheckBox();
			showMaximo.label = "Soma superior";
			showMaximo.selected = true;			
			addChild(showMaximo);
			showMaximo.addEventListener(MouseEvent.CLICK, showHideBarrasMaximo);
			somaMaximo = new TextField();
			
			addChild(somaMaximo);
			somaMaximo.width += 60;
			somaMaximo.selectable = false;
			somaMaximo.defaultTextFormat = new TextFormat("arial", 12, 0x0000FF);
			somaMaximo.text = "100.00";
			somaMaximo.height = 18;
			
			showMinimo = new CheckBox();
			showMinimo.label = "Soma inferior";
			showMinimo.selected = true;
			addChild(showMinimo);
			showMinimo.addEventListener(MouseEvent.CLICK, showHideBarrasMinimo);
			
			somaMinimo = new TextField();
			addChild(somaMinimo);
			somaMinimo.width += 40;
			somaMinimo.selectable = false;
			somaMinimo.defaultTextFormat = new TextFormat("arial", 12, 0xFF0000);
			somaMinimo.text = "100.00";
			somaMinimo.multiline = false;
			somaMinimo.height = 18;
			
			
			showTotal = new CheckBox();
			showTotal.label = "área";
			showTotal.selected = false;
			addChild(showTotal);
			showTotal.addEventListener(MouseEvent.CLICK, showHideTotal);
			
			somaTotal = new TextField();
			addChild(somaTotal);
			somaTotal.selectable = false;
			somaTotal.defaultTextFormat = new TextFormat("arial", 12, 0xCC6600);
			somaTotal.text = "100.00";
			
			integral = new Integral();
			addChild(integral);
			integral.addEventListener(MouseEvent.MOUSE_OVER, onIntegralMouseOver)
			integral.addEventListener(MouseEvent.MOUSE_OUT, onIntegralMouseOut)
			
			
			
			var listaFuncoes:Array = [ {label:"x^2", data:0 },
									   {label:"sen(x) + 2", data:1 },
									   {label:"e^x", data:2 }];
			
			opcoes = new ComboBox();
			opcoes.dataProvider = new DataProvider(listaFuncoes);
			
			addChild(opcoes);
			opcoes.addEventListener(Event.CHANGE, addFunction);
			
			showMaximo.x = 305;// 350;
			showMaximo.width += 40;
			showMaximo.y = 510;
			
			somaMaximo.x = 305;
			somaMaximo.y = 450;
			
			showMinimo.x = 30;
			showMinimo.width += 40;
			showMinimo.y = 510;
			
			somaMinimo.x = 30;
			somaMinimo.y = 452;
			
			showTotal.x = 130;//200;
			showTotal.y = 510;
			
			
			somaTotal.x = showTotal.x + 45;
			somaTotal.y = showTotal.y;
			somaTotal.visible = false;
			
			integral.x = showTotal.x + 70;
			integral.y = 465;
			
			opcoes.x = 470;
			opcoes.y = 450;
		}
		
		private function onIntegralMouseOut(e:MouseEvent):void 
		{
			somaTotal.visible = false;
		}
		
		private function onIntegralMouseOver(e:MouseEvent):void 
		{
			somaTotal.visible = true;
		}
		
		private function showHideBarrasMinimo(e:MouseEvent):void 
		{
			if (showMinimo.selected) {
				//showMinimo.selected = false;
				for (var i:int = 0; i < areasMinimas.length; i++) 
				{
					areasMinimas[i].visible = true;
				}
			}else {
				//showMinimo.selected = true;
				for (i = 0; i < areasMinimas.length; i++) 
				{
					areasMinimas[i].visible = false;
				}
			}
		}
		
		private function showHideBarrasMaximo(e:MouseEvent):void 
		{
			if (showMaximo.selected) {
				//showMaximo.selected = false;
				for (var i:int = 0; i < areasMaximas.length; i++) 
				{
					areasMaximas[i].visible = true;
				}
			}else {
				//showMaximo.selected = true;
				for (i = 0; i < areasMaximas.length; i++) 
				{
					areasMaximas[i].visible = false;
				}
			}
		}
		
		private function showHideTotal(e:MouseEvent):void 
		{
			if (showTotal.selected) {
				areaTotal.visible = true;
			}else {
				areaTotal.visible = false;
			}
		}
		
		private function initFunctions():void
		{
			funcoes = [function(x:Number):Number { return Math.pow(x, 2) },
					   function(x:Number):Number { return Math.sin(x) + 2 },
					   function(x:Number):Number { return Math.exp(x) } ];
					   
			integrais = [function(x:Number):Number { return Math.pow(x, 3)/3 },
					     function(x:Number):Number { return - Math.cos(x) + 2 * x },
					     function(x:Number):Number { return Math.exp(x) } ];
						 
			pontosIniciais = [new Point(2, 4), new Point(2, 4), new Point(2, 3)]; //Coordenadas iniciais dos pontos A (.x) e B(.x) no gráfico
			
			limitesGrafico = [new Point(5, 25), new Point(5, 5), new Point(4, 60)];
		}
		
		private function configGraph():void
		{
			var xMin:Number = -10.5;
			var xMax:Number = 10;
			var largura:Number = 580;
			var yMin:Number = 0;
			var yMax:Number = 10;
			var altura:Number = 400;
			
			if (graph != null) 
			{
				removeChild(graph);
				graph == null;
			}
			
			graph = new SimpleGraph(xMin, xMax, largura, yMin, yMax, altura);
			//graph.setTicksDistance(SimpleGraph.AXIS_X, 1);
			//graph.setSubticksDistance(SimpleGraph.AXIS_X, 1);
			graph.setTickAlignment(SimpleGraph.AXIS_X, "TICKS_CENTER")
			//graph.setTicksDistance(SimpleGraph.AXIS_Y, 0.5);
			//graph.setSubticksDistance(SimpleGraph.AXIS_Y, 1);
			graph.grid = false;
			
			graph.x = 30;
			graph.y = 15;
			
			graph.resolution = 1;
			
			this.addChild(graph);
			
			style1 = new DataStyle();
			style1.color = 0x000000;
			style1.stroke = 2;
			style1.alpha = 1;
			
			graphFunction = new GraphFunction(0, 20, function ():Number {return 0 } );
			
			graph.addFunction(graphFunction, style1);
		}
		
		private function addFunction(e:Event = null):void
		{
			if (e != null) {
				funcaoAtual = opcoes.selectedItem.data;
			}
			else funcaoAtual = 0;
			
			if (areaTotal != null){
				areaTotal.visible = false;
				showTotal.selected = false;
				
				showMinimo.selected = true;
				showMaximo.selected = true;
				showHideBarrasMaximo(null);
				showHideBarrasMinimo(null);
			}
			
			graphFunction.f = funcoes[funcaoAtual];
			
			redefineLimitesGráfico();
			graph.draw();
			
			configuraPontos();
			configuraAreas();
			
			atualizaSomaAreas();
			atualizaTextFields();
		}
		
		private function redefineLimitesGráfico():void
		{
			graph.xmax = limitesGrafico[funcaoAtual].x;
			graph.xmin = -0.5;
			
			graph.ymax = limitesGrafico[funcaoAtual].y;
			graph.ymin =  - limitesGrafico[funcaoAtual].y / 10;
			//graph.ymin = 0;
		}
		
		private function configuraPontos():void
		{
			var t:TextField;
			
			if (pontoA == null)
			{
				pontoA = new PontoArraste();
				
				t = new TextField();				
				t.defaultTextFormat = new TextFormat("arial", 12);
				t.text = "A";
				t.height = t.textHeight+4;
				t.x = -3;
				t.y = 24;
				pontoA.addChild(t);
				pontoA.nome.text = "A";
				pontoA.mouseChildren = false;
				pontoA.nome.visible = false;
				pontoA.addEventListener(MouseEvent.MOUSE_OVER, onPontoOver);
				pontoA.addEventListener(MouseEvent.MOUSE_OUT, onPontoOut);
				
				pontoB = new PontoArraste();
				
				
				t = new TextField();		
				t.defaultTextFormat = new TextFormat("arial", 12);
				t.text = "B";
				t.height = t.textHeight+4;
				t.x = -3;
				t.y = 24;
				pontoB.addChild(t);
				pontoB.nome.text = "B";
				pontoB.mouseChildren = false;
				pontoB.nome.visible = false;
				pontoB.addEventListener(MouseEvent.MOUSE_OVER, onPontoOver);
				pontoB.addEventListener(MouseEvent.MOUSE_OUT, onPontoOut);
				
				
				addChild(pontoA);
				addChild(pontoB);
				
				pontoA.addEventListener(MouseEvent.MOUSE_DOWN, initArrastePonto);
				pontoB.addEventListener(MouseEvent.MOUSE_DOWN, initArrastePonto);
			}
			
			pontoA.x = graph.x2pixel(pontosIniciais[funcaoAtual].x) + graph.x;
			pontoA.y = graph.y2pixel(0) + graph.y;
			
			pontoB.x = graph.x2pixel(pontosIniciais[funcaoAtual].y) + graph.x;
			pontoB.y = graph.y2pixel(0) + graph.y;
			
			dx.x = pontoA.x + (pontoB.x - pontoA.x) / 8;
			dx.y = pontoA.y;
		}
		
		private function onPontoOut(e:MouseEvent):void 
		{
			var p:PontoArraste = PontoArraste(e.target);
			p.nome.visible = false;
		}
		
		private function onPontoOver(e:MouseEvent):void 
		{
			var p:PontoArraste = PontoArraste(e.target);
			p.nome.visible = true;			
		}
		
		private function initArrastePonto(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stopArrastePonto);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, movingPonto);
			pontoArraste = e.target as MovieClip;
		}
		
		private function movingPonto(e:MouseEvent):void 
		{
			var posXgraph:Number = graph.pixel2x(stage.mouseX - graph.x);
			
			if (pontoArraste == pontoA) var posCalc:Number = Math.min(Math.max(40, stage.mouseX), pontoB.x - 20);
			else posCalc = Math.max(Math.min(600, stage.mouseX), pontoA.x + 20);
			
			var posSnap = graph.x2pixel(Math.round(graph.pixel2x(pontoArraste.x - graph.x) / 0.5) * 0.5) + graph.x;
			pontoArraste.x = Math.abs(posSnap - posCalc) < 5 ? posSnap: posCalc;
			
			dx.x = pontoA.x + (pontoB.x - pontoA.x) / 8;
			dx.y = pontoA.y;
			
			configuraAreas();
			atualizaSomaAreas();
			atualizaTextFields();
		}
		
		private function distanciaPontos():Number
		{
			return pontoB.x - pontoA.x;
		}
		
		private function stopArrastePonto(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopArrastePonto);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, movingPonto);
			pontoArraste = null;
		}
		
		private function configuraAreas():void
		{
			if (areasMaximas == null)
			{
				areasMaximas = [new AreaMaxima(), new AreaMaxima(), new AreaMaxima(), new AreaMaxima()];
				areasMinimas = [new AreaMinima(), new AreaMinima(), new AreaMinima(), new AreaMinima()];
				areaTotal = new Sprite();
				areaTotal.visible = false;
				
				for (var i:int = 0; i < areasMaximas.length; i++) 
				{
					addChild(areasMaximas[i]);
					addChild(areasMinimas[i]);
					setChildIndex(areasMinimas[i], 0);
					setChildIndex(areasMaximas[i], 0);
				}
				addChild(areaTotal);
				setChildIndex(areaTotal, 0);
			}
			
			var comprimentoBarras:Number = (pontoB.x - pontoA.x) / areasMaximas.length;
			
			for (i = 0; i < areasMaximas.length; i++) 
			{
				//Atribui a largura das barras
				areasMaximas[i].width = comprimentoBarras;
				areasMinimas[i].width = comprimentoBarras;
				
				//Atribui o posicionamento x e y das barras
				if (i == 0) {
					areasMaximas[i].x = graph.x2pixel(graph.pixel2x(pontoA.x - graph.x)) + graph.x;
					areasMaximas[i].y = graph.y2pixel(graph.pixel2y(pontoA.y - graph.y)) + graph.y;
					
				}else {
					areasMaximas[i].x = areasMaximas[i - 1].x + comprimentoBarras;
					areasMaximas[i].y = areasMaximas[i - 1].y;
				}
				
				areasMinimas[i].x = areasMaximas[i].x;
				areasMinimas[i].y = areasMaximas[i].y;
				
				//Atribui a altura das barras
				var valorYpontoA:Number = graph.y2pixel(funcoes[funcaoAtual](graph.pixel2x(areasMaximas[i].x - graph.x))) + graph.y;
				var valorYpontoAdeltaX:Number = graph.y2pixel(funcoes[funcaoAtual](graph.pixel2x(areasMaximas[i].x + comprimentoBarras - graph.x))) + graph.y;
				
				if (valorYpontoA < valorYpontoAdeltaX) {
					var alturaMinima:Number = Math.abs(pontoA.y - valorYpontoAdeltaX);
					var alturaMaxima:Number = Math.abs(pontoA.y - valorYpontoA);
				}else {
					alturaMinima = Math.abs(pontoA.y - valorYpontoA);
					alturaMaxima = Math.abs(pontoA.y - valorYpontoAdeltaX);
				}
				
				areasMaximas[i].height = alturaMaxima;
				areasMinimas[i].height = alturaMinima;
			}
			
			areaTotal.graphics.clear();
			
			var deltaX:Number = (xPontoB - xPontoA) / 20;
			
			areaTotal.graphics.lineStyle(1, 0xD88912, 1);
			areaTotal.graphics.beginFill(0xFFFF80);
			areaTotal.graphics.moveTo(pontoB.x, pontoB.y);
			areaTotal.graphics.lineTo(pontoA.x, pontoA.y);
			
			for (i = 0; i <= 20; i++) 
			{
				var posY:Number = funcoes[funcaoAtual](xPontoA + i * deltaX);
				var posYpalco:Number = graph.y2pixel(posY) + graph.y;
				areaTotal.graphics.lineTo(graph.x2pixel(xPontoA + (i * deltaX)) + graph.x, posYpalco);
			}
			
			areaTotal.graphics.lineTo(pontoB.x, pontoB.y);
		}
		
		private function atualizaSomaAreas():void
		{
			var base:Number = (xPontoB - xPontoA) / 4;
			
			var somaTotalMaxima:Number = 0;
			
			for (var i:int = 0; i < areasMaximas.length; i++) {
				//somaTotalMaxima += base * graph.pixel2y(areasMaximas[i].y - areasMaximas[i].height - graph.y);
				somaTotalMaxima += base * funcoes[funcaoAtual](xPontoA + (i + 1) * base);
			}
			somaMaximo.text = "" + somaTotalMaxima.toFixed(2).replace(".", ",");
			
			
			var somaTotalMinima:Number = 0;
			
			for (i = 0; i < areasMinimas.length; i++) {
				//somaTotalMinima += base * graph.pixel2y(areasMinimas[i].y - areasMinimas[i].height - graph.y);
				somaTotalMinima += base * funcoes[funcaoAtual](xPontoA + (i) * base);
			}
			somaMinimo.text = "" + somaTotalMinima.toFixed(2).replace(".", ",");
			
			
			var somaTotalTotal:Number = integrais[funcaoAtual](xPontoB) - integrais[funcaoAtual](xPontoA);
			somaTotal.text = " = " + somaTotalTotal.toFixed(2).replace(".", ",");
		}
		
		private function atualizaTextFields():void
		{
			pontoA.nome.text = "= " + xPontoA.toFixed(2).replace(".",",");
			pontoB.nome.text = "= " + xPontoB.toFixed(2).replace(".",",");
		}
		
		private function get xPontoA():Number
		{
			return graph.pixel2x(pontoA.x - graph.x);
		}
		
		private function get xPontoB():Number
		{
			return graph.pixel2x(pontoB.x - graph.x);
		}
		
		
		
		
		private function addListenersGerais():void
		{
			//menuBar.upDown.buttonMode = true;
			//menuBar.upDown.addEventListener(MouseEvent.CLICK, openCloseMenu);
			
			
			
			
			
			
			
			//showMaximo
			//showMinimo
			//opcoes
		}
		

	}
}

