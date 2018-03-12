/// An abstract entity is basically just a thing that can be stored in a
/// database.
abstract class AbstractEntity {
  String id;
}

/// A root entity is a stand-alone entity with a name and description.
abstract class RootEntity extends AbstractEntity {
  String name;
  String description;
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
}

class Manufacturer extends BaseDataEntity {
  String address;
  String url;
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

class ProductGroup extends BaseDataEntity {
  ProductType type;
  int index;

  /// Default usage duration of this product group given in years.
  int duration;

  /// Default fraction [%] of the investment that is used for repair.
  double repair;

  /// Default fraction [%] of the investment that is used for maintenance.
  double maintenance;

  /// Default amount of hours that are used for operation in one year.
  double operation;
}

abstract class AbstractProduct extends BaseDataEntity {
  double purchasePrice;
  String url;
  Manufacturer manufacturer;
  ProductType type;
  ProductGroup group;
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

  bool isWood() => group == FuelGroup.WOOD;
}
