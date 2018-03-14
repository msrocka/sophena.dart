import 'datapack.dart';
import 'enums.dart';
import 'json.dart';

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
    pack.put(modelType(this), json);
  }
}

/// Returns the model type of the given entity.
ModelType modelType<T extends RootEntity>(T e) {
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
  // TODO: other model types
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
    if (pack == null || id == null) return null;
    var json = pack.get(ModelType.MANUFACTURER, id);
    if (json == null) return null;
    return new Manufacturer.fromJson(json, pack: pack);
  }

  factory Manufacturer._fromRef(Map<String, dynamic> ref, DataPack pack) {
    if (ref == null) return null;
    return new Manufacturer.fromPack(ref['id'], pack);
  }

  @override
  Map<String, dynamic> toJson({DataPack pack}) {
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
