library dark_novels_store;

import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  final SharedPreferences prefs;
  final Map<String, StoreItem<dynamic>> cache = {};

  Store({required this.prefs});

  void dispose() {
    cache.values.forEach((i) => i.dispose());
    cache.clear();
  }
}

typedef StoreItemLoad<T> = T? Function(SharedPreferences prefs);
typedef StoreItemSave<T> = void Function(SharedPreferences prefs, T model);
typedef StoreItemClean = void Function(SharedPreferences prefs);

class StoreItem<T> {
  late ValueNotifier<T?> _value;
  late Function _listener;

  StoreItem({
    required SharedPreferences prefs,
    StoreItemLoad<T?>? load,
    StoreItemSave<T>? save,
    StoreItemClean? clean,
  }) {
    _listener = () {
      if (_value.value == null && clean != null) {
        clean(prefs);
      }
      if (_value.value != null && save != null) {
        save(prefs, _value.value!);
      }
    };
    _value = ValueNotifier(load != null ? load(prefs) : null);
    _value.addListener(_listener as void Function());
  }

  ValueNotifier<T?> get value => _value;

  void dispose() => _value.removeListener(_listener as void Function());
}

class StoreNonNullItem<T> extends StoreItem<T> {
  late ValueNotifier<T> _value2;

  StoreNonNullItem({
    required SharedPreferences prefs,
    required StoreItemLoad<T> load,
    required StoreItemSave<T> save,
  }) : super(
          prefs: prefs,
          load: load,
          save: save,
        ) {
    _listener = () {
      save(prefs, _value.value!);
    };
    _value2 = ValueNotifier(load(prefs)!);
    _value2.addListener(_listener as void Function());
  }

  ValueNotifier<T> get value => _value2;

  void dispose() => _value.removeListener(_listener as void Function());
}
