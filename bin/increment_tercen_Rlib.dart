import 'dart:convert';
import 'dart:io';


main() async {
  List<Map> lib =
  JSON.decode(new File('library_0.0.1.json').readAsStringSync());

  print(lib);

  lib.forEach((m) {
    m['version'] = incrementVersion(m['version']);
  });

  new File('library_0.0.1.json')
      .copySync('${new DateTime.now().toIso8601String()}_library_0.0.1.json');

  var json = new JsonEncoder.withIndent(' ');
  new File('library_0.0.1.json').writeAsStringSync(json.convert(lib));
}

String incrementVersion(String version) {
  var list = version.split('.').toList();
  list[list.length - 1] = '${int.parse(list.last) + 1}';
  return list.join('.');
}
