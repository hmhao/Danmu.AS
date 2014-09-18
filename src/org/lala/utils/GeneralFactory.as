package org.lala.utils {
	
	public class GeneralFactory extends Object {
		private var pool:Array;
		private var cls:Class = null;
		private var step:int = 0;
		
		public function GeneralFactory(cls:Class, num:int = 0, step:int = 10) {
			this.pool = [];
			this.cls = cls;
			this.step = step;
			if (this.step < 10) {
				this.step = 10;
			}
			this.addNObjects(num);
		}
		
		public function getObject():Object {
			if (this.pool.length > 0) {
				return this.pool.pop();
			}
			this.addStep();
			return this.pool.pop();
		}
		
		public function putObject(obj:Object):void {
			this.pool.push(obj);
		}
		
		private function addStep():void {
			this.addNObjects(this.step);
		}
		
		private function addNObjects(num:uint):void {
			for (var i:uint = 0, len:uint = this.pool.length; i < num; i++ ) {
				this.pool[i + len] = new this.cls();
			}
		}
	}
}
