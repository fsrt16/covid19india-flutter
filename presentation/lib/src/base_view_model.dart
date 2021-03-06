import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

abstract class BaseViewModel<S, A> {
  S _currentState;
  @protected S get currentState  => _currentState;
  
  BehaviorSubject<S> _uiState; //TODO: This needs to be final but we cannot use non-static methods in constructor. Find idiomatic Dart way to achieve this
  BehaviorSubject<S> get uiState => _uiState;

  final BehaviorSubject<A> _actions = BehaviorSubject<A>(); //TODO: can we make this a simple Stream instead of BehaviourSubject?

  @protected Function(A) actionProcessor;
  
  BaseViewModel({@required S initialState}): 
        this._currentState = initialState {
    _uiState = BehaviorSubject.seeded(
        initialState,
        onListen: onInit,
        onCancel: onDispose);
    _actions.listen((event) {
      actionProcessor(event);
    });
  }

  @protected void emit(S state) {
    //TODO: Use streams here instead so that we can use debounce, distinct etc
    final distinct = _currentState != state;
    _currentState = state;
    if(distinct && !_uiState.isClosed) _uiState.sink.add(state);
  }

  void dispatchAction(A action) {
    if(!_actions.isClosed) {
      _actions.sink.add(action);
    }
  }

  @mustCallSuper
  void onInit() {
    print('BaseViewModel onInit()');
  }

  @mustCallSuper
  void onDispose() {
    print('BaseViewModel onDispose()');
    _actions.close();
  }
}