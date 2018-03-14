// just a small script to generate some JSON bindings for the Sophena model.
// We do not use a general code generator for the JSON bindings to be able
// to tune them by hand.
void main() {
  var type = 'Pipe';
  var superType = 'AbstractProduct';
  var modelType = 'PIPE'; // check _modelType!

  var fieldText = '''
@Column(name = "material")
	public String material;

	@Column(name = "pipe_type")
	public PipeType pipeType;

	@Column(name = "u_value")
	public double uValue;

	@Column(name = "inner_diameter")
	public double innerDiameter;

	@Column(name = "outer_diameter")
	public double outerDiameter;

	@Column(name = "total_diameter")
	public double totalDiameter;

	@Column(name = "delivery_type")
	public String deliveryType;

	@Column(name = "max_temperature")
	public Double maxTemperature;

	@Column(name = "max_pressure")
	public Double maxPressure;

  ''';

  List<String> fields = [];
  for (String fieldRow in fieldText.split('\n')) {
    String r = fieldRow.trim();
    if (r.startsWith('public final List')) {
      fields.add(r.split(' ').skip(2).take(2).join(' '));
    } else if (r.startsWith('public ')) {
      fields.add(r.substring(7, r.length - 1));
    }
  }

  print('class $type extends $superType {');
  for (var field in fields) {
    print('  ' + field + ';');
  }
  print('');
  print('  $type();');

  // from json
  print('');
  print(
      '  $type.fromJson(Map<String, dynamic> json, {DataPack pack}) : super.fromJson(json, pack: pack) {');
  for (var field in fields) {
    var type = field.split(' ')[0];
    var name = field.split(' ')[1];
    if (_primitive(type)) {
      print("    $name = json['$name'];");
    } else if (type.startsWith('List<')) {
      String typeVar = _typeVar(type);
      print("");
      print("    if (json['$name'] != null) {");
      print("      var refs = json['$name'] as List<Map<String, dynamic>>;");
      print("      $name = [];");
      print("      for (var ref in refs) {");
      print("         var e = new $typeVar.fromJson(ref, pack: pack);");
      print("         if (e != null) {");
      print("             $name.add(e);");
      print("         }");
      print("      }");
      print("    }");
      print("");
    } else {
      print("    if (json['$name'] != null) {");
      print("      $name = null; // TODO convert json['$name'];");
      print("    }");
    }
  }
  print('  }');

  // from pack
  if (modelType != null) {
    String fromPack = '''

  factory $type.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.$modelType, id);
    if (json == null) return null;
    return new $type.fromJson(json, pack: pack);
  }

  factory $type._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new $type.fromPack(ref['id'], pack);
  }
    ''';
    print(fromPack);
  }

  // to json
  print('');
  print('  @override');
  print('  Map<String, dynamic> toJson({DataPack pack}) {');
  print('    var json = super.toJson(pack: pack);');
  print('    var w = new JsonWriter(pack, json);');
  for (var field in fields) {
    var type = field.split(' ')[0];
    var name = field.split(' ')[1];
    if (_primitive(type)) {
      print("    w.val('$name', $name);");
    } else if (type.startsWith('List<')) {
      print("    w.list('$name', $name); || w.refList('$name', $name);");
    } else {
      print("    w.obj('$name', $name); || w.refObj('$name', $name); || w.enumer('$name', $name);");
    }
  }
  print('    return json;');
  print('  }');

  print('}');
}

bool _primitive(String type) {
  String t = type.toLowerCase();
  return ['string', 'double', 'int', 'bool', 'boolean'].contains(t);
}

String _typeVar(String type) {
  return type.split('<')[1].split('>')[0];
}
