import 'package:sophena/io.dart';
import 'package:sophena/model.dart';

void main() {
  var path = 'C:/Users//Besitzer/Projects/sophena/data/modelle/Eichstätt_updated.sophena';
  var pack = new DataPack.open(path);
  pack.getIds(ModelType.FUEL).forEach((id) {
    var fuel = pack.get(ModelType.FUEL, id);
    print(fuel['name']);
  });
}