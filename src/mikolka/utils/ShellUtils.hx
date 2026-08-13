package mikolka.utils;

class ShellUtils {
	public inline static function shellPath(value:String) {
		return '"$value"';
	}
}