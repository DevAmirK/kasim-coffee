import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/cart_item.dart';

class CartState extends Equatable {
  CartState([Iterable<CartItem> items = const []])
    : items = List.unmodifiable(items);

  final List<CartItem> items;
  int get count => items.length;

  @override
  List<Object?> get props => [items];

  double get totalPrice => items.fold(0, (sum, item) => sum + item.price);
  int quantity(CartItem item) =>
      items.where((other) => sameConfiguration(item, other)).length;
  static bool sameConfiguration(CartItem a, CartItem b) =>
      a.drink.id == b.drink.id &&
      a.size == b.size &&
      a.milk == b.milk &&
      a.syrup == b.syrup;
  List<CartItem> get positions {
    final result = <CartItem>[];
    for (final item in items) {
      if (!result.any((other) => sameConfiguration(item, other))) {
        result.add(item);
      }
    }
    return result;
  }
}

sealed class CartEvent {
  const CartEvent();
}

class AddProductEvent extends CartEvent {
  const AddProductEvent(this.item);
  final CartItem item;
}

class RemoveProductEvent extends CartEvent {
  const RemoveProductEvent(this.productId);
  final String productId;
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

class DecreaseProductEvent extends CartEvent {
  const DecreaseProductEvent(this.item);
  final CartItem item;
}

class ReplaceProductEvent extends CartEvent {
  const ReplaceProductEvent(this.original, this.replacement);
  final CartItem original;
  final CartItem replacement;
}

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState()) {
    on<AddProductEvent>((event, emit) {
      if (state.items.contains(event.item)) return;
      emit(CartState([...state.items, event.item]));
    });
    on<RemoveProductEvent>((event, emit) {
      final index = state.items.indexWhere(
        (item) => item.id == event.productId,
      );
      if (index < 0) return;
      final selected = state.items[index];
      emit(
        CartState(
          state.items.where(
            (item) => !CartState.sameConfiguration(item, selected),
          ),
        ),
      );
    });
    on<ClearCartEvent>((event, emit) => emit(CartState()));
    on<DecreaseProductEvent>((event, emit) {
      final items = [...state.items];
      final index = items.lastIndexWhere(
        (item) => CartState.sameConfiguration(item, event.item),
      );
      if (index < 0) return;
      items.removeAt(index);
      emit(CartState(items));
    });
    on<ReplaceProductEvent>((event, emit) {
      final count = state.quantity(event.original);
      if (count == 0) return;
      final items = [...state.items];
      final index = items.indexWhere(
        (item) => CartState.sameConfiguration(item, event.original),
      );
      items.removeWhere(
        (item) => CartState.sameConfiguration(item, event.original),
      );
      final replacement = event.replacement;
      items.insertAll(
        index,
        List.generate(
          count,
          (_) => CartItem(
            drink: replacement.drink,
            size: replacement.size,
            milk: replacement.milk,
            syrup: replacement.syrup,
          ),
        ),
      );
      emit(CartState(items));
    });
  }
}
