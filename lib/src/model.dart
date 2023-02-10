import 'datapack.dart';
import 'enums.dart';
import 'json.dart';

/// An abstract entity is basically just a thing that can be stored in a
/// Sophena database or data package.
abstract class AbstractEntity {
  String? id;

  AbstractEntity();

  /// Creates an instance from the given [json] object.
  ///
  /// It is strongly intended that sub-classes extend this constructor by adding
  /// the sub-class specific fields from the json object. If a data [pack] is
  /// given, referenced root entities will be created from the respective
  /// content of the data pack.
  AbstractEntity.fromJson(Map<String, dynamic> json, {DataPack? pack}) {
    id = json['id'];
  }

  /// Creates a map object with primitives that can be converted to json.
  ///
  /// If a data [pack] is given, referenced root entities will be also converted
  /// and written to the data pack during the conversion.
  Map<String, dynamic> toJson({DataPack? pack}) {
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
  String? name;
  String? description;

  RootEntity();

  RootEntity.fromJson(Map<String, dynamic> json, {DataPack? pack})
      : super.fromJson(json, pack: pack) {
    name = json['name'];
    description = json['description'];
  }

  @override
  Map<String, dynamic> toJson({DataPack? pack}) {
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
  void save(DataPack? pack) {
    if (pack == null) {
      return;
    }
    var json = toJson(pack: pack);
    var mt = modelType(this);
    if (mt != null) {
      modelType(this);
    }
  }
}

/// Returns the model type of the given entity.
ModelType? modelType<T extends RootEntity>(T e) {
  if (e is Manufacturer) return ModelType.MANUFACTURER;
  if (e is ProductGroup) return ModelType.PRODUCT_GROUP;
  if (e is BufferTank) return ModelType.BUFFER;
  if (e is BuildingState) return ModelType.BUILDING_STATE;
  if (e is Fuel) return ModelType.FUEL;
  if (e is LoadProfile) return ModelType.LOAD_PROFILE;
  if (e is TransferStation) return ModelType.TRANSFER_STATION;
  if (e is Consumer) return ModelType.CONSUMER;
  if (e is FlueGasCleaning) return ModelType.FLUE_GAS_CLEANING;
  if (e is Pipe) return ModelType.PIPE;
  if (e is HeatRecovery) return ModelType.HEAT_RECOVERY;
  if (e is Boiler) return ModelType.BOILER;
  if (e is WeatherStation) return ModelType.WEATHER_STATION;
  if (e is Producer) return ModelType.PRODUCER;
  if (e is Product) return ModelType.PRODUCT;
  if (e is CostSettings) return ModelType.COST_SETTINGS;
  if (e is Project) return ModelType.PROJECT;
  return null;
}

/// Instances of this class are entities that are located in the base data. Base
/// data sets are provided by the application but can also be created and
/// modified by the user. The data that are provided by the application cannot
/// be changed by a normal user. This is indicated by the [isProtected]
/// property.
abstract class BaseDataEntity extends RootEntity {
  /// If a data set is protected it cannot be modified by a user of the
  /// application.
  bool isProtected = false;

  BaseDataEntity();

  BaseDataEntity.fromJson(Map<String, dynamic> json, {DataPack? pack})
      : super.fromJson(json, pack: pack) {
    isProtected = json['isProtected'];
  }

  @override
  Map<String, dynamic> toJson({DataPack? pack}) {
    var json = super.toJson(pack: pack);
    json['isProtected'] = isProtected;
    return json;
  }
}

class Manufacturer extends BaseDataEntity {
  String? address;
  String? url;

  Manufacturer();

  Manufacturer.fromJson(Map<String, dynamic> json, {DataPack? pack})
      : super.fromJson(json, pack: pack) {
    address = json['address'];
    url = json['url'];
  }

  factory Manufacturer.fromPack(String id, DataPack pack) {
    var json = pack.get(ModelType.MANUFACTURER, id);
    if (json == null) {
      return Manufacturer()..id = id;
    }
    return Manufacturer.fromJson(json, pack: pack);
  }

  factory Manufacturer._fromRef(Map<String, dynamic> ref, DataPack pack) {
    return new Manufacturer.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack? pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('address', address);
    w.val('url', url);
    return json;
  }
}

class ProductGroup extends BaseDataEntity {
  ProductType type;

  /// Product groups that contain heat producers must have a fuel group
  /// assigned.
  FuelGroup fuelGroup;

  /// This is just for ordering the groups in the user interface.
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
    fuelGroup = getFuelGroup(json['fuelGroup']);
    index = json['index'];
    duration = json['duration'];
    repair = json['repair'];
    maintenance = json['maintenance'];
    operation = json['operation'];
  }

  factory ProductGroup.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.PRODUCT_GROUP, id);
    if (json == null) return null;
    return new ProductGroup.fromJson(json, pack: pack);
  }

  factory ProductGroup._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new ProductGroup.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.enumer('type', type);
    w.enumer('fuelGroup', fuelGroup);
    w.val('index', index);
    w.val('duration', duration);
    w.val('repair', repair);
    w.val('maintenance', maintenance);
    w.val('operation', operation);
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
    var w = new JsonWriter(pack, json);
    w.val('purchasePrice', purchasePrice);
    w.val('url', url);
    w.refObj('manufacturer', manufacturer);
    w.enumer('type', type);
    w.refObj('group', group);
    return json;
  }
}

