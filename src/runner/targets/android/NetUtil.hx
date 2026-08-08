package runner.targets.android;

import js.node.Os;

class NetUtil {
  public static function getLocalIPs():Array<String> {
    var result:Array<String> = [];

    var ifaces:Dynamic = Os.networkInterfaces();
    for (name in Reflect.fields(ifaces)) {
      var entries:Array<Dynamic> = cast Reflect.field(ifaces, name);

      for (entry in entries) {
        // typical fields: family, address, internal
        var family:String = entry.family;
        var address:String = entry.address;
        var internal:Bool = entry.internal;

        // keep IPv4, skip internal/loopback
        if (family == "IPv4" && !internal && address != null) {
          result.push(address);
        }
      }
    }

    return result;
  }

  public static function getFirstLocalIP():Null<String> {
    var ips = getLocalIPs();
    return ips.length > 0 ? ips[0] : null;
  }
}
