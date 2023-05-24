// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'task_details_loading_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$TaskDetailsLoadingEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(String taskId) fetching,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(String taskId)? fetching,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(String taskId)? fetching,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsLoadingLoaderEvent value) loading,
    required TResult Function(TaskDetailsLoadingFetchEvent value) fetching,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingLoaderEvent value)? loading,
    TResult Function(TaskDetailsLoadingFetchEvent value)? fetching,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingLoaderEvent value)? loading,
    TResult Function(TaskDetailsLoadingFetchEvent value)? fetching,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskDetailsLoadingEventCopyWith<$Res> {
  factory $TaskDetailsLoadingEventCopyWith(TaskDetailsLoadingEvent value,
          $Res Function(TaskDetailsLoadingEvent) then) =
      _$TaskDetailsLoadingEventCopyWithImpl<$Res>;
}

/// @nodoc
class _$TaskDetailsLoadingEventCopyWithImpl<$Res>
    implements $TaskDetailsLoadingEventCopyWith<$Res> {
  _$TaskDetailsLoadingEventCopyWithImpl(this._value, this._then);

  final TaskDetailsLoadingEvent _value;
  // ignore: unused_field
  final $Res Function(TaskDetailsLoadingEvent) _then;
}

/// @nodoc
abstract class _$$TaskDetailsLoadingLoaderEventCopyWith<$Res> {
  factory _$$TaskDetailsLoadingLoaderEventCopyWith(
          _$TaskDetailsLoadingLoaderEvent value,
          $Res Function(_$TaskDetailsLoadingLoaderEvent) then) =
      __$$TaskDetailsLoadingLoaderEventCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TaskDetailsLoadingLoaderEventCopyWithImpl<$Res>
    extends _$TaskDetailsLoadingEventCopyWithImpl<$Res>
    implements _$$TaskDetailsLoadingLoaderEventCopyWith<$Res> {
  __$$TaskDetailsLoadingLoaderEventCopyWithImpl(
      _$TaskDetailsLoadingLoaderEvent _value,
      $Res Function(_$TaskDetailsLoadingLoaderEvent) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsLoadingLoaderEvent));

  @override
  _$TaskDetailsLoadingLoaderEvent get _value =>
      super._value as _$TaskDetailsLoadingLoaderEvent;
}

/// @nodoc

class _$TaskDetailsLoadingLoaderEvent implements TaskDetailsLoadingLoaderEvent {
  _$TaskDetailsLoadingLoaderEvent();

  @override
  String toString() {
    return 'TaskDetailsLoadingEvent.loading()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsLoadingLoaderEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(String taskId) fetching,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(String taskId)? fetching,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(String taskId)? fetching,
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
    required TResult Function(TaskDetailsLoadingLoaderEvent value) loading,
    required TResult Function(TaskDetailsLoadingFetchEvent value) fetching,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingLoaderEvent value)? loading,
    TResult Function(TaskDetailsLoadingFetchEvent value)? fetching,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingLoaderEvent value)? loading,
    TResult Function(TaskDetailsLoadingFetchEvent value)? fetching,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsLoadingLoaderEvent
    implements TaskDetailsLoadingEvent {
  factory TaskDetailsLoadingLoaderEvent() =
      _$TaskDetailsLoadingLoaderEvent;
}

/// @nodoc
abstract class _$$TaskDetailsLoadingFetchEventCopyWith<$Res> {
  factory _$$TaskDetailsLoadingFetchEventCopyWith(
          _$TaskDetailsLoadingFetchEvent value,
          $Res Function(_$TaskDetailsLoadingFetchEvent) then) =
      __$$TaskDetailsLoadingFetchEventCopyWithImpl<$Res>;
  $Res call({String taskId});
}

