import 'dart:io';

const entity = r"""
abstract class Entity {
  String id = "";

  @override
  String toString() {
    return "${runtimeType}{id=$id}";
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      runtimeType == other.runtimeType ? id == (other as Entity).id : false;
}
""";

main() {
  var dir = Directory("../Sophena/sophena/src/sophena/model");
  for (var f in dir.listSync()) {
    if (!f.path.endsWith(".java")) {
      continue;
    }
  }

  var model = entity;

  print(dir.existsSync());
}
