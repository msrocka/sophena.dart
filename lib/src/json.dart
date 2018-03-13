import 'enums.dart';
import 'datapack.dart';
import 'model.dart';

class JsonWriter {
  final DataPack _pack;
  final Map<String, dynamic> _json;

  JsonWriter(this._pack, this._json);

  /// Puts the given [value] for the given [key] into the underlying json object.
  ///
  /// The given [value] can be anything that can be directly encoded in JSON (
  /// so a string, number, list, object ...).
  void val(String key, dynamic value) {
    if (key == null || value == null) return;
    _json[key] = value;
  }

  /// Converts the given enumeration type into a string and adds it to the
  /// underlying json object.
  void enumer(String key, dynamic val) {
    if (val == null) return;
    var parts = val.toString().split('\.');
    if (parts.length > 1) {
      val(key, parts[1]);
    }
  }

  /// Converts the given [entity] into a json object and adds it to the
  /// underlying json object.
  void obj<T extends AbstractEntity>(String key, T entity) {
    if (entity == null) return;
    val(key, entity.toJson(pack: _pack));
  }

  /// Creates a reference of the given (root) entity and saves it to the
  /// underlying data pack.
  void refObj<T extends RootEntity>(String key, T entity) {
    var ref = _asRef(entity);
    if (ref != null) {
      val(key, ref);
    }
  }

  void list<T extends AbstractEntity>(String key, List<T> list) {
    if (list == null) return;
    List<Map<String, dynamic>> jList = [];
    for (T e in list) {
      if (e == null) continue;
      jList.add(e.toJson(pack: _pack));
    }
    val(key, jList);
  }

  void refList<T extends RootEntity>(String key, List<T> list) {
    if (list == null) return;
    List<Map<String, dynamic>> refList = [];
    for (T e in list) {
      if (e == null) continue;
      var ref = _asRef(e);
      if (ref != null) {
        refList.add(ref);
      }
    }
    val(key, refList);
  }

  Map<String, dynamic> _asRef<T extends RootEntity>(T entity) {
    if (entity == null || entity.id == null) {
      return null;
    }
    var ref = {
      'id': entity.id,
      '@type': entity.runtimeType.toString(),
      'name': entity.name
    };
    ModelType type = modelType(entity);
    if (_pack == null || _pack.contains(type, entity.id)) {
      return ref;
    }
    entity.save(_pack);
    return ref;
  }
}

List<T> jsonEach<T>(dynamic jsonList, T fn(Map<String, dynamic> m)) {
  if (jsonList == null || jsonList is! List<Map<String, dynamic>>) {
    return null;
  }
  List<T> list = [];
  for (var json in jsonList) {
    if (json == null) continue;
    T e = fn(json);
    if (e != null) {
      list.add(e);
    }
  }
  return list;
}
