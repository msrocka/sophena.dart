import 'package:sophena/sophena.dart';
import 'package:logging/logging.dart';

// an example for reading data from a Sophena data package.
void main() {
  // setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  var path =
      'C:/Users//Besitzer/Projects/sophena/data/modelle/Eichstätt_updated.sophena';
  var pack = new DataPack.open(path);
  pack.getIds(ModelType.FUEL).forEach((id) {
    var json = pack.get(ModelType.FUEL, id);
    Fuel fuel = new Fuel.fromJson(json);
    print(fuel.toJson());
  });

  pack.put(ModelType.FUEL, {'id': 'atest'});

  pack.save('C:/Users//Besitzer/Desktop/rems/testpack.sophena');
}
