package mikolka.utils;

class JsonUtils {
    public static function mergeWithJson(target:Dynamic,source:Dynamic,?ignoreFields:Array<String>):Dynamic{
		if(ignoreFields == null) ignoreFields = [];

		var fillInFields = Reflect.fields(target).filterInto(s -> !ignoreFields.contains(s));

		if(source == null) return target;
		Reflect.fields(source).forEach(field -> {
			if(fillInFields.contains(field)) Reflect.setField(target,field,Reflect.field(source,field));
			else if (!ignoreFields.contains(field)) trace('Class doesn\'t contain field field $field');
		});
		return target;
	}
}