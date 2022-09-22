import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'BeanData/menu_bean.dart';

const String keySaveOrder="savedOrder";
class LocalStorage {
  late SharedPreferences _prefs;


  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  saveData(Set<Product> addItems) async{
    List<String>? savedOrders = _prefs.getStringList(keySaveOrder);
    savedOrders?.add(jsonEncode(addItems.map((e) => e.toJson()).toList()));
   await _prefs.setStringList(keySaveOrder,
        savedOrders ?? [jsonEncode(addItems.map((e) => e.toJson()).toList())]);
  }

  List<String>? getSavedData(){
    return _prefs.getStringList(keySaveOrder);
  }
}