/// @nodoc
class __$$TaskDetailsLoadingFetchEventCopyWithImpl<$Res>
    extends _$TaskDetailsLoadingEventCopyWithImpl<$Res>
    implements _$$TaskDetailsLoadingFetchEventCopyWith<$Res> {
  __$$TaskDetailsLoadingFetchEventCopyWithImpl(
      _$TaskDetailsLoadingFetchEvent _value,
      $Res Function(_$TaskDetailsLoadingFetchEvent) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsLoadingFetchEvent));

  @override
  _$TaskDetailsLoadingFetchEvent get _value =>
      super._value as _$TaskDetailsLoadingFetchEvent;

  @override
  $Res call({
    Object? taskId = freezed,
  }) {
    return _then(_$TaskDetailsLoadingFetchEvent(
      taskId == freezed
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TaskDetailsLoadingFetchEvent implements TaskDetailsLoadingFetchEvent {
  _$TaskDetailsLoadingFetchEvent(this.taskId);

  @override
  final String taskId;

  @override
  String toString() {
    return 'TaskDetailsLoadingEvent.fetching(taskId: $taskId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsLoadingFetchEvent &&
            DeepCollectionEquality().equals(other.taskId, taskId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, DeepCollectionEquality().hash(taskId));

  @JsonKey(ignore: true)
  @override
  _$$TaskDetailsLoadingFetchEventCopyWith<_$TaskDetailsLoadingFetchEvent>
      get copyWith => __$$TaskDetailsLoadingFetchEventCopyWithImpl<
          _$TaskDetailsLoadingFetchEvent>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(String taskId) fetching,
  }) {
    return fetching(taskId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(String taskId)? fetching,
  }) {
    return fetching?.call(taskId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(String taskId)? fetching,
    required TResult orElse(),
  }) {
    if (fetching != null) {
      return fetching(taskId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsLoadingLoaderEvent value) loading,
    required TResult Function(TaskDetailsLoadingFetchEvent value) fetching,
  }) {
    return fetching(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingLoaderEvent value)? loading,
    TResult Function(TaskDetailsLoadingFetchEvent value)? fetching,
  }) {
    return fetching?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsLoadingLoaderEvent value)? loading,
    TResult Function(TaskDetailsLoadingFetchEvent value)? fetching,
    required TResult orElse(),
  }) {
    if (fetching != null) {
      return fetching(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsLoadingFetchEvent implements TaskDetailsLoadingEvent {
  factory TaskDetailsLoadingFetchEvent(final String taskId) =
      _$TaskDetailsLoadingFetchEvent;

  String get taskId;
  @JsonKey(ignore: true)
  _$$TaskDetailsLoadingFetchEventCopyWith<_$TaskDetailsLoadingFetchEvent>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TaskDetailsLoadingState {
  TaskDetailLoadingStatus get taskDetailLoadingStatus =>
      throw _privateConstructorUsedError;
  List<TaskModel> get task => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TaskDetailLoadingStatus taskDetailLoadingStatus,
            List<TaskModel> task)
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(TaskDetailLoadingStatus taskDetailLoadingStatus,
            List<TaskModel> task)?
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TaskDetailLoadingStatus taskDetailLoadingStatus,
            List<TaskModel> task)?
        loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsFetchingState value) loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsFetchingState value)? loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsFetchingState value)? loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskDetailsLoadingStateCopyWith<TaskDetailsLoadingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskDetailsLoadingStateCopyWith<$Res> {
  factory $TaskDetailsLoadingStateCopyWith(TaskDetailsLoadingState value,
          $Res Function(TaskDetailsLoadingState) then) =
      _$TaskDetailsLoadingStateCopyWithImpl<$Res>;
  $Res call(
      {TaskDetailLoadingStatus taskDetailLoadingStatus, List<TaskModel> task});
}

/// @nodoc
class _$TaskDetailsLoadingStateCopyWithImpl<$Res>
    implements $TaskDetailsLoadingStateCopyWith<$Res> {
  _$TaskDetailsLoadingStateCopyWithImpl(this._value, this._then);

  final TaskDetailsLoadingState _value;
  // ignore: unused_field
  final $Res Function(TaskDetailsLoadingState) _then;

  @override
  $Res call({
    Object? taskDetailLoadingStatus = freezed,
    Object? task = freezed,
  }) {
    return _then(_value.copyWith(
      taskDetailLoadingStatus: taskDetailLoadingStatus == freezed
          ? _value.taskDetailLoadingStatus
          : taskDetailLoadingStatus // ignore: cast_nullable_to_non_nullable
              as TaskDetailLoadingStatus,
      task: task == freezed
          ? _value.task
          : task // ignore: cast_nullable_to_non_nullable
              as List<TaskModel>,
    ));
  }
}

