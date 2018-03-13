// just a small script to generate some JSON bindings for the Sophena model.
// We do not use a general code generator for the JSON bindings to be able
// to tune them by hand.
void main() {
  var type = 'ProductCosts';
  var superType = null;
  var modelType = null; // check _modelType!

  var fieldText = '''
@Column(name = "is_disabled")
	public boolean disabled;

	@OneToOne
	@JoinColumn(name = "f_building_state")
	public BuildingState buildingState;

	@Column(name = "demand_based")
	public boolean demandBased;

	@Column(name = "heating_load")
	public double heatingLoad;

	@Column(name = "water_fraction")
	public double waterFraction;

	@Column(name = "load_hours")
	public int loadHours;

	@Column(name = "heating_limit")
	public double heatingLimit;

	@Column(name = "floor_space")
	public double floorSpace;

	@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
	@JoinColumn(name = "f_consumer")
	public final List<FuelConsumption> fuelConsumptions = new ArrayList<>();

	@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
	@JoinColumn(name = "f_owner")
	public final List<TimeInterval> interruptions = new ArrayList<>();

	@OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
	@JoinColumn(name = "f_consumer")
	public final List<LoadProfile> loadProfiles = new ArrayList<>();

	@OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
	@JoinColumn(name = "f_location")
	public Location location;

	@OneToOne
	@JoinColumn(name = "f_transfer_station")
	public TransferStation transferStation;

	@Embedded
	@AttributeOverrides({
			@AttributeOverride(name = "investment",
					column = @Column(name = "transfer_station_investment")),
			@AttributeOverride(name = "duration",
					column = @Column(name = "transfer_station_duration")),
			@AttributeOverride(name = "repair",
					column = @Column(name = "transfer_station_repair")),
			@AttributeOverride(name = "maintenance",
					column = @Column(name = "transfer_station_maintenance")),
			@AttributeOverride(name = "operation",
					column = @Column(name = "transfer_station_operation")) })
	public ProductCosts transferStationCosts;
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
  return ['string', 'double', 'int', 'bool', 'boolean'].contains(t);
}

String _typeVar(String type) {
  return type.split('<')[1].split('>')[0];
}