class Fuel extends BaseDataEntity {
  /// The standard unit of the fuel (e.g. L, m3, kg).
  String unit;

  /// The calorific value in kWh per 1 standard unit.
  double calorificValue;

  /// Density of a wood fuel in kg per solid cubic meter.
  ///
  /// This is only used for wood fuels in order to convert different quantity
  /// types into each other.
  double density;

  /// Each fuel belongs to a group with equal properties that can be used in the
  /// same heat producer.
  FuelGroup group;

  /// CO2 emissions in g/kWh.
  double co2Emissions;

  double primaryEnergyFactor;

  /// The ash content (in %) for wood based fuels.
  double ashContent;

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
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.FUEL, id);
    if (json == null) return null;
    return new Fuel.fromJson(json, pack: pack);
  }

  factory Fuel._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Fuel.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('unit', unit);
    w.val('calorificValue', calorificValue);
    w.val('density', density);
    w.enumer('group', group);
    w.val('co2Emissions', co2Emissions);
    w.val('primaryEnergyFactor', primaryEnergyFactor);
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
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.BUFFER, id);
    if (json == null) return null;
    return new BufferTank.fromJson(json, pack: pack);
  }

  factory BufferTank._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new BufferTank.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('volume', volume);
    w.val('diameter', diameter);
    w.val('height', height);
    w.val('insulationThickness', insulationThickness);
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
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.BUILDING_STATE, id);
    if (json == null) return null;
    return new BuildingState.fromJson(json, pack: pack);
  }

  factory BuildingState._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new BuildingState.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('index', index);
    w.val('isDefault', isDefault);
    w.enumer('type', type);
    w.val('heatingLimit', heatingLimit);
    w.val('antifreezingTemperature', antifreezingTemperature);
    w.val('waterFraction', waterFraction);
    w.val('loadHours', loadHours);
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
    var w = new JsonWriter(pack, json);
    w.refObj('fuel', fuel);
    w.val('amount', amount);
    w.val('utilisationRate', utilisationRate);
    w.enumer('woodAmountType', woodAmountType);
    w.val('waterContent', waterContent);
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
    var w = new JsonWriter(pack, json);
    w.val('start', start);
    w.val('end', end);
    w.val('description', description);
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
    var w = new JsonWriter(pack, json);
    w.val('name', name);
    w.val('street', street);
    w.val('zipCode', zipCode);
    w.val('city', city);
    w.val('latitude', latitude);
    w.val('longitude', longitude);
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
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.TRANSFER_STATION, id);
    if (json == null) return null;
    return new TransferStation.fromJson(json, pack: pack);
  }

  factory TransferStation._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new TransferStation.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('buildingType', buildingType);
    w.val('outputCapacity', outputCapacity);
    w.val('stationType', stationType);
    w.val('material', material);
    w.val('waterHeating', waterHeating);
    w.val('control', control);
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
    var w = new JsonWriter(null, json);
    w.val('investment', investment);
    w.val('duration', duration);
    w.val('repair', repair);
    w.val('maintenance', maintenance);
    w.val('operation', operation);
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
    demandBased = json['demandBased'];
    heatingLoad = json['heatingLoad'];
    waterFraction = json['waterFraction'];
    loadHours = json['loadHours'];
    heatingLimit = json['heatingLimit'];
    floorSpace = json['floorSpace'];

    fuelConsumptions = jsonEach(json['fuelConsumptions'],
        (ref) => new FuelConsumption.fromJson(ref, pack: pack));
    interruptions = jsonEach(json['interruptions'],
        (ref) => new TimeInterval.fromJson(ref, pack: pack));
    loadProfiles = jsonEach(json['loadProfiles'],
        (ref) => new LoadProfile.fromJson(ref, pack: pack));

    buildingState = jsonObj(
        json['buildingState'], (obj) => new BuildingState._fromRef(obj, pack));
    location = jsonObj(
        json['location'], (obj) => new Location.fromJson(obj, pack: pack));
    transferStation = jsonObj(json['transferStation'],
        (obj) => new TransferStation._fromRef(obj, pack));
    transferStationCosts = jsonObj(
        json['transferStationCosts'], (obj) => new ProductCosts.fromJson(obj));
  }

  factory Consumer.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.CONSUMER, id);
    if (json == null) return null;
    return new Consumer.fromJson(json, pack: pack);
  }

  factory Consumer._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Consumer.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('disabled', disabled);
    w.refObj('buildingState', name);
    w.val('demandBased', demandBased);
    w.val('heatingLoad', heatingLoad);
    w.val('waterFraction', waterFraction);
    w.val('loadHours', loadHours);
    w.val('heatingLimit', heatingLimit);
    w.val('floorSpace', floorSpace);
    w.list('fuelConsumptions', fuelConsumptions);
    w.list('interruptions', interruptions);
    w.list('loadProfiles', loadProfiles);
    w.obj('location', location);
    w.refObj('transferStation', name);
    w.obj('transferStationCosts', name);
    return json;
  }
}

