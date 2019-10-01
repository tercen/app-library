import 'dart:convert';
import 'dart:io';


main() async {
  var libFile = 'library_0.0.3.json';
  List lib =
  json.decode(new File(libFile).readAsStringSync());

  print(lib);

  lib.forEach((m) {
    m['version'] = incrementVersion(m['version']);
  });

  new File(libFile)
      .copySync('${new DateTime.now().toIso8601String()}_${libFile}.old');

  var jsonEnc = new JsonEncoder.withIndent(' ');
  new File(libFile).writeAsStringSync(jsonEnc.convert(lib));
}

String incrementVersion(String version) {
  var list = version.split('.').toList();
  if (list.length >= 2) {
    list[list.length - 2] = '${int.parse(list[list.length - 2]) + 1}';
    list[list.length - 1] = '0';
  } else {
    list[list.length - 1] = '${int.parse(list.last) + 1}';
  }

  return list.join('.');
}
