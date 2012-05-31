package cepa.ai 
{
	
	/**
	 * ...
	 * @author Arthur Tofani
	 */
	public interface AIObserver 
	{
		function onResetClick():void;
		function onScormFetch():void;
		function onScormSave():void;
		function onTutorialClick():void;
	}
	
}