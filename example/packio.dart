import 'package:sophena/io.dart';
import 'package:sophena/model.dart';

// an example for reading data from a Sophena data package.
void main() {
  var path = 'C:/Users//Besitzer/Projects/sophena/data/modelle/Eichstätt_updated.sophena';
  var pack = new DataPack.open(path);
  pack.getIds(ModelType.FUEL).forEach((id) {
    var json = pack.get(ModelType.FUEL, id);
    Fuel fuel = new Fuel.fromJson(json);
    print(fuel.toJson());
  });
}