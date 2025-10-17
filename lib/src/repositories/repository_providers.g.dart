// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ファイルリポジトリプロバイダー

@ProviderFor(fileRepository)
const fileRepositoryProvider = FileRepositoryProvider._();

/// ファイルリポジトリプロバイダー

final class FileRepositoryProvider
    extends $FunctionalProvider<FileRepository, FileRepository, FileRepository>
    with $Provider<FileRepository> {
  /// ファイルリポジトリプロバイダー
  const FileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileRepositoryHash();

  @$internal
  @override
  $ProviderElement<FileRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileRepository create(Ref ref) {
    return fileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileRepository>(value),
    );
  }
}

String _$fileRepositoryHash() => r'f171032110770292fa8060860dad7db8b714b362';

/// ストレージリポジトリプロバイダー

@ProviderFor(storageRepository)
const storageRepositoryProvider = StorageRepositoryProvider._();

/// ストレージリポジトリプロバイダー

final class StorageRepositoryProvider
    extends
        $FunctionalProvider<
          StorageRepository,
          StorageRepository,
          StorageRepository
        >
    with $Provider<StorageRepository> {
  /// ストレージリポジトリプロバイダー
  const StorageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageRepositoryHash();

  @$internal
  @override
  $ProviderElement<StorageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StorageRepository create(Ref ref) {
    return storageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageRepository>(value),
    );
  }
}

String _$storageRepositoryHash() => r'b8261101ce269a2a3682426eafbc1691b5635a44';
