import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:tutorbinassignment/storage.dart';

import '../BeanData/menu_bean.dart';

class ItemAddVm extends BaseViewModel {
  List<MenuBean> menuItems = [];
  Set<Product> addItems = {};
  Set<Product> existingData = {};
  int totalPayableAmount = 0;
  LocalStorage localStorage = LocalStorage();

  ItemAddVm() {
    createDataFromJson().then((value) {
      notifyListeners();
    });
    localStorage.init().then((value) {
      fetchSavedData();
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
        addItems.remove(product);
      }
    }
    updateTotalAmount(product.price ?? 0, isAdd: isAdd);
  }

  updateTotalAmount(int itemPrice, {bool isAdd = true}) {
    if (isAdd) {
      totalPayableAmount += itemPrice;
    } else {
      totalPayableAmount -= itemPrice;
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

  Future handleOrderPlaced() async {
    await localStorage.saveData(addItems);
  }

  fetchSavedData() {
    Set<Product> allOrders = {};
    List<String>? orders = localStorage.getSavedData();
    orders?.forEach((element) {
      Set<Product> oneOrderProduct = {};
      (jsonDecode(element) as List).forEach((element) {
        oneOrderProduct.add(Product.fromJson(element));
      });

      allOrders = customUnion(allOrders, oneOrderProduct);
    });
    existingData = SplayTreeSet<Product>.from(
      allOrders,
      (a, b) => b.count - a.count,
    );
    existingData=Set.from(existingData.take(3));
    createPopularProducts();
  }

  Set<Product> customUnion(
      Set<Product> allOrders, Set<Product> oneOrderProduct) {
    oneOrderProduct.forEach((element) {
      try {
        Product existingItem =
            allOrders.firstWhere((item) => item.name == element.name);
        int newCount = existingItem.count + element.count;
        allOrders.remove(existingItem);
        allOrders.add(existingItem..count = newCount);
      } catch (e) {
        allOrders.add(element);
      }
    });
    return allOrders;
  }

  createPopularProducts() {
    List<Product> popularProducts=[];
    menuItems.forEach((element) {
      element.products?.forEach((item) {
        // constant loop
        for(int i=0;i<existingData.length;i++){
          if(item.name==existingData.elementAt(i).name){
            popularProducts.add(item..isBestSeller=i==0);
          }
        }
      });
    });
    if(popularProducts.isNotEmpty){
      menuItems.insert(0, MenuBean.name("Popular products",popularProducts));
    }
    notifyListeners();
  }

}
