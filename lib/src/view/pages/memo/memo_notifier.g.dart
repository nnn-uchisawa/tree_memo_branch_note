// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MemoNotifier)
final memoProvider = MemoNotifierProvider._();

final class MemoNotifierProvider
    extends $NotifierProvider<MemoNotifier, MemoState> {
  MemoNotifierProvider._()
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

String _$memoNotifierHash() => r'fb2fa747e4b23621ae1feb18c2f5e0aeeb432c4e';

abstract class _$MemoNotifier extends $Notifier<MemoState> {
  MemoState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MemoState, MemoState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemoState, MemoState>,
              MemoState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
