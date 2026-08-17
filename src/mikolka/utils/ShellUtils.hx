package mikolka.utils;

import haxe.Rest;
import haxe.extern.EitherType;
#if js
import js.Syntax;
#end

class ShellUtils {
	public inline static function shellPath(value:String) {
		return '"$value"';
	}
	/**
		Enumerate every element in an array. 
	**/
	public inline static function forEach<T>(root:EitherType<Rest<T>,Array<T>>,callback:T->Void) {
		#if js
		Syntax.code("{0}.forEach({1})",root,callback);
		#else
		for(x in root){
			callback(x);
		}
		#end
	}
	public inline static function mapInto<A,B>(root:Array<A>,callback:A->B):Array<B> {
		#if js
		return Syntax.code("{0}.map({1})",root,callback);
		#else
		return root.map(callback);
		#end
	}
}