package  {
	
	public class hiScoreClass {
		
		private var initials:String;
		private var score:int;
		
		public function hiScoreClass(ini:String="", scr:int=0) {
			initials = ini;
			score = scr;
		}
		public function get accessInitial():String 
		{ 
			return initials; 
		} 
		public function set accessInitial(setValue:String):void 
		{ 
			initials = setValue; 
		}
		public function get accessScore():int
		{
			return score;
		}
		public function set accessScore(setValue:int):void
		{
			score = setValue;
		}
		
	}
	
}
