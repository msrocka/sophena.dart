// just a small script to generate some JSON bindings for the Sophena model.
// We do not use a general code generator for the JSON bindings to be able
// to tune them by hand.
void main() {
  var type = 'HeatNet';
  var superType = 'AbstractEntity';
  var modelType = null; // check _modelType!

  var fieldText = '''
@Column(name = "net_length")
	public double length;

	@Column(name = "supply_temperature")
	public double supplyTemperature;

	@Column(name = "return_temperature")
	public double returnTemperature;

	@Column(name = "simultaneity_factor")
	public double simultaneityFactor;

	@Column(name = "smoothing_factor")
	public double smoothingFactor;

	@Column(name = "max_load")
	public Double maxLoad;

	@OneToOne
	@JoinColumn(name = "f_buffer_tank")
	public BufferTank bufferTank;

	@Column(name = "buffer_tank_volume")
	public double bufferTankVolume;

	@Column(name = "max_buffer_load_temperature")
	public double maxBufferLoadTemperature;

	@Column(name = "lower_buffer_load_temperature")
	public Double lowerBufferLoadTemperature;

	@Column(name = "buffer_loss")
	public double bufferLoss;

	@Embedded
	public ProductCosts bufferTankCosts;

	@Column(name = "power_loss")
	public double powerLoss;

	@Column(name = "with_interruption")
	public boolean withInterruption;

	@Column(name = "interruption_start")
	public String interruptionStart;

	@Column(name = "interruption_end")
	public String interruptionEnd;

	@JoinColumn(name = "f_heat_net")
	@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
	public final List<HeatNetPipe> pipes = new ArrayList<>();

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
      print("      $name = null; // TODO e.g. jsonObj|jsonList(json['$name'], (obj) => ?);");
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
