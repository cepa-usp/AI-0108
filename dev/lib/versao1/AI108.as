package 
{
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import com.eclecticdesignstudio.motion.Actuate;
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
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	
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
		private var areasMaximas:Sprite;
		private var areasMinimas:Sprite;
		public var pontoA:MovieClip;
		private var pontoB:MovieClip;
		private var funcaoAtual:int;
		private var pontoArraste:MovieClip;
		private var showMaximo:CheckBox;
		private var showMinimo:CheckBox;
		private var opcoes:ComboBox;
		private var qtAreas:ComboBox;
		private var integrais:Array;
		private var integral:Integral;
		private var pontosIniciais:Array;
		private var limitesGrafico:Array;
		private var somaMaximo:TextField;
		private var somaMinimo:TextField;
		private var mouseCoord:TextField = new TextField();
		private var showTotal:CheckBox;
		private var somaTotal:TextField;
		private var showCoords:Boolean = false;
		private var areaTotal:Sprite;
		private var timeToShow:Timer = new Timer(400, 1);
		private var nAreas:int;
		
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
			
		
			nAreas = 5; //Número de áreas inicial.
			
			areasMaximas = new Sprite();
			areasMinimas = new Sprite();
			areaTotal = new Sprite();
			addChild(areaTotal);
			addChild(areasMaximas);
			addChild(areasMinimas);
			
			addCheckComboBox();
			
			initFunctions();
			configGraph();
			addFunction();
			//configuraPontos();
			
			
			
			addListenersGerais();
			

			addChild(mouseCoord);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, updateMouseCoord);
			mouseCoord.alpha = 0;
			mouseCoord.selectable = false;
			
			updateMouseCoord(null);			
			timeToShow.addEventListener(TimerEvent.TIMER_COMPLETE, showMouseCoords);
			configuraAreas(3);

		}
		
		
		private function showMouseCoords(e:TimerEvent):void 
		{
			if (stage.mouseY > graph.height) return;
			if (stage.mouseX > graph.width) return;
			Actuate.tween(mouseCoord, 1, { alpha:1 } );
		}
		
		private function updateMouseCoord(e:MouseEvent):void 
		{
			if (mouseCoord.alpha != 0) Actuate.tween(mouseCoord, 0.8, { alpha:0 }, false );
			
			mouseCoord.text = "(" + graph.pixel2x(stage.mouseX - graph.x).toFixed(2) + " ," + graph.pixel2y(stage.mouseY - graph.y).toFixed(2) + ")";
			
			if (stage.mouseX + mouseCoord.textWidth > stage.stageWidth - 5) mouseCoord.x = stage.mouseX - mouseCoord.textWidth - 5;
			else mouseCoord.x = stage.mouseX;
			if (stage.mouseY - 20 < 5) mouseCoord.y = stage.mouseY + 22;
			else mouseCoord.y = stage.mouseY - 22;
			
			if (timeToShow.running) {
				timeToShow.stop();
				timeToShow.reset();
			}
			
			timeToShow.start();
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
									   {label:"e^x", data:2 } ];
									   
								   
			
			opcoes = new ComboBox();
			opcoes.dataProvider = new DataProvider(listaFuncoes);
			
			qtAreas = new ComboBox();
			qtAreas.dataProvider = new DataProvider([3, 5, 10, 20, 50, 100, 150, 200, 500]);
			
			
			addChild(opcoes);
			addChild(qtAreas);
			opcoes.addEventListener(Event.CHANGE, addFunction);
			qtAreas.addEventListener(Event.CHANGE, onAreaChange);			
			var linhaCheckboxesY:int = 486;
			
			showMaximo.x = 303;// 350;
			showMaximo.width += 40;
			showMaximo.y = linhaCheckboxesY;
			
			somaMaximo.x = 305;
			somaMaximo.y = 450;
			
			showMinimo.x = 30;
			showMinimo.width += 40;
			showMinimo.y = linhaCheckboxesY;
			
			somaMinimo.x = 90;
			somaMinimo.y = 452;
			
			
			showTotal.x = 180;//200;
			showTotal.y = linhaCheckboxesY;
			
			
			somaTotal.x = showTotal.x + 55;
			somaTotal.y = showTotal.y;
			somaTotal.visible = false;
			
			integral.x = 210;
			integral.y = 458;
			
			opcoes.x = 470;
			opcoes.y = 450;
			
			qtAreas.x = 470;
			qtAreas.y = 480;
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
				//for (var i:int = 0; i < areasMinimas.length; i++) 
				//{
					//areasMinimas[i].visible = true;
				//}
				areasMinimas.visible = true;
			}else {
				//showMinimo.selected = true;
				//for (i = 0; i < areasMinimas.length; i++) 
				//{
					//areasMinimas[i].visible = false;
				//}
				areasMinimas.visible = false;
			}
		}
		
		private function showHideBarrasMaximo(e:MouseEvent):void 
		{
			if (showMaximo.selected) {
				//showMaximo.selected = false;
				//for (var i:int = 0; i < areasMaximas.length; i++) 
				//{
					//areasMaximas[i].visible = true;
				//}
				areasMaximas.visible = true;
			}else {
				//showMaximo.selected = true;
				//for (i = 0; i < areasMaximas.length; i++) 
				//{
					//areasMaximas[i].visible = false;
				//}
				areasMaximas.visible = false;
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
			var largura:Number = 570;
			var yMin:Number = 0;
			var yMax:Number = 10;
			var altura:Number = 380;
			if (graph != null) 
			{
				removeChild(graph);
				graph == null;
			}
			
			graph = new SimpleGraph(xMin, xMax, largura, yMin, yMax, altura);
			
			graph.setAxesNameFormat(graph.getLabelsFormat());
			graph.setAxisName("AXIS_X", "x");
			graph.setAxisName("AXIS_Y", " y ");

			//graph.setTicksDistance(SimpleGraph.AXIS_X, 1);
			//graph.setSubticksDistance(SimpleGraph.AXIS_X, 1);
			graph.setTickAlignment(SimpleGraph.AXIS_X, "TICKS_CENTER")
			//graph.setTicksDistance(SimpleGraph.AXIS_Y, 0.5);
			//graph.setSubticksDistance(SimpleGraph.AXIS_Y, 1);
			graph.grid = false;
			
			graph.x = 20;
			graph.y = 40;
			
			graph.resolution = 1;
			
			this.addChild(graph);
			
			style1 = new DataStyle();
			style1.color = 0x000000;
			style1.stroke = 2;
			style1.alpha = 1;
			
			graphFunction = new GraphFunction(0, 20, function ():Number {return 0 } );
			
			graph.addFunction(graphFunction, style1);
			dx.visible = false;
			dx.addEventListener(MouseEvent.MOUSE_OVER, onDxOver);
			dx.addEventListener(MouseEvent.MOUSE_OUT, onDxOut);
			//dx.txt.visible = false;
		}
		
		private function onDxOver(e:MouseEvent):void 
		{
			dx.txt.visible = true;		
			//trace("ma oe")
		}
		private function onDxOut(e:MouseEvent):void 
		{
			dx.txt.visible = false;			
		}		
		
		private function onAreaChange(e:Event):void 
		{
			var q:int = qtAreas.selectedItem.data;
			configuraAreas(q);
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
			configuraAreas(nAreas);
			
			//atualizaSomaAreas();
			//atualizaTextFields();
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
				t.text = "a";
				t.height = t.textHeight+4;
				t.x = -3;
				t.y = 24;
				pontoA.addChild(t);
				pontoA.nome.text = "a";
				pontoA.mouseChildren = false;
				pontoA.nome.visible = false;
				pontoA.addEventListener(MouseEvent.MOUSE_OVER, onPontoOver);
				pontoA.addEventListener(MouseEvent.MOUSE_OUT, onPontoOut);
				
				pontoB = new PontoArraste();
				
				
				t = new TextField();		
				t.defaultTextFormat = new TextFormat("arial", 12);
				t.text = "b";
				t.height = t.textHeight+4;
				t.x = -3;
				t.y = 24;
				pontoB.addChild(t);
				pontoB.nome.text = "b";
				pontoB.mouseChildren = false;
				pontoB.nome.visible = false;
				pontoB.addEventListener(MouseEvent.MOUSE_OVER, onPontoOver);
				pontoB.addEventListener(MouseEvent.MOUSE_OUT, onPontoOut);
				
				
				addChild(pontoA);
				addChild(pontoB);
				
				pontoA.addEventListener(MouseEvent.MOUSE_DOWN, initArrastePonto);
				pontoB.addEventListener(MouseEvent.MOUSE_DOWN, initArrastePonto);
			}
			
			pontoA.x = graph.x2pixel(pontosIniciais[funcaoAtual].x) + graph.x -3;
			pontoA.y = graph.y2pixel(0) + graph.y;
			
			pontoB.x = graph.x2pixel(pontosIniciais[funcaoAtual].y) + graph.x -3;
			pontoB.y = graph.y2pixel(0) + graph.y;
			
			dx.x = pontoA.x + (pontoB.x - pontoA.x) / 8;
			dx.y = 200  //pontoA.y;
			
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
			dx.y = 200 //pontoA.y;
			
			
			configuraAreas(nAreas);
			//atualizaSomaAreas();
			//atualizaTextFields();
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
			configuraAreas(nAreas);
		}
		
		private function configuraAreas(nAreas:int):void
		{
			this.nAreas = nAreas;
			/*
			if (areasMaximas == null)
			{


				areasMaximas = [];
				areasMinimas = [];
				areaTotal = new Sprite();
				areaTotal.visible = false;
				
				for (var i:int = 0; i < nAreas; i++) 
				{
					areasMaximas.push(new AreaMaxima());
					areasMinimas.push(new AreaMinima());
					addChild(areasMaximas[i]);
					addChild(areasMinimas[i]);
					areasMaximas[i].visible = showMaximo.selected;
					areasMinimas[i].visible = showMinimo.selected;
					setChildIndex(areasMinimas[i], 0);
					setChildIndex(areasMaximas[i], 0);
				}
				addChild(areaTotal);
				setChildIndex(areaTotal, 0);
			}else if (nAreas != areasMaximas.length) {
				if (nAreas > areasMaximas.length) {
					for (var j:int = areasMaximas.length; j < nAreas; j++) 
					{
						areasMaximas.push(new AreaMaxima());
						areasMinimas.push(new AreaMinima());
						addChild(areasMaximas[j]);
						addChild(areasMinimas[j]);
						areasMaximas[j].visible = showMaximo.selected;
						areasMinimas[j].visible = showMinimo.selected;
						setChildIndex(areasMinimas[j], getChildIndex(areasMinimas[j - 1]));
						setChildIndex(areasMaximas[j], getChildIndex(areasMaximas[j - 1]));
					}
				}else {
					for (j = areasMaximas.length - 1; j > nAreas - 1; j--) 
					{
						removeChild(areasMaximas[j]);
						removeChild(areasMinimas[j]);
						areasMaximas.splice(j, 1);
						areasMinimas.splice(j, 1);
					}
				}
			}
			
			var comprimentoBarras:Number = (pontoB.x - pontoA.x) / nAreas;
			trace(comprimentoBarras);
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
			*/
			
			var largura:Number = (pontoB.x - pontoA.x) / nAreas;
			
			areasMaximas.graphics.clear();
			areasMaximas.graphics.lineStyle(1, 0x0000FF);
			areasMaximas.graphics.beginFill(0x0000FF, 0.2);
			
			areasMinimas.graphics.clear();
			areasMinimas.graphics.lineStyle(1, 0xEC0000);
			areasMinimas.graphics.beginFill(0xEC0000, 0.2);
			
			for (var i:int = 0; i < nAreas; i++) 
			{
				var yMin:Number = graph.y2pixel(funcoes[funcaoAtual](graph.pixel2x(pontoA.x + i * largura - graph.x))) + graph.y;
				var yMax:Number = graph.y2pixel(funcoes[funcaoAtual](graph.pixel2x(pontoA.x + i * largura + largura - graph.x))) + graph.y;
				
				if (yMin < yMax) {
					var aux:Number = yMin;
					yMin = yMax;
					yMax = aux;
				}
				areasMaximas.graphics.moveTo(pontoA.x + i * largura, pontoA.y);
				areasMaximas.graphics.lineTo(pontoA.x + i * largura, yMax);
				areasMaximas.graphics.lineTo(pontoA.x + (i + 1) * largura, yMax);
				areasMaximas.graphics.lineTo(pontoA.x + (i + 1) * largura, pontoA.y);
				areasMaximas.graphics.lineTo(pontoA.x + i * largura, pontoA.y);
				
				areasMinimas.graphics.moveTo(pontoA.x + i * largura, pontoA.y);
				areasMinimas.graphics.lineTo(pontoA.x + i * largura, yMin);
				areasMinimas.graphics.lineTo(pontoA.x + (i + 1) * largura, yMin);
				areasMinimas.graphics.lineTo(pontoA.x + (i + 1) * largura, pontoA.y);
				areasMinimas.graphics.lineTo(pontoA.x + i * largura, pontoA.y);
			}
			
			areaTotal.graphics.clear();
			
			var deltaX:Number = (xPontoB - xPontoA) / 20;
			dx.txt.text = "= " + deltaX.toFixed(5);
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
			
			atualizaSomaAreas();
			atualizaTextFields();
		}
		
		private function atualizaSomaAreas():void
		{
			var largura:Number = (xPontoB - xPontoA) / nAreas;
			
			var somaTotalMaxima:Number = 0;
			var somaTotalMinima:Number = 0;
			
			//for (var i:int = 0; i < areasMaximas.length; i++) {
			for (var i:int = 0; i < nAreas; i++) {
				var yMin:Number = funcoes[funcaoAtual](graph.pixel2x(pontoA.x - graph.x) + (i * largura));
				var yMax:Number = funcoes[funcaoAtual](graph.pixel2x(pontoA.x - graph.x) + ((i + 1) * largura));
				
				if (yMin > yMax) {
					var aux:Number = yMin;
					yMin = yMax;
					yMax = aux;
				}
				
				somaTotalMaxima += largura * yMax;
				somaTotalMinima += largura * yMin;
			}
			
			somaMaximo.text = "" + somaTotalMaxima.toFixed(2).replace(".", ",");
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

