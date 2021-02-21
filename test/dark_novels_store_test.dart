import 'package:dark_novels_store/dark_novels_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('storage extension', () async {
    SharedPreferences.setMockInitialValues({'test': 'test'});
    Store store = Store(prefs: await SharedPreferences.getInstance());
    expect(store.test.value, 'test');
  });
}

extension TestStore on Store {
  ValueNotifier<String?> get test => ((cache['test'] ??= StoreItem<String>(
        load: loadStore,
        save: saveStore,
        clean: cleanStore,
        prefs: prefs,
      )) as StoreItem<String>)
          .value;
}

StoreItemLoad<String> get loadStore =>
    (prefs) => prefs.containsKey('test') ? prefs.getString('test') : null;

StoreItemSave<String> get saveStore => (prefs, model) async {
      await prefs.setString('test', model);
    };

StoreItemClean get cleanStore => (prefs) async {
      await prefs.remove('test');
    };
