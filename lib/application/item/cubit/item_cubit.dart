import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:unit_bargain_hunter/application/calculator/cubit/calculator_cubit.dart';
import 'package:unit_bargain_hunter/domain/calculator/calculator.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  CalculatorCubit _calculatorCubit;
  int _index;

  ItemCubit(
    this._calculatorCubit, {
    required int index,
  })  : _index = index,
        super(
          ItemState(
            index: index,
            item: _calculatorCubit.state.items[index],
          ),
        ) {
    _listenToCalcCubit();
    final item = _calculatorCubit.state.items[_index];
    priceController.text = item.price.toStringAsFixed(2);
    quantityController.text = item.quantity.toStringAsFixed(2);
  }

  void _listenToCalcCubit() {
    _calculatorCubit.stream.listen((event) {
      if (_index >= event.items.length) return;
      final itemFromCubit = event.items[_index];
      if (itemFromCubit != state.item) {
        _index = itemFromCubit.index;
        emit(state.copyWith(item: itemFromCubit));
      }
    });
  }

  final priceController = TextEditingController();
  final quantityController = TextEditingController();
}
