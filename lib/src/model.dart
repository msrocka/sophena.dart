abstract class Defaults {
  static const SMOOTHING_FACTOR = 10;

  static const EMISSION_FACTOR_ELECTRICITY = 0.6148;
  static const EMISSION_FACTOR_OIL = 0.3072;
  static const EMISSION_FACTOR_NATURAL_GAS = 0.2392;
  static const PRIMARY_ENERGY_FACTOR_ELECTRICITY = 2.8;
  static const SPECIFIC_STAND_BY_LOSS = 0.014;
}

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

class AnnualCostEntry {
  String? label;
  double value = 0;
}

class Boiler extends AbstractProduct {
  double maxPower = 0;
  double minPower = 0;
  double efficiencyRate = 0;
  bool isCoGenPlant = false;
  double maxPowerElectric = 0;
  double minPowerElectric = 0;
  double efficiencyRateElectric = 0;
}

class BufferTank extends AbstractProduct {
  double volume = 0;
  double diameter = 0;
  double height = 0;
  double insulationThickness = 0;
}

class BuildingState extends BaseDataEntity {
  int index = 0;
  bool isDefault = false;
  BuildingType? type;
  double heatingLimit = 0;
  double antifreezingTemperature = 0;
  double waterFraction = 0;
  int loadHours = 0;
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

class Consumer extends RootEntity {
  bool disabled = false;
  bool demandBased = false;
  BuildingState? buildingState;
  double heatingLoad = 0;
  double waterFraction = 0;
  int loadHours = 0;
  double heatingLimit = 0;
  double floorSpace = 0;
  final List<FuelConsumption> fuelConsumptions = [];
  final List<TimeInterval> interruptions = [];
  LoadProfile? profile;
  Location? location;
  TransferStation? transferStation;
  ProductCosts? transferStationCosts;
}

class CostSettings extends Entity {
  static final String GLOBAL_ID = "9ff7e5f9-c603-4f21-b687-22191b697ba1";

  double hourlyWage = 0;
  double electricityPrice = 0;
  double electricityDemandShare = 0;
  Fuel? projectElectricityMix;
  Fuel? electricityMix;
  Fuel? replacedElectricityMix;
  double electricityRevenues = 0;
  double heatRevenues = 0;
  double interestRate = 0;
  double interestRateFunding = 0;
  double funding = 0;
  double fundingBiomassBoilers = 0;
  double fundingHeatNet = 0;
  double fundingTransferStations = 0;
  double connectionFees = 0;
  double insuranceShare = 0;
  double otherShare = 0;
  double administrationShare = 0;
  List<AnnualCostEntry> annualCosts = [];
  double investmentFactor = 0;
  double bioFuelFactor = 0;
  double fossilFuelFactor = 0;
  double electricityFactor = 0;
  double operationFactor = 0;
  double maintenanceFactor = 0;
  double heatRevenuesFactor = 0;
  double electricityRevenuesFactor = 0;
}

class FlueGasCleaning extends AbstractProduct {
  String? flueGasCleaningType;
  String? fuel;
  String? cleaningMethod;
  String? cleaningType;
  double maxVolumeFlow = 0;
  double maxProducerPower = 0;
  double maxElectricityConsumption = 0;
  double separationEfficiency = 0;
}

class FlueGasCleaningEntry extends Entity {
  FlueGasCleaning? product;
  ProductCosts? costs;
}

class Fuel extends BaseDataEntity {
  FuelGroup? group;
  String? unit;
  double calorificValue = 0;
  double density = 0;
  double co2Emissions = 0;
  double primaryEnergyFactor = 0;
  double ashContent = 0;
}

class FuelConsumption extends Entity {
  Fuel? fuel;
  double amount = 0;
  double utilisationRate = 0;
  WoodAmountType? woodAmountType;
  double waterContent = 0;
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

class FuelSpec {
  Fuel? fuel;
  WoodAmountType? woodAmountType;
  double waterContent = 0;
  double pricePerUnit = 0;
  double ashCosts = 0;
}

class HeatNet extends Entity {
  double? length;
  double? supplyTemperature;
  double? returnTemperature;
  double? simultaneityFactor;
  double? smoothingFactor;
  double? maxLoad;
  BufferTank? bufferTank;
  double maxBufferLoadTemperature = 0;
  double? lowerBufferLoadTemperature;
  double bufferLambda = 0;
  ProductCosts? bufferTankCosts;
  double powerLoss = 0;
  TimeInterval? interruption;
  final List<HeatNetPipe> pipes = [];
}

class HeatNetPipe extends Entity {
  Pipe? pipe;
  ProductCosts? costs;
  String? name;
  double length = 0;
  double pricePerMeter = 0;
}

class HeatRecovery extends AbstractProduct {
  String? heatRecoveryType;
  String? fuel;
  double power = 0;
  double producerPower = 0;
}

class LoadProfile extends Entity {
  final List<double> dynamicData;
  final List<double> staticData;