class FlueGasCleaning extends AbstractProduct {
  String flueGasCleaningType;
  double maxVolumeFlow;
  String fuel;
  double maxProducerPower;
  double maxElectricityConsumption;
  String cleaningMethod;
  String cleaningType;
  double separationEfficiency;

  FlueGasCleaning();

  FlueGasCleaning.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    flueGasCleaningType = json['flueGasCleaningType'];
    maxVolumeFlow = json['maxVolumeFlow'];
    fuel = json['fuel'];
    maxProducerPower = json['maxProducerPower'];
    maxElectricityConsumption = json['maxElectricityConsumption'];
    cleaningMethod = json['cleaningMethod'];
    cleaningType = json['cleaningType'];
    separationEfficiency = json['separationEfficiency'];
  }

  factory FlueGasCleaning.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.FLUE_GAS_CLEANING, id);
    if (json == null) return null;
    return new FlueGasCleaning.fromJson(json, pack: pack);
  }

  factory FlueGasCleaning._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new FlueGasCleaning.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('flueGasCleaningType', flueGasCleaningType);
    w.val('maxVolumeFlow', maxVolumeFlow);
    w.val('fuel', fuel);
    w.val('maxProducerPower', maxProducerPower);
    w.val('maxElectricityConsumption', maxElectricityConsumption);
    w.val('cleaningMethod', cleaningMethod);
    w.val('cleaningType', cleaningType);
    w.val('separationEfficiency', separationEfficiency);
    return json;
  }
}

class FlueGasCleaningEntry extends AbstractEntity {
  FlueGasCleaning product;
  ProductCosts costs;

  FlueGasCleaningEntry();

  FlueGasCleaningEntry.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    product = jsonObj(
        json['product'], (obj) => new FlueGasCleaning._fromRef(obj, pack));
    costs = jsonObj(json['costs'], (obj) => new ProductCosts.fromJson(obj));
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.refObj('product', product);
    w.obj('costs', costs);
    return json;
  }
}

class FuelSpec {
  Fuel fuel;
  WoodAmountType woodAmountType;
  double waterContent;
  double pricePerUnit;
  double taxRate;

  FuelSpec();

