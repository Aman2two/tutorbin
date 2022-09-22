import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import '../BeanData/menu_bean.dart';

class ItemAddVm extends BaseViewModel {
  List<MenuBean> menuItems = [];
  Set<Product> addItems = {};
  int totalPayableAmount = 0;

  ItemAddVm() {
    createDataFromJson().then((value) {
      notifyListeners();
    });
  }


  handleElementAdd(Product product, {bool isAdd = true}) {
    if (isAdd) {
      addItems.add(product);
      product.count++;
    } else {
      product.count--;
      if (product.count == 0) {
        product.isBestSeller=false;
        addItems.remove(product);
      }
    }
    updateTotalAmount(product.price??0,isAdd: isAdd);
  }

  updateTotalAmount(int itemPrice, {bool isAdd = true}) {
    if (isAdd) {
      totalPayableAmount += itemPrice;
    } else {
      totalPayableAmount -= itemPrice;
    }
    calculateBestSeller();
  }

  calculateBestSeller(){
    int bestAmount=0;
    int bestItemIndex=-1;
    for(int i=0;i<addItems.length;i++){
      var element=addItems.elementAt(i);
      if(bestAmount<element.count)
        {
          bestAmount=element.count;
          bestItemIndex=i;
        }
    }
    if(bestItemIndex!=-1){
      for (var element in addItems) {
        element.isBestSeller=false;
      }
      addItems.elementAt(bestItemIndex).isBestSeller=true;
    }
    notifyListeners();
  }

  Future<void> createDataFromJson() async {
    final String response = await rootBundle.loadString('lib/assets/menu.json');
    final data = await json.decode(response) as Map<String, dynamic>;
    List<MenuBean> beanData = [];
    for (var element in data.entries) {
      beanData.add(MenuBean.fromJson(element.key, element.value));
    }
    menuItems = beanData;
  }



}
