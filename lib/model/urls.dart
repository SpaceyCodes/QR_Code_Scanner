import '../db/database_provider.dart';

class URL {
  int id;
  String name;

  URL({this.id, this.name});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.URL_NAME: name,
    };

    if (id != null) {
      map[DatabaseProvider.URL_ID] = id;
    }

    return map;
  }

  URL.fromMap(Map<String, dynamic> map) {
    id = map[DatabaseProvider.URL_ID];
    name = map[DatabaseProvider.URL_NAME];
  }
}