  FuelSpec.fromJson(Map<String, dynamic> json, {DataPack pack}) {
    fuel = jsonObj(json['fuel'], (obj) => new Fuel._fromRef(obj, pack));
    if (json['woodAmountType'] != null) {
      woodAmountType = getWoodAmountType(json['woodAmountType']);
    }
    waterContent = json['waterContent'];
    pricePerUnit = json['pricePerUnit'];
    taxRate = json['taxRate'];
  }

  Map<String, dynamic> toJson({DataPack pack}) {
    Map<String, dynamic> json = {};
    var w = new JsonWriter(pack, json);
    w.refObj('fuel', fuel);
    w.enumer('woodAmountType', woodAmountType);
    w.val('waterContent', waterContent);
    w.val('pricePerUnit', pricePerUnit);
    w.val('taxRate', taxRate);
    return json;
  }
}

class Pipe extends AbstractProduct {
  String material;
  PipeType pipeType;
  double uValue;
  double innerDiameter;
  double outerDiameter;
  double totalDiameter;
  String deliveryType;
  double maxTemperature;
  double maxPressure;

  Pipe();

  Pipe.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    material = json['material'];
    if (json['pipeType'] != null) {
      pipeType = getPipeType(json['pipeType']);
    }
    uValue = json['uValue'];
    innerDiameter = json['innerDiameter'];
    outerDiameter = json['outerDiameter'];
    totalDiameter = json['totalDiameter'];
    deliveryType = json['deliveryType'];
    maxTemperature = json['maxTemperature'];
    maxPressure = json['maxPressure'];
  }

  factory Pipe.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.PIPE, id);
    if (json == null) return null;
    return new Pipe.fromJson(json, pack: pack);
  }

  factory Pipe._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Pipe.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('material', material);
    w.enumer('pipeType', pipeType);
    w.val('uValue', uValue);
    w.val('innerDiameter', innerDiameter);
    w.val('outerDiameter', outerDiameter);
    w.val('totalDiameter', totalDiameter);
    w.val('deliveryType', deliveryType);
    w.val('maxTemperature', maxTemperature);
    w.val('maxPressure', maxPressure);
    return json;
  }
}

/// This class represents the concrete use of a pipe in a heat net of a project.
class HeatNetPipe extends AbstractEntity {
  Pipe pipe;
  ProductCosts costs;
  String name;
  double length;
  double pricePerMeter;

  HeatNetPipe();

  HeatNetPipe.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    pipe = jsonObj(json['pipe'], (obj) => new Pipe._fromRef(obj, pack));
    costs = jsonObj(json['costs'], (obj) => new ProductCosts.fromJson(obj));
    name = json['name'];
    length = json['length'];
    pricePerMeter = json['pricePerMeter'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.refObj('pipe', pipe);
    w.obj('costs', costs);
    w.val('name', name);
    w.val('length', length);
    w.val('pricePerMeter', pricePerMeter);
    return json;
  }
}

class HeatNet extends AbstractEntity {
  double length;
  double supplyTemperature;
  double returnTemperature;
  double simultaneityFactor;
  double smoothingFactor;
  double maxLoad;
  BufferTank bufferTank;
  double bufferTankVolume;
  double maxBufferLoadTemperature;
  double lowerBufferLoadTemperature;
  double bufferLoss;
  ProductCosts bufferTankCosts;
  double powerLoss;
  bool withInterruption;
  String interruptionStart;
  String interruptionEnd;
  List<HeatNetPipe> pipes;

  HeatNet();

