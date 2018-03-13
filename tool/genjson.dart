// just a small script to generate some JSON bindings for the Sophena model.
// We do not use a general code generator for the JSON bindings to be able
// to tune them by hand.
void main() {
  var type = 'Manufacturer';
  var fields = [
    'String address',
    'String url',
  ];

  print('class $type extends ? {');
  for (var field in fields) {
    print('  ' + field + ';');
  }
  print('');
  print('  $type();');

  // from json
  print('');
  print('  $type.fromJson(Map<String, dynamic> json) : super.fromJson(json) {');
  for (var field in fields) {
    var name = field.split(' ')[1];
    print("    $name = json['$name'];");
  }
  print('  }');

  // to json
  print('');
  print('  @override');
  print('  Map<String, dynamic> toJson() {');
  print('    var json = super.toJson();');
  for (var field in fields) {
    var name = field.split(' ')[1];
    print("    json['$name'] = $name;");
  }
  print('    return json;');
  print('  }');

  print('}');
}
