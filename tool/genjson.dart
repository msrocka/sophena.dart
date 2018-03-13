// just a small script to generate some JSON bindings for the Sophena model.
// We do not use a general code generator for the JSON bindings to be able
// to tune them by hand.
void main() {
  var type = 'ProductCosts';
  var superType = null;
  var modelType = null; // check _modelType!

  var fieldText = '''
	/** The purchase price of the product in EUR. */
	@Column(name = "investment")
	public double investment;

	/** The usage duration of the product in years. */
	@Column(name = "duration")
	public int duration;

	/** Fraction [%] of the investment that is used for repair. */
	@Column(name = "repair")
	public double repair;

	/** Fraction [%] of the investment that is used for maintenance . */
	@Column(name = "maintenance")
	public double maintenance;

	/** Hours per year that are used for operation of the product. */
	@Column(name = "operation")
	public double operation;
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
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.$modelType, id);
    if (json == null) {
      return null;
    }
    return new $type.fromJson(json, pack: pack);
  }

  factory $type._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
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
  return ['string', 'double', 'int', 'bool'].contains(t);
}
