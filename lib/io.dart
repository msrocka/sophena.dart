import 'dart:io';
import 'package:archive/archive.dart';

import 'model.dart';

class DataPack {
  Archive _archive;

  DataPack.open(String path) {
    File file = new File(path);
    List<int> bytes = file.readAsBytesSync();
    _archive = new ZipDecoder().decodeBytes(bytes);
  }

  List<String> getIds(ModelType type) {
    String dir = _path(type);
    List<String> ids = [];
    for (ArchiveFile f in _archive.files) {
      if (!f.isFile) {
        continue;
      }
      if (f.name.startsWith(dir + '/')) {
        ids.add(f.name.substring(0, f.name.length - 4)); // without '.json'
      }
    }
    return ids;
  }

  String _path(ModelType type) {
    if (type == null) return "unknown";
    switch (type) {
      case ModelType.BOILER:
        return "boilers";
      case ModelType.BUFFER:
        return "buffers";
      case ModelType.BUILDING_STATE:
        return "building_states";
      case ModelType.CONSUMER:
        return "consumers";
      case ModelType.COST_SETTINGS:
        return "cost_settings";
      case ModelType.FLUE_GAS_CLEANING:
        return "flue_gas_cleaning";
      case ModelType.FUEL:
        return "fuels";
      case ModelType.HEAT_RECOVERY:
        return "heat_recovery";
      case ModelType.LOAD_PROFILE:
        return "load_profiles";
      case ModelType.MANUFACTURER:
        return "manufacturers";
      case ModelType.PIPE:
        return "pipes";
      case ModelType.PRODUCER:
        return "producers";
      case ModelType.PRODUCT:
        return "products";
      case ModelType.PRODUCT_GROUP:
        return "product_groups";
      case ModelType.PROJECT:
        return "projects";
      case ModelType.TRANSFER_STATION:
        return "transfer_stations";
      case ModelType.WEATHER_STATION:
        return "weather_stations";
      default:
        return "unknown";
    }
  }
}