  HeatNet.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    length = json['length'];
    supplyTemperature = json['supplyTemperature'];
    returnTemperature = json['returnTemperature'];
    simultaneityFactor = json['simultaneityFactor'];
    smoothingFactor = json['smoothingFactor'];
    maxLoad = json['maxLoad'];
    bufferTank = jsonObj(
        json['bufferTank'], (obj) => new BufferTank._fromRef(obj, pack));
    bufferTankVolume = json['bufferTankVolume'];
    maxBufferLoadTemperature = json['maxBufferLoadTemperature'];
    lowerBufferLoadTemperature = json['lowerBufferLoadTemperature'];
    bufferLoss = json['bufferLoss'];
    bufferTankCosts = jsonObj(
        json['bufferTankCosts'], (obj) => new ProductCosts.fromJson(json));
    powerLoss = json['powerLoss'];
    withInterruption = json['withInterruption'];
    interruptionStart = json['interruptionStart'];
    interruptionEnd = json['interruptionEnd'];
    pipes = jsonEach(
        json['pipes'], (obj) => new HeatNetPipe.fromJson(obj, pack: pack));
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('length', length);
    w.val('supplyTemperature', supplyTemperature);
    w.val('returnTemperature', returnTemperature);
    w.val('simultaneityFactor', simultaneityFactor);
    w.val('smoothingFactor', smoothingFactor);
    w.val('maxLoad', maxLoad);
    w.refObj('bufferTank', bufferTank);
    w.val('bufferTankVolume', bufferTankVolume);
    w.val('maxBufferLoadTemperature', maxBufferLoadTemperature);
    w.val('lowerBufferLoadTemperature', lowerBufferLoadTemperature);
    w.val('bufferLoss', bufferLoss);
    w.obj('bufferTankCosts', bufferTankCosts);
    w.val('powerLoss', powerLoss);
    w.val('withInterruption', withInterruption);
    w.val('interruptionStart', interruptionStart);
    w.val('interruptionEnd', interruptionEnd);
    w.refList('pipes', pipes);
    return json;
  }
}

class HeatRecovery extends AbstractProduct {
  double power;
  String heatRecoveryType;
  String fuel;
  double producerPower;

  HeatRecovery();

  HeatRecovery.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    power = json['power'];
    heatRecoveryType = json['heatRecoveryType'];
    fuel = json['fuel'];
    producerPower = json['producerPower'];
  }

  factory HeatRecovery.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.HEAT_RECOVERY, id);
    if (json == null) return null;
    return new HeatRecovery.fromJson(json, pack: pack);
  }

  factory HeatRecovery._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new HeatRecovery.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('power', power);
    w.val('heatRecoveryType', heatRecoveryType);
    w.val('fuel', fuel);
    w.val('producerPower', producerPower);
    return json;
  }
}

class ProducerProfile extends AbstractEntity {
  List<double> minPower;
  List<double> maxPower;

  ProducerProfile();

  ProducerProfile.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    minPower = json['minPower'];
    maxPower = json['maxPower'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('minPower', minPower);
    w.val('maxPower', maxPower);
    return json;
  }
}

class Boiler extends AbstractProduct {
  double maxPower;
  double minPower;
  double efficiencyRate;
  bool isCoGenPlant;
  double maxPowerElectric;
  double minPowerElectric;
  double efficiencyRateElectric;

  Boiler();

  Boiler.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    maxPower = json['maxPower'];
    minPower = json['minPower'];
    efficiencyRate = json['efficiencyRate'];
    isCoGenPlant = json['isCoGenPlant'];
    maxPowerElectric = json['maxPowerElectric'];
    minPowerElectric = json['minPowerElectric'];
    efficiencyRateElectric = json['efficiencyRateElectric'];
  }

  factory Boiler.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.BOILER, id);
    if (json == null) return null;
    return new Boiler.fromJson(json, pack: pack);
  }

  factory Boiler._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Boiler.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('maxPower', maxPower);
    w.val('minPower', minPower);
    w.val('efficiencyRate', efficiencyRate);
    w.val('isCoGenPlant', isCoGenPlant);
    w.val('maxPowerElectric', maxPowerElectric);
    w.val('minPowerElectric', minPowerElectric);
    w.val('efficiencyRateElectric', efficiencyRateElectric);
    return json;
  }
}

class WeatherStation extends BaseDataEntity {
  double maxPower;
  double minPower;
  double efficiencyRate;
  bool isCoGenPlant;
  double maxPowerElectric;
  double minPowerElectric;
  double efficiencyRateElectric;

  WeatherStation();

  WeatherStation.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    maxPower = json['maxPower'];
    minPower = json['minPower'];
    efficiencyRate = json['efficiencyRate'];
    isCoGenPlant = json['isCoGenPlant'];
    maxPowerElectric = json['maxPowerElectric'];
    minPowerElectric = json['minPowerElectric'];
    efficiencyRateElectric = json['efficiencyRateElectric'];
  }

  factory WeatherStation.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.WEATHER_STATION, id);
    if (json == null) return null;
    return new WeatherStation.fromJson(json, pack: pack);
  }

  factory WeatherStation._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new WeatherStation.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('maxPower', maxPower);
    w.val('minPower', minPower);
    w.val('efficiencyRate', efficiencyRate);
    w.val('isCoGenPlant', isCoGenPlant);
    w.val('maxPowerElectric', maxPowerElectric);
    w.val('minPowerElectric', minPowerElectric);
    w.val('efficiencyRateElectric', efficiencyRateElectric);
    return json;
  }
}

