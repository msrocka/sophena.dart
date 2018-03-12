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
  
}

abstract class AbstractProduct extends BaseDataEntity {}