/// @nodoc
abstract class _$$TaskDetailsFetchingStateCopyWith<$Res>
    implements $TaskDetailsLoadingStateCopyWith<$Res> {
  factory _$$TaskDetailsFetchingStateCopyWith(_$TaskDetailsFetchingState value,
          $Res Function(_$TaskDetailsFetchingState) then) =
      __$$TaskDetailsFetchingStateCopyWithImpl<$Res>;
  @override
  $Res call(
      {TaskDetailLoadingStatus taskDetailLoadingStatus, List<TaskModel> task});
}

/// @nodoc
class __$$TaskDetailsFetchingStateCopyWithImpl<$Res>
    extends _$TaskDetailsLoadingStateCopyWithImpl<$Res>
    implements _$$TaskDetailsFetchingStateCopyWith<$Res> {
  __$$TaskDetailsFetchingStateCopyWithImpl(_$TaskDetailsFetchingState _value,
      $Res Function(_$TaskDetailsFetchingState) _then)
      : super(_value, (v) => _then(v as _$TaskDetailsFetchingState));

  @override
  _$TaskDetailsFetchingState get _value =>
      super._value as _$TaskDetailsFetchingState;

  @override
  $Res call({
    Object? taskDetailLoadingStatus = freezed,
    Object? task = freezed,
  }) {
    return _then(_$TaskDetailsFetchingState(
      taskDetailLoadingStatus == freezed
          ? _value.taskDetailLoadingStatus
          : taskDetailLoadingStatus // ignore: cast_nullable_to_non_nullable
              as TaskDetailLoadingStatus,
      task == freezed
          ? _value._task
          : task // ignore: cast_nullable_to_non_nullable
              as List<TaskModel>,
    ));
  }
}

/// @nodoc

class _$TaskDetailsFetchingState implements TaskDetailsFetchingState {
  _$TaskDetailsFetchingState(
      this.taskDetailLoadingStatus, final List<TaskModel> task)
      : _task = task;

  @override
  final TaskDetailLoadingStatus taskDetailLoadingStatus;
  final List<TaskModel> _task;
  @override
  List<TaskModel> get task {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_task);
  }

  @override
  String toString() {
    return 'TaskDetailsLoadingState.loaded(taskDetailLoadingStatus: $taskDetailLoadingStatus, task: $task)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDetailsFetchingState &&
            DeepCollectionEquality().equals(
                other.taskDetailLoadingStatus, taskDetailLoadingStatus) &&
            DeepCollectionEquality().equals(other._task, _task));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      DeepCollectionEquality().hash(taskDetailLoadingStatus),
      DeepCollectionEquality().hash(_task));

  @JsonKey(ignore: true)
  @override
  _$$TaskDetailsFetchingStateCopyWith<_$TaskDetailsFetchingState>
      get copyWith =>
          __$$TaskDetailsFetchingStateCopyWithImpl<_$TaskDetailsFetchingState>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TaskDetailLoadingStatus taskDetailLoadingStatus,
            List<TaskModel> task)
        loaded,
  }) {
    return loaded(taskDetailLoadingStatus, task);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(TaskDetailLoadingStatus taskDetailLoadingStatus,
            List<TaskModel> task)?
        loaded,
  }) {
    return loaded?.call(taskDetailLoadingStatus, task);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TaskDetailLoadingStatus taskDetailLoadingStatus,
            List<TaskModel> task)?
        loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(taskDetailLoadingStatus, task);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TaskDetailsFetchingState value) loaded,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TaskDetailsFetchingState value)? loaded,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TaskDetailsFetchingState value)? loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class TaskDetailsFetchingState implements TaskDetailsLoadingState {
  factory TaskDetailsFetchingState(
      final TaskDetailLoadingStatus taskDetailLoadingStatus,
      final List<TaskModel> task) = _$TaskDetailsFetchingState;

  @override
  TaskDetailLoadingStatus get taskDetailLoadingStatus;
  @override
  List<TaskModel> get task;
  @override
  @JsonKey(ignore: true)
  _$$TaskDetailsFetchingStateCopyWith<_$TaskDetailsFetchingState>
      get copyWith => throw _privateConstructorUsedError;
}
