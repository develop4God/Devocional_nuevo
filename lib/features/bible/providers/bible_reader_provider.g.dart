// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bibleReaderHash() => r'c48672e51edd238ea8ff35964597c9c51842c7ac';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$BibleReader
    extends BuildlessAutoDisposeAsyncNotifier<BibleReaderState> {
  late final List<BibleVersion> versions;

  FutureOr<BibleReaderState> build(
    List<BibleVersion> versions,
  );
}

/// See also [BibleReader].
@ProviderFor(BibleReader)
const bibleReaderProvider = BibleReaderFamily();

/// See also [BibleReader].
class BibleReaderFamily extends Family<AsyncValue<BibleReaderState>> {
  /// See also [BibleReader].
  const BibleReaderFamily();

  /// See also [BibleReader].
  BibleReaderProvider call(
    List<BibleVersion> versions,
  ) {
    return BibleReaderProvider(
      versions,
    );
  }

  @override
  BibleReaderProvider getProviderOverride(
    covariant BibleReaderProvider provider,
  ) {
    return call(
      provider.versions,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bibleReaderProvider';
}

/// See also [BibleReader].
class BibleReaderProvider extends AutoDisposeAsyncNotifierProviderImpl<
    BibleReader, BibleReaderState> {
  /// See also [BibleReader].
  BibleReaderProvider(
    List<BibleVersion> versions,
  ) : this._internal(
          () => BibleReader()..versions = versions,
          from: bibleReaderProvider,
          name: r'bibleReaderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bibleReaderHash,
          dependencies: BibleReaderFamily._dependencies,
          allTransitiveDependencies:
              BibleReaderFamily._allTransitiveDependencies,
          versions: versions,
        );

  BibleReaderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.versions,
  }) : super.internal();

  final List<BibleVersion> versions;

  @override
  FutureOr<BibleReaderState> runNotifierBuild(
    covariant BibleReader notifier,
  ) {
    return notifier.build(
      versions,
    );
  }

  @override
  Override overrideWith(BibleReader Function() create) {
    return ProviderOverride(
      origin: this,
      override: BibleReaderProvider._internal(
        () => create()..versions = versions,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        versions: versions,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<BibleReader, BibleReaderState>
      createElement() {
    return _BibleReaderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BibleReaderProvider && other.versions == versions;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, versions.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BibleReaderRef on AutoDisposeAsyncNotifierProviderRef<BibleReaderState> {
  /// The parameter `versions` of this provider.
  List<BibleVersion> get versions;
}

class _BibleReaderProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BibleReader,
        BibleReaderState> with BibleReaderRef {
  _BibleReaderProviderElement(super.provider);

  @override
  List<BibleVersion> get versions => (origin as BibleReaderProvider).versions;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
