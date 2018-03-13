/// An abstract entity is basically just a thing that can be stored in a
/// database.
abstract class AbstractEntity {
  String id;

  AbstractEntity();

  AbstractEntity.fromJson(Map<String, dynamic> json) {
    id = json[id];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = id;
    json['@type'] = this.runtimeType.toString();
    return json;
  }
}

/// A root entity is a stand-alone entity with a name and description.
abstract class RootEntity extends AbstractEntity {
  String name;
  String description;

  RootEntity();

  RootEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    name = json['name'];
    description = json['description'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    if (name != null) {
      json['name'] = name;
    }
    if (description != null) {
      json['description'] = description;
    }
    return super.toJson();
  }
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

  BaseDataEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    isProtected = json['isProtected'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['isProtected'] = isProtected;
    return json;
  }
}

/// An enumeration of all root entity types. This is used in things like data
/// exchange, e.g. for assigning package paths to types and the other way around.
enum ModelType {
  BOILER,
  BUFFER,
  BUILDING_STATE,
  CONSUMER,
  COST_SETTINGS,
  FLUE_GAS_CLEANING,
  FUEL,
  HEAT_RECOVERY,
  LOAD_PROFILE,
  MANUFACTURER,
  PIPE,
  PRODUCER,
  PRODUCT_GROUP,
  PRODUCT,
  PROJECT,
  TRANSFER_STATION,
  WEATHER_STATION
}

class Manufacturer extends BaseDataEntity {
  String address;
  String url;

  Manufacturer();

  Manufacturer.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    address = json['address'];
    url = json['url'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    if (address != null) {
      json['address'] = address;
    }
    if (url != null) {
      json['url'] = url;
    }
    return json;
  }
}

enum ProductType {
  BIOMASS_BOILER,
  FOSSIL_FUEL_BOILER,
  HEAT_PUMP,
  COGENERATION_PLANT,
  SOLAR_THERMAL_PLANT,
  ELECTRIC_HEAT_GENERATOR,
  BOILER_ACCESSORIES,
  HEAT_RECOVERY,
  FLUE_GAS_CLEANING,
  BUFFER_TANK,
  BOILER_HOUSE_TECHNOLOGY,
  BUILDING,
  PIPE,
  HEATING_NET_TECHNOLOGY,
  HEATING_NET_CONSTRUCTION,
  TRANSFER_STATION,
  PLANNING
}

/// Get the product type for the given string [value].
ProductType getProductType(String value) {
  if (value == null) return null;
  for (ProductType fg in ProductType.values) {
    String s = fg.toString().split('\.')[1];
    if (s == value) {
      return fg;
    }
  }
  return null;
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

  ProductGroup.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    type = getProductType(json['type']);
    index = json['index'];
    duration = json['duration'];
    repair = json['repair'];
    maintenance = json['maintenance'];
    operation = json['operation'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
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

  AbstractProduct.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    purchasePrice = json['purchasePrice'];
    url = json['url'];
    if (json['manufacturer'] != null) {
      manufacturer = new Manufacturer.fromJson(json['manufacturer']);
    }
    if (json['type'] != null) {
      type = getProductType(json['type']);
    }
    if (json['group'] != null) {
      group = new ProductGroup.fromJson(json['group']);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    if (purchasePrice != null) {
      json['purchasePrice'] = purchasePrice;
    }
    if (url != null) {
      json['url'] = url;
    }
    if (manufacturer != null) {
      json['manufacturer'] = manufacturer.toJson();
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

enum FuelGroup {
  BIOGAS,
  NATURAL_GAS,
  LIQUID_GAS,
  HEATING_OIL,
  PELLETS,
  ELECTRICITY,
  HOT_WATER,
  PLANTS_OIL,
  WOOD
}

/// Get the fuel group for the given string [value].
FuelGroup getFuelGroup(String value) {
  if (value == null) return null;
  for (FuelGroup fg in FuelGroup.values) {
    String s = fg.toString().split('\.')[1];
    if (s == value) {
      return fg;
    }
  }
  return null;
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

  Fuel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    unit = json['unit'];
    calorificValue = json['calorificValue'];
    density = json['density'];
    if (json['group'] != null) {
      group = getFuelGroup(json['group']);
    }
    co2Emissions = json['co2Emissions'];
    primaryEnergyFactor = json['primaryEnergyFactor'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
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

/// Wood amounts can be given in the different quantity types: (dry) mass, chips,
/// logs
enum WoodAmountType { MASS, CHIPS, LOGS }

/// Get the wood amount type for the given string [value].
WoodAmountType getWoodAmountType(String value) {
  if (value == null) return null;
  for (WoodAmountType wt in WoodAmountType.values) {
    String s = wt.toString().split('\.')[1];
    if (s == value) {
      return wt;
    }
  }
  return null;
}

class BufferTank extends AbstractProduct {
  double volume;
  double diameter;
  double height;
  double insulationThickness;

  BufferTank();

  BufferTank.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    volume = json['volume'];
    diameter = json['diameter'];
    height = json['height'];
    insulationThickness = json['insulationThickness'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
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

enum BuildingType {
	SINGLE_FAMILY_HOUSE,
	MULTI_FAMILY_HOUSE,
	BLOCK_OF_FLATS,
	TERRACE_HOUSE,
	TOWER_BLOCK,
	SCHOOL,
	KINDERGARDEN,
	OFFICE_BUILDING,
	HOSPITAL,
	NURSING_HOME,
	RESTAURANT,
	HOTEL,
	COMMERCIAL_BUILDING,
	FERMENTER,
	OTHER
}

/// Get the building type for the given string [value].
BuildingType getBuildingType(String value) {
  if (value == null) return null;
  for (BuildingType bt in BuildingType.values) {
    String s = bt.toString().split('\.')[1];
    if (s == value) {
      return bt;
    }
  }
  return null;
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

  BuildingState.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
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

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
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

  FuelConsumption.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json['fuel'] != null) {
      fuel = new Fuel.fromJson(json['fuel']);
    }
    amount = json['amount'];
    utilisationRate = json['utilisationRate'];
    if (json['woodAmountType'] != null) {
      woodAmountType = getWoodAmountType(json['woodAmountType']);
    }
    waterContent = json['waterContent'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    if (fuel != null) {
      json['fuel'] = fuel.toJson();
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

  TimeInterval.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    start = json['start'];
    end = json['end'];
    description = json['description'];
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
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
