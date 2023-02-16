import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';

import 'enums.dart';

class DataPack {
  late final Archive _archive;
  final Logger _log = new Logger('sophena.DataPack');

  DataPack() {
    _archive = new Archive();
  }

  DataPack.open(String path) {
    _log.fine('Open data pack $path');
    File file = new File(path);
    List<int> bytes = file.readAsBytesSync();
    _archive = new ZipDecoder().decodeBytes(bytes);
  }

  List<String> getIds(ModelType type) {
    _log.finest('Get IDs for $type');
    String dir = _path(type);
    List<String> ids = [];
    for (ArchiveFile f in _archive.files) {
      if (!f.isFile) {
        continue;
      }
      if (f.name.startsWith(dir + '/')) {
        ids.add(f.name.substring(dir.length + 1, f.name.length - 5));
      }
    }
    return ids;
  }

  bool contains(ModelType type, String id) {
    var path = '${_path(type)}/$id.json';
    return _archive.findFile(path) != null;
  }

  /// Loads the json object for the given [type] and [id] from the package.
  ///
  /// It simply returns `null` if it does not exist.
  Map<String, dynamic>? get(ModelType type, String id) {
    var path = '${_path(type)}/$id.json';
    var f = _archive.findFile(path);
    return f != null
        ? json.decode(utf8.decode(f.content)) as Map<String, dynamic>
        : null;
  }

  void put(ModelType type, Map<String, dynamic> map) {
    String? id = map['id'];
    if (id == null) {
      _log.warning('Cannot add json for $type: id is null');
      return;
    }
    var path = '${_path(type)}/$id.json';
    var f = _archive.findFile(path);
    if (f != null) {
      _log.warning('Cannot add json $path as it already exists');
      return;
    }
    List<int> content = utf8.encode(json.encode(map));
    f = new ArchiveFile(path, content.length, content);
    _archive.addFile(f);
  }

  /// Saves the data pack to a file with the given [path].
  void save(String path) {
    _log.fine('Write data pack to $path');
    try {
      File file = new File(path);
      List<int>? bytes = new ZipEncoder().encode(_archive);
      file.writeAsBytesSync(bytes!);
    } catch (e) {
      _log.severe('Failed to save data pack to $path', e);
    }
  }
}

String _path(ModelType type) {
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
