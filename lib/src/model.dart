import 'datapack.dart';
import 'enums.dart';

/// An abstract entity is basically just a thing that can be stored in a
/// Sophena database or data package.
abstract class AbstractEntity {
  String id;

  AbstractEntity();

  /// Creates an instance from the given [json] object.
  ///
  /// It is strongly intended that sub-classes extend this constructor by adding
  /// the sub-class specific fields from the json object. If a data [pack] is
  /// given, referenced root entities will be created from the respective
  /// content of the data pack.
  AbstractEntity.fromJson(Map<String, dynamic> json, {DataPack pack}) {
    id = json['id'];
  }

  /// Creates a map object with primitives that can be converted to json.
  ///
  /// If a data [pack] is given, referenced root entities will be also converted
  /// and written to the data pack during the conversion.
  Map<String, dynamic> toJson({DataPack pack}) {
    Map<String, dynamic> json = {};
    json['id'] = id;
    json['@type'] = this.runtimeType.toString();
    return json;
  }
}

/// A root entity is a stand-alone entity with a name and description.
///
/// Typically root entities can be referenced from multiple other entities and
/// are stored in separate files in a data pack.
abstract class RootEntity extends AbstractEntity {
  String name;
  String description;

  RootEntity();

  RootEntity.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    name = json['name'];
    description = json['description'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (name != null) {
      json['name'] = name;
    }
    if (description != null) {
      json['description'] = description;
    }
    return json;
  }

  /// Save the entity to the given data pack.
  void save(DataPack pack) {
    if (pack == null) {
      return;
    }
    var json = toJson(pack: pack);
    pack.put(_modelType(this), json);
  }
}

ModelType _modelType<T extends RootEntity>(T e) {
  if (e is Manufacturer) return ModelType.MANUFACTURER;
  if (e is ProductGroup) return ModelType.PRODUCT_GROUP;
  if (e is BufferTank) return ModelType.BUFFER;
  if (e is BuildingState) return ModelType.BUILDING_STATE;
  if (e is Fuel) return ModelType.FUEL;
  if (e is LoadProfile) return ModelType.LOAD_PROFILE;
  if (e is TransferStation) return ModelType.TRANSFER_STATION;
  if (e is Consumer) return ModelType.CONSUMER;
  // TODO: other model types
  return null;
}

Map<String, dynamic> _toRef<T extends RootEntity>(T e, DataPack pack) {
  if (e == null || e.id == null) {
    return null;
  }
  var ref = {'id': e.id, '@type': e.runtimeType.toString(), 'name': e.name};
  ModelType type = _modelType(e);
  if (pack == null || pack.contains(type, e.id)) {
    return ref;
  }
  e.save(pack);
  return ref;
}

/// Instances of this class are entities that are located in the base data. Base
/// data sets are provided by the application but can also be created and
/// modified by the user. The data that are provided by the application cannot
/// be changed by a normal user. This is indicated by the [isProtected]
/// property.
abstract class BaseDataEntity extends RootEntity {
  /// If a data set is protected it cannot be modified by a user of the
  /// application.
  bool isProtected;

  BaseDataEntity();

  BaseDataEntity.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    isProtected = json['isProtected'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    json['isProtected'] = isProtected;
    return json;
  }
}

class Manufacturer extends BaseDataEntity {
  String address;
  String url;

  Manufacturer();

  Manufacturer.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    address = json['address'];
    url = json['url'];
  }

  factory Manufacturer.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.MANUFACTURER, id);
    if (json == null) {
      return null;
    }
    return new Manufacturer.fromJson(json, pack: pack);
  }

  factory Manufacturer._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
    return new Manufacturer.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (address != null) {
      json['address'] = address;
    }
    if (url != null) {
      json['url'] = url;
    }
    return json;
  }
}

class ProductGroup extends BaseDataEntity {
  ProductType type;
  int index;

  /// Default usage duration of this product group given in years.
  int duration;

  /// Default fraction (%) of the investment that is used for repair.
  double repair;

  /// Default fraction (%) of the investment that is used for maintenance.
  double maintenance;

  /// Default amount of hours that are used for operation in one year.
  double operation;

  ProductGroup();