class Producer extends RootEntity {
  bool disabled;
  int rank;
  ProductGroup productGroup;
  Boiler boiler;
  bool hasProfile;
  ProducerProfile profile;
  double profileMaxPower;
  ProducerFunction function;
  ProductCosts costs;
  FuelSpec fuelSpec;
  HeatRecovery heatRecovery;
  List<TimeInterval> interruptions;
  ProductCosts heatRecoveryCosts;
  double utilisationRate;

  Producer();

  Producer.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    disabled = json['disabled'];
    rank = json['rank'];
    productGroup = jsonObj(
        json['productGroup'], (obj) => new ProductGroup._fromRef(obj, pack));
    boiler = jsonObj(json['boiler'], (obj) => new Boiler._fromRef(obj, pack));
    hasProfile = json['hasProfile'];
    profile = jsonObj(json['profile'],
        (obj) => new ProducerProfile.fromJson(obj, pack: pack));
    profileMaxPower = json['profileMaxPower'];
    function = getProducerFunction(json['function']);
    costs = jsonObj(json['costs'], (obj) => new ProductCosts.fromJson(json));
    fuelSpec = jsonObj(
        json['fuelSpec'], (obj) => new FuelSpec.fromJson(json, pack: pack));
    heatRecovery = jsonObj(
        json['heatRecovery'], (obj) => new HeatRecovery._fromRef(obj, pack));
    interruptions = jsonEach(json['interruptions'],
        (obj) => new TimeInterval.fromJson(json, pack: pack));
    heatRecoveryCosts = jsonObj(
        json['heatRecoveryCosts'], (obj) => new ProductCosts.fromJson(json));
    utilisationRate = json['utilisationRate'];
  }

  factory Producer.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.PRODUCER, id);
    if (json == null) return null;
    return new Producer.fromJson(json, pack: pack);
  }

  factory Producer._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Producer.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('disabled', disabled);
    w.val('rank', rank);
    w.refObj('productGroup', productGroup);
    w.refObj('boiler', boiler);
    w.val('hasProfile', hasProfile);
    w.obj('profile', profile);
    w.val('profileMaxPower', profileMaxPower);
    w.enumer('function', function);
    w.obj('costs', costs);
    w.obj('fuelSpec', fuelSpec);
    w.refObj('heatRecovery', heatRecovery);
    w.list('interruptions', interruptions);
    w.obj('heatRecoveryCosts', heatRecoveryCosts);
    w.val('utilisationRate', utilisationRate);
    return json;
  }
}

class Product extends AbstractProduct {
  String projectId;

  Product();

  Product.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    projectId = json['projectId'];
  }

  factory Product.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.PRODUCT, id);
    if (json == null) return null;
    return new Product.fromJson(json, pack: pack);
  }

  factory Product._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Product.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('projectId', projectId);
    return json;
  }
}

class ProductEntry extends AbstractEntity {
  Product product;
  ProductCosts costs;
  double pricePerPiece;
  double count;

  ProductEntry();

  ProductEntry.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    product =
        jsonObj(json['product'], (obj) => new Product._fromRef(obj, pack));
    costs = jsonObj(json['costs'], (obj) => new ProductCosts.fromJson(obj));
    pricePerPiece = json['pricePerPiece'];
    count = json['count'];
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.refObj('product', product);
    w.obj('costs', costs);
    w.val('pricePerPiece', pricePerPiece);
    w.val('count', count);
    return json;
  }
}

class CostSettings extends AbstractEntity {
  double vatRate;
  double hourlyWage;
  double electricityPrice;
  double electricityRevenues;
  double electricityDemandShare;
  double interestRate;
  double interestRateFunding;
  double funding;
  double insuranceShare;
  double otherShare;
  double administrationShare;
  double investmentFactor;
  double bioFuelFactor;
  double fossilFuelFactor;
  double electricityFactor;
  double operationFactor;
  double maintenanceFactor;