  LoadProfile(this.dynamicData, this.staticData);
}

class Location extends Entity {
  String? name;
  String? street;
  String? zipCode;
  String? city;
  double? latitude;
  double? longitude;
}

class Manufacturer extends BaseDataEntity {
  String? address;
  String? url;
  String? logo;
  int sponsorOrder = 0;
}

class Pipe extends AbstractProduct {
  String? material;
  PipeType? pipeType;
  String? deliveryType;
  double uValue = 0;
  double innerDiameter = 0;
  double outerDiameter = 0;
  double totalDiameter = 0;
  double? maxTemperature;
  double? maxPressure;
}

enum PipeType { UNO, DUO }

class Producer extends RootEntity {
  bool disabled = false;
  int rank = 0;
  ProductGroup? productGroup;
  Boiler? boiler;
  ProducerProfile? profile;
  double profileMaxPower = 0;
  double profileMaxPowerElectric = 0;
  ProducerFunction? function;
  ProductCosts? costs;
  FuelSpec? fuelSpec;
  Fuel? producedElectricity;
  HeatRecovery? heatRecovery;
  final List<TimeInterval> interruptions = [];
  ProductCosts? heatRecoveryCosts;
  double? utilisationRate;
}

enum ProducerFunction { BASE_LOAD, PEAK_LOAD }

class ProducerProfile extends Entity {
  final List<double> minPower;
  final List<double> maxPower;

  ProducerProfile(this.minPower, this.maxPower);
}

class Product extends AbstractProduct {
  String? projectId;
}

enum ProductArea {
  TECHNOLOGY,
  BUILDINGS,
  HEATING_NET,
  PLANNING;
}

class ProductCosts {
  double investment = 0;
  int duration = 0;
  double repair = 0;
  double maintenance = 0;
  double operation = 0;
}

class ProductEntry extends Entity {
  Product? product;
  ProductCosts? costs;
  double pricePerPiece = 0;
  double count = 0;
}

class ProductGroup extends BaseDataEntity {
  ProductType? type;
  FuelGroup? fuelGroup;
  int index = 0;
  int duration = 0;
  double repair = 0;
  double maintenance = 0;
  double operation = 0;
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

class Project extends RootEntity {
  ProjectFolder? folder;
  int duration = 0;
  final List<Producer> producers = [];
  final List<Consumer> consumers = [];
  WeatherStation? weatherStation;
  CostSettings? costSettings;
  HeatNet? heatNet;
  final List<ProductEntry> productEntries = [];
  final List<Product> ownProducts = [];
  final List<FlueGasCleaningEntry> flueGasCleaningEntries = [];
}

class ProjectFolder extends RootEntity {}

class TimeInterval extends Entity {
  String? start;
  String? end;
  String? description;
}

class TransferStation extends AbstractProduct {
  String? buildingType;
  double outputCapacity = 0;
  String? stationType;
  String? material;
  String? waterHeating;
  String? control;
}

class WeatherStation extends BaseDataEntity {
  double longitude = 0;
  double latitude = 0;
  double altitude = 0;
  List<double> data = [];
}

enum WoodAmountType {
  MASS("t", 1),

  CHIPS("Srm", 0.4),

  LOGS("Ster (Rm)", 0.7);

  // typical unit for the wood type
  final String unit;

  // conversion factor for converting the wood type specific unit to solid
  // cubic meters
  final double factor;

  const WoodAmountType(this.unit, this.factor);
}