  ProductGroup.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    type = getProductType(json['type']);
    index = json['index'];
    duration = json['duration'];
    repair = json['repair'];
    maintenance = json['maintenance'];
    operation = json['operation'];
  }

  factory ProductGroup.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.PRODUCT_GROUP, id);
    if (json == null) {
      return null;
    }
    return new ProductGroup.fromJson(json, pack: pack);
  }

  factory ProductGroup._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
    return new ProductGroup.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (type != null) {
      json['type'] = type.toString().split('\.')[1];
    }
    if (index != null) {
      json['index'] = index;
    }
    if (duration != null) {
      json['duration'] = duration;
    }
    if (repair != null) {
      json['repair'] = repair;
    }
    if (maintenance != null) {
      json['maintenance'] = maintenance;
    }
    if (operation != null) {
      json['operation'] = operation;
    }
    return json;
  }
}

abstract class AbstractProduct extends BaseDataEntity {
  double purchasePrice;
  String url;
  Manufacturer manufacturer;
  ProductType type;
  ProductGroup group;

  AbstractProduct();

  AbstractProduct.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    purchasePrice = json['purchasePrice'];
    url = json['url'];
    manufacturer = new Manufacturer._fromRef(json['manufacturer'], pack);
    if (json['type'] != null) {
      type = getProductType(json['type']);
    }
    group = new ProductGroup._fromRef(json['group'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (purchasePrice != null) {
      json['purchasePrice'] = purchasePrice;
    }
    if (url != null) {
      json['url'] = url;
    }
    if (manufacturer != null) {
      json['manufacturer'] = _toRef(manufacturer, pack);
    }
    if (type != null) {
      json['type'] = type.toString().split('\.')[1];
    }
    if (group != null) {
      json['group'] = group.toJson();
    }
    return json;
  }
}

class Fuel extends BaseDataEntity {
  /// The standard unit of the fuel (e.g. L, m3, kg).
  String unit;

  /// The calorific value in kWh per 1 standard unit.
  double calorificValue;

  /// Only for wood fuels: density in kg per solid cubic meter.
  double density;

  FuelGroup group;

  /// Gramme CO2 emissions per kWh fuel energy.
  double co2Emissions;

  double primaryEnergyFactor;

  Fuel();

  Fuel.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    unit = json['unit'];
    calorificValue = json['calorificValue'];
    density = json['density'];
    if (json['group'] != null) {
      group = getFuelGroup(json['group']);
    }
    co2Emissions = json['co2Emissions'];
    primaryEnergyFactor = json['primaryEnergyFactor'];
  }

  factory Fuel.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.FUEL, id);
    if (json == null) {
      return null;
    }
    return new Fuel.fromJson(json, pack: pack);
  }

  factory Fuel._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
    return new Fuel.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (unit != null) {
      json['unit'] = unit;
    }
    if (calorificValue != null) {
      json['calorificValue'] = calorificValue;
    }
    if (density != null) {
      json['density'] = density;
    }
    if (group != null) {
      json['group'] = group.toString().split('\.')[1];
    }
    if (co2Emissions != null) {
      json['co2Emissions'] = co2Emissions;
    }
    if (primaryEnergyFactor != null) {
      json['primaryEnergyFactor'] = primaryEnergyFactor;
    }
    return json;
  }

  bool isWood() => group == FuelGroup.WOOD;
}

class BufferTank extends AbstractProduct {
  double volume;
  double diameter;
  double height;
  double insulationThickness;

  BufferTank();

  BufferTank.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    volume = json['volume'];
    diameter = json['diameter'];
    height = json['height'];
    insulationThickness = json['insulationThickness'];
  }

  factory BufferTank.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.BUFFER, id);
    if (json == null) {
      return null;
    }
    return new BufferTank.fromJson(json, pack: pack);
  }

  factory BufferTank._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
    return new BufferTank.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (volume != null) {
      json['volume'] = volume;
    }
    if (diameter != null) {
      json['diameter'] = diameter;
    }
    if (height != null) {
      json['height'] = height;
    }
    if (insulationThickness != null) {
      json['insulationThickness'] = insulationThickness;
    }
    return json;
  }
}

class BuildingState extends BaseDataEntity {
  int index;
  bool isDefault;
  BuildingType type;
  double heatingLimit;
  double antifreezingTemperature;
  double waterFraction;
  int loadHours;

  BuildingState();

