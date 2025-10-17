// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemoNotifier)
const memoProvider = MemoNotifierProvider._();

final class MemoNotifierProvider
    extends $NotifierProvider<MemoNotifier, MemoState> {
  const MemoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoNotifierHash();

  @$internal
  @override
  MemoNotifier create() => MemoNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoState>(value),
    );
  }
}

String _$memoNotifierHash() => r'8e382fc581103db06444d4eda78268bb74cb2dbe';

abstract class _$MemoNotifier extends $Notifier<MemoState> {
  MemoState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MemoState, MemoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemoState, MemoState>,
              MemoState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
