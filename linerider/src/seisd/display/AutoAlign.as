package seisd.display 
{
	
	/*
	 * Vamoss
	 * implementada a integração com o IDisplayAlignable
	 * incorporando acesso direto as propriedades de alinhamento dos objetos
	 */
	
	/*
	 * based on cicron@naver.com (2008.10.17)
	 */
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import seisd.utils.ArrayUtils;
	
	public class AutoAlign 
	{
		
		protected static var alignList:Vector.<Align> = new Vector.<Align>();
		
		public function AutoAlign() 
		{	
			
		}
		
		/**
		 * Adiciona o alvo no AutoAlign
		 * @param	target
		 * @param	vars
		 */
		/*
		 * 
			1. Stage Mode Setup
			- scaleMode = 'noScale' / align = 'TOP_LEFT'
			2. Set Stage Object
			- import ks.AutoAlign; // import 
			- AutoAlign.setStage(stage); // stage Object //
			3. New Align Object
			- Relative Alignment
			* AutoAlign.to( Object, { x:0.5, y:0.5 } ); // relative alignment
			: axis X to center (50%) / axis Y to Center (50%)
			* AutoAlign.to( Object, { x:[1, 960], y:[1, 640] } ); // relative alignment with limited area
			: axis X to right ( 100% & out of 960px ) / axis y to bottom ( 100% & out of 640 )
			- Absolute Aligment
			* AutoAlign.to( Object, { left:100, top:100 } );
			: x: 100, y: 100
			* AutoAlign.to( Object, { right:100, bottom:30 } );
			: x: stagewidth -100, y: stageheight-30
			* AutoAlign.to( Object, { right:[100,400], bottom:[100,400] } );
			: x: stagewidth -400, limit : 100 , y: stageheight -400, limit: 100
			4. Delete Object's Aligning
			- AutoAlign.del(Object);
			: delete object's align action
		 *	---------------
		 * 
		 * 
		 * 
		 * 
		 * 
		 * 
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * READ-ME
		 * 
		 * (para vamoss)
		 * LEIA E APAGUE 
		 * 
		 * funfou!!
		 * basicamente corrigi o singleton do movieclipbase que não adicionava o seu align no AutoAlign 
		 * troquei new Align(this, parent) por AutoAlign.add(this, parent)
		 * 
		 * criei um trace toString() doidera para o Align, facilitará um bocado novos traces heheh
		 * 
		 * fiz comentarios na funcao add()
		 * 
		 * atualizei a funcao has() e del() para um modo compacto estilo Actionscript 4G
		 * e acabei por integrar com a classe ArrayUtils
		 * 
		 * o resto deixo para vc se divertir =D
		 * 
		 * 
		 * 
		 * news: tive que por um Math.round() no xPercent do update
		 * há um comentário, depois pensamos juntos
		 * 
		 * 
		 * 
		 * 
		 */
		public static function add(target:*, alignTarget:DisplayObject, vars:Object = null):Align
		{
			//TODO incluir o verificador se o target já existe, se sim, ele apenas atualiza
			
			var align:Align = new Align(target, alignTarget, vars);
			alignList.push(align);
			
			//TODO pode remover?
			//align.target.addEventListener(Event.ADDED_TO_STAGE, targetAdded);
			//align.target.addEventListener(Event.REMOVED_FROM_STAGE, targetRemoved);
			
			//TODO pode ser um boolean?    
			if (align.alignTarget) AutoAlign.update(align.target);
			
			return align;
		}
		
		/**
		 * Retira o alvo do AutoAlign
		 * @param	target
		 */
		public static function del(target:DisplayObject):void
		{
			ArrayUtils.remove(target, alignList);
		}
		
		/**
		 * Verifica se o alvo já está no AutoAlign
		 * @param	target
		 * @return
		 */
		public static function has(target:DisplayObject):Boolean
		{
			return ArrayUtils.has(target, alignList);
		}
		
		/**
		 * Retorna um objeto Align baseado no alvo
		 * @param	target
		 * @return
		 */
		public static function getAlign(target:DisplayObject):Align
		{
			for (var i:int = 0; i < alignList.length; i++) 
			{
				if ( alignList[i].target == target ) {
					return alignList[i];
				}
			}
			return null;
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/**
		 * Atualiza o posicionamento de todos os elementos, ou apenas um alvo específico
		 * @param	target
		 */
		public static function update(target:* = null):void
		{
			var parentWidth = function ( target:*):Number {
				if (target.alignTarget is Stage) {
					return Stage(target.alignTarget).stageWidth;
				}else if (target.alignTarget is IDisplayAlignable && IDisplayAlignable(target.alignTarget).ww) {
					return IDisplayAlignable(target.alignTarget).ww;
				}else {
					return target.alignTarget.width;
				}
			}
			var parentHeight = function ( target:*):Number {
				if (target.alignTarget is Stage) {
					return Stage(target.alignTarget).stageHeight;
				}else if (target.alignTarget is IDisplayAlignable && IDisplayAlignable(target.alignTarget).hh) {
					return IDisplayAlignable(target.alignTarget).hh;
				}else {
					return target.alignTarget.height;
				}
			}
			var alignLeft = function ( target:*) {
				target.x = target.left;
			}
			var alignRight = function ( target:*) {
				var gox:Number = parentWidth(target) - target.right;
				if ( target.rightLimit ) {
					gox < target.rightLimit ? target.x = target.rightLimit : target.x = gox  ;
				} else {
					target.x = gox;
				}
			}
			var alignTop = function ( target:*) {
				target.y = target.top;
			}
			var alignBottom = function ( target:*) {
				var goy:Number = parentHeight(target) - target.bottom;
				if ( target.bottomLimit ) {
					goy < target.bottomLimit ? target.y = target.bottomLimit : target.y = goy ;
				} else {
					target.y = goy;
				}
			}
			var alignX = function ( target:*) {
				var gox:Number = parentWidth(target) * target.xPercent;
				
				//TODO pus algo de arrendondar o valor
				// no TweenMax, usa-se tipo roundProps:["xPercent"]
				gox = Math.round(gox);
				
				if ( target.leftLimit ) {
					gox < target.leftLimit ? target.x = target.leftLimit : target.x = gox ;
				} else {
					target.x = gox;
				}
			}
			var alignY = function ( target:*) {
				var goy:Number = parentHeight(target) * target.yPercent;
				if ( target.topLimit ) {
					goy < target.topLimit ? target.y  = target.topLimit : target.y = goy ;
				} else {
					target.y = goy;
				}
			}
			
			for ( var i = 0 ; i < alignList.length ; i ++ ) {
				var mc:Align = alignList[i];
				
				if (mc.alignTarget)
				{
					//realinha apenas o target quando setado, ou todos quando não setado
					if (!(target is IDisplayAlignable) || mc == target)
					{
						if ( !isNaN(mc.top) ) 		alignTop(mc);
						if ( !isNaN(mc.bottom) )	alignBottom(mc);
						if ( !isNaN(mc.left) ) 		alignLeft(mc);
						if ( !isNaN(mc.right) ) 	alignRight(mc);
						if ( !isNaN(mc.xPercent) ) 	alignX(mc) ;
						if ( !isNaN(mc.yPercent) ) 	alignY(mc);
					}
				}
			}
		}
		
		/**
		 * Added to stage
		 * @param	e
		 */
		private static function targetAdded(e:Event):void 
		{
			e.currentTarget.addEventListener(Event.RESIZE, AutoAlign.update);
		}
		
		/**
		 * Removed from stage
		 * @param	e
		 */
		private static function targetRemoved(e:Event):void 
		{
			e.currentTarget.removeEventListener(Event.RESIZE, AutoAlign.update);			
		}
	}
}