  BuildingState.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    index = json['index'];
    isDefault = json['isDefault'];
    if (json['type'] != null) {
      type = getBuildingType(json['type']);
    }
    heatingLimit = json['heatingLimit'];
    antifreezingTemperature = json['antifreezingTemperature'];
    waterFraction = json['waterFraction'];
    loadHours = json['loadHours'];
  }

  factory BuildingState.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.BUILDING_STATE, id);
    if (json == null) {
      return null;
    }
    return new BuildingState.fromJson(json, pack: pack);
  }

  factory BuildingState._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
    return new BuildingState.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (index != null) {
      json['index'] = index;
    }
    if (isDefault != null) {
      json['isDefault'] = isDefault;
    }
    if (type != null) {
      json['type'] = type.toString().split('\.')[1];
    }
    if (heatingLimit != null) {
      json['heatingLimit'] = heatingLimit;
    }
    if (antifreezingTemperature != null) {
      json['antifreezingTemperature'] = antifreezingTemperature;
    }
    if (waterFraction != null) {
      json['waterFraction'] = waterFraction;
    }
    if (loadHours != null) {
      json['loadHours'] = loadHours;
    }
    return json;
  }
}

class FuelConsumption extends AbstractEntity {
  Fuel fuel;
  double amount;
  double utilisationRate;
  WoodAmountType woodAmountType;
  double waterContent;

  FuelConsumption();

  FuelConsumption.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    fuel = new Fuel._fromRef(json['fuel'], pack);
    amount = json['amount'];
    utilisationRate = json['utilisationRate'];
    if (json['woodAmountType'] != null) {
      woodAmountType = getWoodAmountType(json['woodAmountType']);
    }
    waterContent = json['waterContent'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (fuel != null) {
      json['fuel'] = _toRef(fuel, pack);
    }
    if (amount != null) {
      json['amount'] = amount;
    }
    if (utilisationRate != null) {
      json['utilisationRate'] = utilisationRate;
    }
    if (woodAmountType != null) {
      json['woodAmountType'] = woodAmountType.toString().split('\.')[1];
    }
    if (waterContent != null) {
      json['waterContent'] = waterContent;
    }
    return json;
  }
}

class TimeInterval extends AbstractEntity {
  String start;
  String end;
  String description;

  TimeInterval();

  TimeInterval.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    start = json['start'];
    end = json['end'];
    description = json['description'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (start != null) {
      json['start'] = start;
    }
    if (end != null) {
      json['end'] = end;
    }
    if (description != null) {
      json['description'] = description;
    }
    return json;
  }
}

class LoadProfile extends RootEntity {
  List<double> dynamicData;
  List<double> staticData;

  LoadProfile();

  LoadProfile.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    dynamicData = json['dynamicData'];
    staticData = json['staticData'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    json['dynamicData'] = dynamicData;
    json['staticData'] = staticData;
    return json;
  }
}

class Location extends AbstractEntity {
  String name;
  String street;
  String zipCode;
  String city;
  double latitude;
  double longitude;

  Location();

  Location.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    name = json['name'];
    street = json['street'];
    zipCode = json['zipCode'];
    city = json['city'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (name != null) {
      json['name'] = name;
    }
    if (street != null) {
      json['street'] = street;
    }
    if (zipCode != null) {
      json['zipCode'] = zipCode;
    }
    if (city != null) {
      json['city'] = city;
    }
    if (latitude != null) {
      json['latitude'] = latitude;
    }
    if (longitude != null) {
      json['longitude'] = longitude;
    }
    return json;
  }
}

class TransferStation extends AbstractProduct {
  String buildingType;
  double outputCapacity;
  String stationType;
  String material;
  String waterHeating;
  String control;

  TransferStation();

  TransferStation.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    buildingType = json['buildingType'];
    outputCapacity = json['outputCapacity'];
    stationType = json['stationType'];
    material = json['material'];
    waterHeating = json['waterHeating'];
    control = json['control'];
  }

  factory TransferStation.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.TRANSFER_STATION, id);
    if (json == null) {
      return null;
    }
    return new TransferStation.fromJson(json, pack: pack);
  }

  factory TransferStation._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
    return new TransferStation.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (buildingType != null) {
      json['buildingType'] = buildingType;
    }
    if (outputCapacity != null) {
      json['outputCapacity'] = outputCapacity;
    }
    if (stationType != null) {
      json['stationType'] = stationType;
    }
    if (material != null) {
      json['material'] = material;
    }
    if (waterHeating != null) {
      json['waterHeating'] = waterHeating;
    }
    if (control != null) {
      json['control'] = control;
    }
    return json;
  }
}

class ProductCosts {
  double investment;
  int duration;
  double repair;
  double maintenance;
  double operation;

  ProductCosts();

