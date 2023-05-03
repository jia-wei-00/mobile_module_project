import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';

part 'route_state.dart';

class RouteCubit extends Cubit<RouteState> {
  RouteCubit() : super(const RouteInitial(0));

  void changeRoute(int index) {
    emit(RouteInitial(index));
  }
}
