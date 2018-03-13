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

/// In Sophena products are grouped and each group is of a specific type.
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