  CostSettings();

  CostSettings.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    vatRate = json['vatRate'];
    hourlyWage = json['hourlyWage'];
    electricityPrice = json['electricityPrice'];
    electricityRevenues = json['electricityRevenues'];
    electricityDemandShare = json['electricityDemandShare'];
    interestRate = json['interestRate'];
    interestRateFunding = json['interestRateFunding'];
    funding = json['funding'];
    insuranceShare = json['insuranceShare'];
    otherShare = json['otherShare'];
    administrationShare = json['administrationShare'];
    investmentFactor = json['investmentFactor'];
    bioFuelFactor = json['bioFuelFactor'];
    fossilFuelFactor = json['fossilFuelFactor'];
    electricityFactor = json['electricityFactor'];
    operationFactor = json['operationFactor'];
    maintenanceFactor = json['maintenanceFactor'];
  }

  factory CostSettings.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.COST_SETTINGS, id);
    if (json == null) return null;
    return new CostSettings.fromJson(json, pack: pack);
  }

  factory CostSettings._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new CostSettings.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('vatRate', vatRate);
    w.val('hourlyWage', hourlyWage);
    w.val('electricityPrice', electricityPrice);
    w.val('electricityRevenues', electricityRevenues);
    w.val('electricityDemandShare', electricityDemandShare);
    w.val('interestRate', interestRate);
    w.val('interestRateFunding', interestRateFunding);
    w.val('funding', funding);
    w.val('insuranceShare', insuranceShare);
    w.val('otherShare', otherShare);
    w.val('administrationShare', administrationShare);
    w.val('investmentFactor', investmentFactor);
    w.val('bioFuelFactor', bioFuelFactor);
    w.val('fossilFuelFactor', fossilFuelFactor);
    w.val('electricityFactor', electricityFactor);
    w.val('operationFactor', operationFactor);
    w.val('maintenanceFactor', maintenanceFactor);
    return json;
  }
}

class Project extends RootEntity {
  int duration;
  List<Producer> producers;
  List<Consumer> consumers;
  WeatherStation weatherStation;
  CostSettings costSettings;
  HeatNet heatNet;
  List<ProductEntry> productEntries;
  List<Product> ownProducts;
  List<FlueGasCleaningEntry> flueGasCleaningEntries;

  Project();

  Project.fromJson(Map<String, dynamic> json, {DataPack pack})
      : super.fromJson(json, pack: pack) {
    duration = json['duration'];
    producers =
        jsonEach(json['producers'], (obj) => new Producer._fromRef(obj, pack));
    consumers =
        jsonEach(json['consumers'], (obj) => new Consumer._fromRef(obj, pack));
    weatherStation = jsonObj(json['weatherStation'],
        (obj) => new WeatherStation._fromRef(obj, pack));
    costSettings = jsonObj(json['costSettings'],
        (obj) => new CostSettings.fromJson(obj, pack: pack));
    heatNet = jsonObj(
        json['heatNet'], (obj) => new HeatNet.fromJson(obj, pack: pack));
    productEntries = jsonEach(json['productEntries'],
        (obj) => new ProductEntry.fromJson(obj, pack: pack));
    ownProducts =
        jsonEach(json['ownProducts'], (obj) => new Product._fromRef(obj, pack));
    flueGasCleaningEntries = jsonEach(json['flueGasCleaningEntries'],
        (obj) => new FlueGasCleaningEntry.fromJson(json, pack: pack));
  }

  factory Project.fromPack(String id, DataPack pack) {
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.PROJECT, id);
    if (json == null) return null;
    return new Project.fromJson(json, pack: pack);
  }

  factory Project._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Project.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
    var json = super.toJson(pack: pack);
    var w = new JsonWriter(pack, json);
    w.val('duration', duration);
    w.refList('producers', producers);
    w.refList('consumers', consumers);
    w.refObj('weatherStation', weatherStation);
    w.obj('costSettings', costSettings);
    w.obj('heatNet', heatNet);
    w.list('productEntries', productEntries);
    w.list('ownProducts', ownProducts);
    w.list('flueGasCleaningEntries', flueGasCleaningEntries);
    return json;
  }
}
