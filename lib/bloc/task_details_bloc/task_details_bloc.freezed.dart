// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'task_details_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$TaskDetailsEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String taskId) loading,
    required TResult Function(String tempTaskId) refresh,
    required TResult Function() onlyLoading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsLoadingEvent value) loading,
    required TResult Function(TaskDetailsRefreshEvent value) refresh,
    required TResult Function(TaskDetailsOnlyLoadingEvent value) onlyLoading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskDetailsEventCopyWith<$Res> {
  factory $TaskDetailsEventCopyWith(
          TaskDetailsEvent value, $Res Function(TaskDetailsEvent) then) =
      _$TaskDetailsEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$TaskDetailsEventCopyWithImpl<$Res>
    implements $TaskDetailsEventCopyWith<$Res> {
  _$TaskDetailsEventCopyWithImpl(this._value, this._then);

  final TaskDetailsEvent _value;
  // ignore: unused_field
  final $Res Function(TaskDetailsEvent) _then;
}

/// @nodoc
abstract class _$$TaskDetailsLoadingEventCopyWith<$Res> {
  factory _$$TaskDetailsLoadingEventCopyWith(_$TaskDetailsLoadingEvent value,
          $Res Function(_$TaskDetailsLoadingEvent) then) =
      __$$TaskDetailsLoadingEventCopyWithImpl<$Res>;
  $Res call({String taskId});
}

/// @nodoc
class __$$TaskDetailsLoadingEventCopyWithImpl<$Res>
    extends _$TaskDetailsEventCopyWithImpl<$Res>
    implements _$$TaskDetailsLoadingEventCopyWith<$Res> {
  __$$TaskDetailsLoadingEventCopyWithImpl(_$TaskDetailsLoadingEvent _value,
      $Res Function(_$TaskDetailsLoadingEvent) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsLoadingEvent));

  @override
  _$TaskDetailsLoadingEvent get _value =>
      super._value as _$TaskDetailsLoadingEvent;

  @override
  $Res call({
    Object? taskId = freezed,
  }) {
    return _then(_$TaskDetailsLoadingEvent(
      taskId == freezed
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TaskDetailsLoadingEvent implements TaskDetailsLoadingEvent {
  _$TaskDetailsLoadingEvent(this.taskId);

  @override
  final String taskId;

  @override
  String toString() {
    return 'TaskDetailsEvent.loading(taskId: $taskId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsLoadingEvent &&
            DeepCollectionEquality().equals(other.taskId, taskId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, DeepCollectionEquality().hash(taskId));

  @JsonKey(ignore: true)
  @override
  _$$TaskDetailsLoadingEventCopyWith<_$TaskDetailsLoadingEvent> get copyWith =>
      __$$TaskDetailsLoadingEventCopyWithImpl<_$TaskDetailsLoadingEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String taskId) loading,
    required TResult Function(String tempTaskId) refresh,
    required TResult Function() onlyLoading,
  }) {
    return loading(taskId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
  }) {
    return loading?.call(taskId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(taskId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsLoadingEvent value) loading,
    required TResult Function(TaskDetailsRefreshEvent value) refresh,
    required TResult Function(TaskDetailsOnlyLoadingEvent value) onlyLoading,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsLoadingEvent implements TaskDetailsEvent {
  factory TaskDetailsLoadingEvent(final String taskId) =
      _$TaskDetailsLoadingEvent;

  String get taskId;
  @JsonKey(ignore: true)
  _$$TaskDetailsLoadingEventCopyWith<_$TaskDetailsLoadingEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TaskDetailsRefreshEventCopyWith<$Res> {
  factory _$$TaskDetailsRefreshEventCopyWith(_$TaskDetailsRefreshEvent value,
          $Res Function(_$TaskDetailsRefreshEvent) then) =
      __$$TaskDetailsRefreshEventCopyWithImpl<$Res>;
  $Res call({String tempTaskId});
}

/// @nodoc
class __$$TaskDetailsRefreshEventCopyWithImpl<$Res>
    extends _$TaskDetailsEventCopyWithImpl<$Res>
    implements _$$TaskDetailsRefreshEventCopyWith<$Res> {
  __$$TaskDetailsRefreshEventCopyWithImpl(_$TaskDetailsRefreshEvent _value,
      $Res Function(_$TaskDetailsRefreshEvent) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsRefreshEvent));

  @override
  _$TaskDetailsRefreshEvent get _value =>
      super._value as _$TaskDetailsRefreshEvent;

  @override
  $Res call({
    Object? tempTaskId = freezed,
  }) {
    return _then(_$TaskDetailsRefreshEvent(
      tempTaskId == freezed
          ? _value.tempTaskId
          : tempTaskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TaskDetailsRefreshEvent implements TaskDetailsRefreshEvent {
  _$TaskDetailsRefreshEvent(this.tempTaskId);

  @override
  final String tempTaskId;

  @override
  String toString() {
    return 'TaskDetailsEvent.refresh(tempTaskId: $tempTaskId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsRefreshEvent &&
            DeepCollectionEquality()
                .equals(other.tempTaskId, tempTaskId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, DeepCollectionEquality().hash(tempTaskId));

  @JsonKey(ignore: true)
  @override
  _$$TaskDetailsRefreshEventCopyWith<_$TaskDetailsRefreshEvent> get copyWith =>
      __$$TaskDetailsRefreshEventCopyWithImpl<_$TaskDetailsRefreshEvent>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String taskId) loading,
    required TResult Function(String tempTaskId) refresh,
    required TResult Function() onlyLoading,
  }) {
    return refresh(tempTaskId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
  }) {
    return refresh?.call(tempTaskId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
    required TResult orElse(),
  }) {
    if (refresh != null) {
      return refresh(tempTaskId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsLoadingEvent value) loading,
    required TResult Function(TaskDetailsRefreshEvent value) refresh,
    required TResult Function(TaskDetailsOnlyLoadingEvent value) onlyLoading,
  }) {
    return refresh(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
  }) {
    return refresh?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
    required TResult orElse(),
  }) {
    if (refresh != null) {
      return refresh(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsRefreshEvent implements TaskDetailsEvent {
  factory TaskDetailsRefreshEvent(final String tempTaskId) =
      _$TaskDetailsRefreshEvent;

  String get tempTaskId;
  @JsonKey(ignore: true)
  _$$TaskDetailsRefreshEventCopyWith<_$TaskDetailsRefreshEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TaskDetailsOnlyLoadingEventCopyWith<$Res> {
  factory _$$TaskDetailsOnlyLoadingEventCopyWith(
          _$TaskDetailsOnlyLoadingEvent value,
          $Res Function(_$TaskDetailsOnlyLoadingEvent) then) =
      __$$TaskDetailsOnlyLoadingEventCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TaskDetailsOnlyLoadingEventCopyWithImpl<$Res>
    extends _$TaskDetailsEventCopyWithImpl<$Res>
    implements _$$TaskDetailsOnlyLoadingEventCopyWith<$Res> {
  __$$TaskDetailsOnlyLoadingEventCopyWithImpl(
      _$TaskDetailsOnlyLoadingEvent _value,
      $Res Function(_$TaskDetailsOnlyLoadingEvent) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsOnlyLoadingEvent));

  @override
  _$TaskDetailsOnlyLoadingEvent get _value =>
      super._value as _$TaskDetailsOnlyLoadingEvent;
}

/// @nodoc

class _$TaskDetailsOnlyLoadingEvent implements TaskDetailsOnlyLoadingEvent {
  _$TaskDetailsOnlyLoadingEvent();

  @override
  String toString() {
    return 'TaskDetailsEvent.onlyLoading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsOnlyLoadingEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String taskId) loading,
    required TResult Function(String tempTaskId) refresh,
    required TResult Function() onlyLoading,
  }) {
    return onlyLoading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
  }) {
    return onlyLoading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String taskId)? loading,
    TResult Function(String tempTaskId)? refresh,
    TResult Function()? onlyLoading,
    required TResult orElse(),
  }) {
    if (onlyLoading != null) {
      return onlyLoading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsLoadingEvent value) loading,
    required TResult Function(TaskDetailsRefreshEvent value) refresh,
    required TResult Function(TaskDetailsOnlyLoadingEvent value) onlyLoading,
  }) {
    return onlyLoading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
  }) {
    return onlyLoading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingEvent value)? loading,
    TResult Function(TaskDetailsRefreshEvent value)? refresh,
    TResult Function(TaskDetailsOnlyLoadingEvent value)? onlyLoading,
    required TResult orElse(),
  }) {
    if (onlyLoading != null) {
      return onlyLoading(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsOnlyLoadingEvent implements TaskDetailsEvent {
  factory TaskDetailsOnlyLoadingEvent() = _$TaskDetailsOnlyLoadingEvent;
}

/// @nodoc
mixin _$TaskDetailsState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Order> orders, TaskModel task) loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsInitialState value) initial,
    required TResult Function(TaskDetailsLoadingState value) loading,
    required TResult Function(TaskDetailsLoadedState value) loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskDetailsStateCopyWith<$Res> {
  factory $TaskDetailsStateCopyWith(
          TaskDetailsState value, $Res Function(TaskDetailsState) then) =
      _$TaskDetailsStateCopyWithImpl<$Res>;
}

/// @nodoc
class _$TaskDetailsStateCopyWithImpl<$Res>
    implements $TaskDetailsStateCopyWith<$Res> {
  _$TaskDetailsStateCopyWithImpl(this._value, this._then);

  final TaskDetailsState _value;
  // ignore: unused_field
  final $Res Function(TaskDetailsState) _then;
}

/// @nodoc
abstract class _$$TaskDetailsInitialStateCopyWith<$Res> {
  factory _$$TaskDetailsInitialStateCopyWith(_$TaskDetailsInitialState value,
          $Res Function(_$TaskDetailsInitialState) then) =
      __$$TaskDetailsInitialStateCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TaskDetailsInitialStateCopyWithImpl<$Res>
    extends _$TaskDetailsStateCopyWithImpl<$Res>
    implements _$$TaskDetailsInitialStateCopyWith<$Res> {
  __$$TaskDetailsInitialStateCopyWithImpl(_$TaskDetailsInitialState _value,
      $Res Function(_$TaskDetailsInitialState) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsInitialState));

  @override
  _$TaskDetailsInitialState get _value =>
      super._value as _$TaskDetailsInitialState;
}

/// @nodoc

class _$TaskDetailsInitialState implements TaskDetailsInitialState {
  _$TaskDetailsInitialState();

  @override
  String toString() {
    return 'TaskDetailsState.initial()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsInitialState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Order> orders, TaskModel task) loaded,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsInitialState value) initial,
    required TResult Function(TaskDetailsLoadingState value) loading,
    required TResult Function(TaskDetailsLoadedState value) loaded,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsInitialState implements TaskDetailsState {
  factory TaskDetailsInitialState() = _$TaskDetailsInitialState;
}

/// @nodoc
abstract class _$$TaskDetailsLoadingStateCopyWith<$Res> {
  factory _$$TaskDetailsLoadingStateCopyWith(_$TaskDetailsLoadingState value,
          $Res Function(_$TaskDetailsLoadingState) then) =
      __$$TaskDetailsLoadingStateCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TaskDetailsLoadingStateCopyWithImpl<$Res>
    extends _$TaskDetailsStateCopyWithImpl<$Res>
    implements _$$TaskDetailsLoadingStateCopyWith<$Res> {
  __$$TaskDetailsLoadingStateCopyWithImpl(_$TaskDetailsLoadingState _value,
      $Res Function(_$TaskDetailsLoadingState) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsLoadingState));

  @override
  _$TaskDetailsLoadingState get _value =>
      super._value as _$TaskDetailsLoadingState;
}

/// @nodoc

class _$TaskDetailsLoadingState implements TaskDetailsLoadingState {
  _$TaskDetailsLoadingState();

  @override
  String toString() {
    return 'TaskDetailsState.loading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsLoadingState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Order> orders, TaskModel task) loaded,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsInitialState value) initial,
    required TResult Function(TaskDetailsLoadingState value) loading,
    required TResult Function(TaskDetailsLoadedState value) loaded,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsLoadingState implements TaskDetailsState {
  factory TaskDetailsLoadingState() = _$TaskDetailsLoadingState;
}

/// @nodoc
abstract class _$$TaskDetailsLoadedStateCopyWith<$Res> {
  factory _$$TaskDetailsLoadedStateCopyWith(_$TaskDetailsLoadedState value,
          $Res Function(_$TaskDetailsLoadedState) then) =
      __$$TaskDetailsLoadedStateCopyWithImpl<$Res>;
  $Res call({List<Order> orders, TaskModel task});
}

/// @nodoc
class __$$TaskDetailsLoadedStateCopyWithImpl<$Res>
    extends _$TaskDetailsStateCopyWithImpl<$Res>
    implements _$$TaskDetailsLoadedStateCopyWith<$Res> {
  __$$TaskDetailsLoadedStateCopyWithImpl(_$TaskDetailsLoadedState _value,
      $Res Function(_$TaskDetailsLoadedState) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsLoadedState));

  @override
  _$TaskDetailsLoadedState get _value =>
      super._value as _$TaskDetailsLoadedState;

  @override
  $Res call({
    Object? orders = freezed,
    Object? task = freezed,
  }) {
    return _then(_$TaskDetailsLoadedState(
      orders == freezed
          ? _value._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<Order>,
      task == freezed
          ? _value.task
          : task // ignore: cast_nullable_to_non_nullable
              as TaskModel,
    ));
  }
}

/// @nodoc

class _$TaskDetailsLoadedState implements TaskDetailsLoadedState {
  _$TaskDetailsLoadedState(final List<Order> orders, this.task)
      : _orders = orders;

  final List<Order> _orders;
  @override
  List<Order> get orders {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  @override
  final TaskModel task;

  @override
  String toString() {
    return 'TaskDetailsState.loaded(orders: $orders, task: $task)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsLoadedState &&
            DeepCollectionEquality().equals(other._orders, _orders) &&
            DeepCollectionEquality().equals(other.task, task));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      DeepCollectionEquality().hash(_orders),
      DeepCollectionEquality().hash(task));

  @JsonKey(ignore: true)
  @override
  _$$TaskDetailsLoadedStateCopyWith<_$TaskDetailsLoadedState> get copyWith =>
      __$$TaskDetailsLoadedStateCopyWithImpl<_$TaskDetailsLoadedState>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<Order> orders, TaskModel task) loaded,
  }) {
    return loaded(orders, task);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
  }) {
    return loaded?.call(orders, task);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<Order> orders, TaskModel task)? loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(orders, task);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsInitialState value) initial,
    required TResult Function(TaskDetailsLoadingState value) loading,
    required TResult Function(TaskDetailsLoadedState value) loaded,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsInitialState value)? initial,
    TResult Function(TaskDetailsLoadingState value)? loading,
    TResult Function(TaskDetailsLoadedState value)? loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsLoadedState implements TaskDetailsState {
  factory TaskDetailsLoadedState(
          final List<Order> orders, final TaskModel task) =
      _$TaskDetailsLoadedState;

  List<Order> get orders;
  TaskModel get task;
  @JsonKey(ignore: true)
  _$$TaskDetailsLoadedStateCopyWith<_$TaskDetailsLoadedState> get copyWith =>
      throw _privateConstructorUsedError;
}
