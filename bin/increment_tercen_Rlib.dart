import 'dart:convert';
import 'dart:io';


main() async {
  var libFile = 'library_0.0.2.json';
  List<Map> lib =
  JSON.decode(new File(libFile).readAsStringSync());

  print(lib);

  lib.forEach((m) {
    m['version'] = incrementVersion(m['version']);
  });

  new File(libFile)
      .copySync('${new DateTime.now().toIso8601String()}_${libFile}.old');

  var json = new JsonEncoder.withIndent(' ');
  new File(libFile).writeAsStringSync(json.convert(lib));
}

String incrementVersion(String version) {
  var list = version.split('.').toList();
  list[list.length - 1] = '${int.parse(list.last) + 1}';
  return list.join('.');
}
