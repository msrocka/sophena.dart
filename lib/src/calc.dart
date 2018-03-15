/// Contains functions to calculate the calorific value based on fuel
/// specifications.
///
/// Especially for wood fuels this is more than just returning the calorific
/// value defined in the fuel.
class CalorificValue {
  CalorificValue._internal();

  static double forWood(
      {double woodMass = 1.0, // t
      double waterContent = 0.2,
      double calorificValue = 5200.0 // kWh/t
      }) {
    if (woodMass == null || waterContent == null || calorificValue == null)
      return 0.0;
    return woodMass *
        ((1 - waterContent) * calorificValue - waterContent * 680);
  }
}
