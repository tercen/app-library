import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as libpath;

main() async {
  var libFile = 'library_0.0.3.json';
  var baseFolder = '/home/alex/dev/bitbucket/tercen/apps/operator/R';
  var renvCacheDir =
      '/home/alex/dev/bitbucket/tercen/apps/operator/R/RENV_PATHS_CACHE/v4';

  if (!new Directory(renvCacheDir).existsSync()) {
    new Directory(renvCacheDir).createSync(recursive: true);
  }

  renvCacheDir =
      '/home/alex/dev/bitbucket/tercen/apps/operator/R/RENV_PATHS_CACHE';

  var lib = json.decode(new File(libFile).readAsStringSync());

  for (var m in lib) {
    await upgrade(m, baseFolder, renvCacheDir);
  }
}

String incrementVersion(String version) {
  var list = version.split('.').toList();
  list[list.length - 1] = '${int.parse(list.last) + 1}';
  return list.join('.');
}

var afterOp = false;

Future upgrade(Map lib, String baseFolder, packratCacheDir) async {
  var operator_name = libpath
      .basenameWithoutExtension(Uri.parse(lib['url']['uri']).pathSegments.last);

//  if (operator_name != 'rfImp_operator') return;

//  if (operator_name == 'shiny_operator2') {
//    afterOp = true;
//  }
//
//  if (!afterOp) return;

  var version = lib['version'];

  print('version = ' + version);

  print('git = ' + operator_name);

  var op_folder = libpath.join(baseFolder, operator_name);

  print('op_folder = ' + op_folder);

  if (!new Directory(op_folder).existsSync()) {
    print('clone operator ${operator_name}');
    await start('git', ['clone', 'git@github.com:tercen/${operator_name}.git'],
        workingDirectory: baseFolder);
  }

  if (!new Directory(op_folder).existsSync()) {
    throw 'failed to clone ${lib['url']['uri']}';
  }

  var tags = await gitTags(op_folder);

  if (tags.contains(version)) {
    print('version ${version} already exists for operator $operator_name ');
    return;
  }

  await start('rm', ['-rf', 'packrat'], workingDirectory: op_folder);
  await start('rm', ['-rf', 'renv'], workingDirectory: op_folder);

  await start('rm', ['-f', '.Rprofile'], workingDirectory: op_folder);
  await start('rm', ['-f', 'renv.lock'], workingDirectory: op_folder);

  await startR(['--vanilla', '-e', 'renv::init()'],
      workingDirectory: op_folder, packratCacheDir: packratCacheDir);

  await start('git', ['add', '-A'], workingDirectory: op_folder);
  await start('git', ['commit', '-m', '"tercen lib upgrade"'],
      workingDirectory: op_folder);
  await start('git', ['tag', '-a', '${version}', '-m', '"++"'],
      workingDirectory: op_folder);
  await start('git', ['push'], workingDirectory: op_folder);
  await start('git', ['push', '--tags'], workingDirectory: op_folder);

//
//
//  rm -r packrat
//  rm .Rprofile
//
//  R --vanilla -e "packrat::init(options = list(use.cache = TRUE))"
//
//  git add -A && git commit -m "tercen lib upgrade" && git tag -a 0.1.0 -m "++" && git push && git push --tags
}

Future start(String executable, List<String> arguments,
    {String workingDirectory}) async {
  print('start --  in ${workingDirectory}');
  print('${executable} ${arguments}');
  var process = await Process.start(executable, arguments,
      runInShell: true, workingDirectory: workingDirectory);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  var exit = await process.exitCode;

//  if (exit != 0) throw '$executable failed -- $exit';
}

Future startR(List<String> arguments,
    {String workingDirectory, String packratCacheDir}) async {
  print('startR --  in ${workingDirectory}');
  var args = [
    'run',
    '--rm',
    '-v',
    '${packratCacheDir}:${packratCacheDir}',
    '-v',
    '${workingDirectory}:${workingDirectory}',
    '-w',
    workingDirectory,
    '-u',
    'rstudio',
  ];

  if (packratCacheDir != null) {
    args
      ..addAll([
        '-e',
        'RENV_PATHS_CACHE=${packratCacheDir}',
      ]);
  }

  args..addAll(['tercen/tercen_studio:0.9.2.6', 'R'])..addAll(arguments);

  print('docker ${args.join(' ')}');

  var process = await Process.start('docker', args,
      runInShell: true, workingDirectory: workingDirectory);
//  var process = await Process.start('R', arguments,
//      runInShell: true, workingDirectory: workingDirectory);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  var exit = await process.exitCode;

  if (exit != 0) throw 'R failed -- $exit';
}

Future<ProcessResult> run(String executable, List<String> arguments,
    {String workingDirectory}) async {
  print('run --  in ${workingDirectory}');
  print('${executable} ${arguments}');
  return Process.run(executable, arguments,
      runInShell: true, workingDirectory: workingDirectory);
}

Future<String> gitTags(workingDirectory) async {
  var processResult =
      await run('git', ['tag'], workingDirectory: workingDirectory);

  print(processResult.stdout);

  return processResult.stdout;
}