  ProductCosts.fromJson(Map<String, dynamic> json) {
    investment = json['investment'];
    duration = json['duration'];
    repair = json['repair'];
    maintenance = json['maintenance'];
    operation = json['operation'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (investment != null) {
      json['investment'] = investment;
    }
    if (duration != null) {
      json['duration'] = duration;
    }
    if (repair != null) {
      json['repair'] = repair;
    }
    if (maintenance != null) {
      json['maintenance'] = maintenance;
    }
    if (operation != null) {
      json['operation'] = operation;
    }
    return json;
  }
}

class Consumer extends RootEntity {
  bool disabled;
  BuildingState buildingState;
  bool demandBased;
  double heatingLoad;
  double waterFraction;
  int loadHours;
  double heatingLimit;
  double floorSpace;
  List<FuelConsumption> fuelConsumptions;
  List<TimeInterval> interruptions;
  List<LoadProfile> loadProfiles;
  Location location;
  TransferStation transferStation;
  ProductCosts transferStationCosts;

  Consumer();

  Consumer.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    disabled = json['disabled'];
    if (json['buildingState'] != null) {
      buildingState = new BuildingState._fromRef(json['buildingState'], pack);
    }
    demandBased = json['demandBased'];
    heatingLoad = json['heatingLoad'];
    waterFraction = json['waterFraction'];
    loadHours = json['loadHours'];
    heatingLimit = json['heatingLimit'];
    floorSpace = json['floorSpace'];

    if (json['fuelConsumptions'] != null) {
      var refs = json['fuelConsumptions'] as List<Map<String, dynamic>>;
      fuelConsumptions = [];
      for (var ref in refs) {
        var e = new FuelConsumption.fromJson(ref, pack: pack);
        if (e != null) {
          fuelConsumptions.add(e);
        }
      }
    }

    if (json['interruptions'] != null) {
      var refs = json['interruptions'] as List<Map<String, dynamic>>;
      interruptions = [];
      for (var ref in refs) {
        var e = new TimeInterval.fromJson(ref, pack: pack);
        if (e != null) {
          interruptions.add(e);
        }
      }
    }

    if (json['loadProfiles'] != null) {
      var refs = json['loadProfiles'] as List<Map<String, dynamic>>;
      loadProfiles = [];
      for (var ref in refs) {
        var e = new LoadProfile.fromJson(ref, pack: pack);
        if (e != null) {
          loadProfiles.add(e);
        }
      }
    }

    if (json['location'] != null) {
      location = new Location.fromJson(json['location'], pack: pack);
    }

    if (json['transferStation'] != null) {
      transferStation =
          new TransferStation._fromRef(json['transferStation'], pack);
    }
    if (json['transferStationCosts'] != null) {
      transferStationCosts =
          new ProductCosts.fromJson(json['transferStationCosts']);
    }
  }

  factory Consumer.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) {
      return null;
    }
    var json = pack.get(ModelType.CONSUMER, id);
    if (json == null) {
      return null;
    }
    return new Consumer.fromJson(json, pack: pack);
  }

  factory Consumer._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) {
      return null;
    }
    return new Consumer.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    if (disabled != null) {
      json['disabled'] = null; // TODO convert disabled;
    }
    if (buildingState != null) {
      json['buildingState'] = null; // TODO convert buildingState;
    }
    if (demandBased != null) {
      json['demandBased'] = null; // TODO convert demandBased;
    }
    if (heatingLoad != null) {
      json['heatingLoad'] = heatingLoad;
    }
    if (waterFraction != null) {
      json['waterFraction'] = waterFraction;
    }
    if (loadHours != null) {
      json['loadHours'] = loadHours;
    }
    if (heatingLimit != null) {
      json['heatingLimit'] = heatingLimit;
    }
    if (floorSpace != null) {
      json['floorSpace'] = floorSpace;
    }
    if (fuelConsumptions != null) {
      json['fuelConsumptions'] = null; // TODO convert fuelConsumptions;
    }
    if (interruptions != null) {
      json['interruptions'] = null; // TODO convert interruptions;
    }
    if (loadProfiles != null) {
      json['loadProfiles'] = null; // TODO convert loadProfiles;
    }
    if (location != null) {
      json['location'] = null; // TODO convert location;
    }
    if (transferStation != null) {
      json['transferStation'] = null; // TODO convert transferStation;
    }
    if (transferStationCosts != null) {
      json['transferStationCosts'] = null; // TODO convert transferStationCosts;
    }
    return json;
  }
}
