import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';

Future<void> main() async {
  var github = GitHub(auth: findAuthenticationFromEnvironment());

  // var repos = await github.repositories.listRepositories().toList();

  // var repos =
  //     await github.repositories.listOrganizationRepositories('tercen').toList();
  //
  // print(repos.map((e) => e.fullName).toList());

  var operator = {
    "kind": "ROperator",
    "name": "Standard dev",
    "description": "Caculates standard deviation",
    "tags": ["simple statistics"],
    "authors": ["tercen"],
    "urls": [
      {"kind": "Url", "uri": "https://github.com/tercen/sd_operator"}
    ],
    "url": {"kind": "Url", "uri": "https://github.com/tercen/sd_operator.git"},
    "version": "0.9.0"
  };

  var repo = await github.repositories
      .getRepository(RepositorySlug('tercen', 'sd_operator'));

  var release = await github.repositories.getLatestRelease(repo.slug());

  print('release ${release.toJson()}');
  var kinds = <String>['ROperator', 'ShinyOperator', 'DockerOperator'];
  var fileToKinds = <String, String>{
    'ROperator': 'main.R',
    'DockerOperator': 'Dockerfile',
    'ShinyOperator': 'server.R'
  };
  RepositoryContents operatorFile;
  String kind;

  operatorFile = await github.repositories
      .getContents(repo.slug(), 'operator.json', ref: release.tagName);

  var operatorJson = json.decode(utf8.decode(
      base64.decode(LineSplitter().convert(operatorFile.file.content).join())));

  kind = kinds.firstWhere((element) => element == operatorJson['kind'],
      orElse: () => null);

  if (kind == null) {
    for (var entry in fileToKinds.entries) {
      RepositoryContents file;
      try {
        file = await github.repositories
            .getContents(repo.slug(), entry.value, ref: release.tagName);
      } on GitHubError catch (e) {
        if (e.message != 'Not found') {
          rethrow;
        }
      }

      if (file != null) {
        kind = entry.key;
        break;
      }
    }
  }

  if (kind == null) {
    throw 'bad.operator.kind -- ${repo.fullName} ${release.tagName}';
  }

  print('operatorJson ${operatorJson}');

  if (kind == 'ROperator'){


  }

  operator = {
    "kind": "ROperator",
    "name": "Standard dev",
    "description": "Caculates standard deviation",
    "tags": ["simple statistics"],
    "authors": ["tercen"],
    "urls": [
      {"kind": "Url", "uri": "https://github.com/tercen/sd_operator"}
    ],
    "url": {"kind": "Url", "uri": "https://github.com/tercen/sd_operator.git"},
    "version": "0.9.0"
  };

  exit(0);
}
