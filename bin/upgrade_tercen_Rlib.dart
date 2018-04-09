import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as libpath;

main() async {
  List<Map> lib =
      JSON.decode(new File('library_0.0.1.json').readAsStringSync());

  for (var m in lib){
    await upgrade(m);
  }
}

String incrementVersion(String version) {
  var list = version.split('.').toList();
  list[list.length - 1] = '${int.parse(list.last) + 1}';
  return list.join('.');
}

Future upgrade(Map lib) async {
  var baseFolder = '/home/alex/dev/bitbucket/tercen/apps/operator/R';

  var operator_name = libpath
      .basenameWithoutExtension(Uri.parse(lib['url']['uri']).pathSegments.last);

  var version = lib['version'];

  print('version = ' + version);

  print('git = ' + operator_name);

  var op_folder = libpath.join(baseFolder, operator_name);

  print('op_folder = ' + op_folder);

  await run('rm', ['-rf', 'packrat'], workingDirectory: op_folder);
  await run('rm', ['-f', '.Rprofile'], workingDirectory: op_folder);
  await run('R',
      ['--vanilla', '-e', 'packrat::init(options=list(use.cache=TRUE))'],
      workingDirectory: op_folder);
  await run('git', ['add', '-A'], workingDirectory: op_folder);
  await run('git', ['commit', '-m', '"tercen lib upgrade"'],
      workingDirectory: op_folder);
  await run('git', ['tag', '-a', '${version}', '-m', '"++"'],
      workingDirectory: op_folder);
  await run('git', ['push'], workingDirectory: op_folder);
  await run('git', ['push', '--tags'], workingDirectory: op_folder);

//
//
//  rm -r packrat
//  rm .Rprofile
//
//  R --vanilla -e "packrat::init(options = list(use.cache = TRUE))"
//
//  git add -A && git commit -m "tercen lib upgrade" && git tag -a 0.1.0 -m "++" && git push && git push --tags
}

Future run(String executable, List<String> arguments,
    {String workingDirectory}) async {
  print('run --  in ${workingDirectory}');
  print('${executable} ${arguments}');
  var process = await Process
      .start(executable, arguments, runInShell: true , workingDirectory: workingDirectory);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  var exit = await process.exitCode;

//  if (exit != 0) throw '$executable failed -- $exit';
}
