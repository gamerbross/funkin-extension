package mikolka.utils;

class JsonUtils {
    public static function mergeWithJson(target:Dynamic,source:Dynamic,?ignoreFields:Array<String>):Dynamic{
		if(ignoreFields == null) ignoreFields = [];
		var fillInFields = Reflect.fields(target).filter(s -> !ignoreFields.contains(s));

		if(source == null) return target;
		for (field in Reflect.fields(source)){
			if(fillInFields.contains(field)) Reflect.setField(target,field,Reflect.field(source,field));
			else if (!ignoreFields.contains(field)) trace('Class doesn\'t contain field field $field');
		}
		return target;
	}
}