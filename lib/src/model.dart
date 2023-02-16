abstract class Entity {
  String id = "";

  @override
  String toString() {
    return "${runtimeType}{id=$id}";
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      runtimeType == other.runtimeType ? id == (other as Entity).id : false;
}

abstract class RootEntity extends Entity {
  String name = "";
  String? description;
}

abstract class BaseDataEntity extends RootEntity {
  bool isProtected = false;
}

abstract class AbstractProduct extends RootEntity {
  double? purchasePrice;
  String? url;
  Manufacturer? manufacturer;
  ProductType? type;
}

class Manufacturer extends BaseDataEntity {
  String? address;
  String? url;
  String? logo;
  int? sponsorOrder;
}

enum ProductArea {
  TECHNOLOGY,
  BUILDINGS,
  HEATING_NET,
  PLANNING;
}

enum ProductType {
  BIOMASS_BOILER(ProductArea.TECHNOLOGY),
  FOSSIL_FUEL_BOILER(ProductArea.TECHNOLOGY),
  HEAT_PUMP(ProductArea.TECHNOLOGY),
  COGENERATION_PLANT(ProductArea.TECHNOLOGY),
  SOLAR_THERMAL_PLANT(ProductArea.TECHNOLOGY),
  ELECTRIC_HEAT_GENERATOR(ProductArea.TECHNOLOGY),
  OTHER_HEAT_SOURCE(ProductArea.TECHNOLOGY),
  BOILER_ACCESSORIES(ProductArea.TECHNOLOGY),
  OTHER_EQUIPMENT(ProductArea.TECHNOLOGY),
  HEAT_RECOVERY(ProductArea.TECHNOLOGY),
  FLUE_GAS_CLEANING(ProductArea.TECHNOLOGY),
  BUFFER_TANK(ProductArea.TECHNOLOGY),
  BOILER_HOUSE_TECHNOLOGY(ProductArea.TECHNOLOGY),
  BUILDING(ProductArea.BUILDINGS),
  PIPE(ProductArea.HEATING_NET),
  HEATING_NET_TECHNOLOGY(ProductArea.HEATING_NET),
  HEATING_NET_CONSTRUCTION(ProductArea.HEATING_NET),
  TRANSFER_STATION(ProductArea.HEATING_NET),
  PLANNING(ProductArea.PLANNING);

  final ProductArea productArea;
  const ProductType(this.productArea);
}
