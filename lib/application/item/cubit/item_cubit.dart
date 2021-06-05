import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  ItemCubit({
    required Item item,
  }) : super(ItemState(item: item)) {
    priceController.text = item.price.toStringAsFixed(2);
    quantityController.text = item.quantity.toStringAsFixed(2);
  }

  final priceController = TextEditingController();
  final quantityController = TextEditingController();
}
