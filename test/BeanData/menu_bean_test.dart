

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorbinassignment/BeanData/menu_bean.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  test("dart convert test",()async{
    final String response = await rootBundle.loadString('lib/assets/menu.json');
    final data = await json.decode(response) as Map<String,dynamic>;
    List<MenuBean> beanData=[];
    for (var element in data.entries) {
      beanData.add(MenuBean.fromJson(element.key, element.value));
    }
    expect(6, beanData.length);
  });
}