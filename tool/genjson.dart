// just a small script to generate some JSON bindings for the Sophena model.
// We do not use a general code generator for the JSON bindings to be able
// to tune them by hand.
void main() {
  var type = 'AbstractProduct';
  var fields = [
    'double purchasePrice',
    'String url',
    'Manufacturer manufacturer',
    'ProductType type',
    'ProductGroup group',
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
    var type = field.split(' ')[0];
    var name = field.split(' ')[1];
    if (_primitive(type)) {
      print("    $name = json['$name'];");
    } else {
      print("    if (json['$name'] != null) {");
      print("      $name = null; // TODO convert json['$name'];");
      print("    }");
    }
  }
  print('  }');

  // to json
  print('');
  print('  @override');
  print('  Map<String, dynamic> toJson() {');
  print('    var json = super.toJson();');
  for (var field in fields) {
    var type = field.split(' ')[0];
    var name = field.split(' ')[1];
    print('    if ($name != null) {');
    if (_primitive(type)) {
      print("      json['$name'] = $name;");
    } else {
      print("      json['$name'] = null; // TODO convert $name;");
    }
    print('    }');
  }
  print('    return json;');
  print('  }');

  print('}');
}

bool _primitive(String type) {
  String t = type.toLowerCase();
  return ['string', 'double', 'int'].contains(t);
}
