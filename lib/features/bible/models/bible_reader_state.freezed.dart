// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_reader_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BibleReaderState {
  BibleVersion get selectedVersion => throw _privateConstructorUsedError;
  List<BibleVersion> get availableVersions =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get books => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get verses => throw _privateConstructorUsedError;
  Set<String> get selectedVerses =>
      throw _privateConstructorUsedError; // Format: "bookName|chapter|verse"
  Set<String> get markedVerses =>
      throw _privateConstructorUsedError; // Persisted to SharedPreferences
  String? get selectedBookName => throw _privateConstructorUsedError;
  int? get selectedBookNumber => throw _privateConstructorUsedError;
  int? get selectedChapter => throw _privateConstructorUsedError;
  int? get selectedVerse => throw _privateConstructorUsedError;
  int get maxChapter => throw _privateConstructorUsedError;
  int get maxVerse => throw _privateConstructorUsedError;
  double get fontSize => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;
  bool get showFontControls => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get searchResults =>
      throw _privateConstructorUsedError;

  /// Create a copy of BibleReaderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BibleReaderStateCopyWith<BibleReaderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleReaderStateCopyWith<$Res> {
  factory $BibleReaderStateCopyWith(
          BibleReaderState value, $Res Function(BibleReaderState) then) =
      _$BibleReaderStateCopyWithImpl<$Res, BibleReaderState>;
  @useResult
  $Res call(
      {BibleVersion selectedVersion,
      List<BibleVersion> availableVersions,
      List<Map<String, dynamic>> books,
      List<Map<String, dynamic>> verses,
      Set<String> selectedVerses,
      Set<String> markedVerses,
      String? selectedBookName,
      int? selectedBookNumber,
      int? selectedChapter,
      int? selectedVerse,
      int maxChapter,
      int maxVerse,
      double fontSize,
      bool isLoading,
      bool isSearching,
      bool showFontControls,
      List<Map<String, dynamic>> searchResults});
}

/// @nodoc
class _$BibleReaderStateCopyWithImpl<$Res, $Val extends BibleReaderState>
    implements $BibleReaderStateCopyWith<$Res> {
  _$BibleReaderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BibleReaderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedVersion = null,
    Object? availableVersions = null,
    Object? books = null,
    Object? verses = null,
    Object? selectedVerses = null,
    Object? markedVerses = null,
    Object? selectedBookName = freezed,
    Object? selectedBookNumber = freezed,
    Object? selectedChapter = freezed,
    Object? selectedVerse = freezed,
    Object? maxChapter = null,
    Object? maxVerse = null,
    Object? fontSize = null,
    Object? isLoading = null,
    Object? isSearching = null,
    Object? showFontControls = null,
    Object? searchResults = null,
  }) {
    return _then(_value.copyWith(
      selectedVersion: null == selectedVersion
          ? _value.selectedVersion
          : selectedVersion // ignore: cast_nullable_to_non_nullable
              as BibleVersion,
      availableVersions: null == availableVersions
          ? _value.availableVersions
          : availableVersions // ignore: cast_nullable_to_non_nullable
              as List<BibleVersion>,
      books: null == books
          ? _value.books
          : books // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      verses: null == verses
          ? _value.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      selectedVerses: null == selectedVerses
          ? _value.selectedVerses
          : selectedVerses // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      markedVerses: null == markedVerses
          ? _value.markedVerses
          : markedVerses // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      selectedBookName: freezed == selectedBookName
          ? _value.selectedBookName
          : selectedBookName // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBookNumber: freezed == selectedBookNumber
          ? _value.selectedBookNumber
          : selectedBookNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedChapter: freezed == selectedChapter
          ? _value.selectedChapter
          : selectedChapter // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedVerse: freezed == selectedVerse
          ? _value.selectedVerse
          : selectedVerse // ignore: cast_nullable_to_non_nullable
              as int?,
      maxChapter: null == maxChapter
          ? _value.maxChapter
          : maxChapter // ignore: cast_nullable_to_non_nullable
              as int,
      maxVerse: null == maxVerse
          ? _value.maxVerse
          : maxVerse // ignore: cast_nullable_to_non_nullable
              as int,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      showFontControls: null == showFontControls
          ? _value.showFontControls
          : showFontControls // ignore: cast_nullable_to_non_nullable
              as bool,
      searchResults: null == searchResults
          ? _value.searchResults
          : searchResults // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BibleReaderStateImplCopyWith<$Res>
    implements $BibleReaderStateCopyWith<$Res> {
  factory _$$BibleReaderStateImplCopyWith(_$BibleReaderStateImpl value,
          $Res Function(_$BibleReaderStateImpl) then) =
      __$$BibleReaderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BibleVersion selectedVersion,
      List<BibleVersion> availableVersions,
      List<Map<String, dynamic>> books,
      List<Map<String, dynamic>> verses,
      Set<String> selectedVerses,
      Set<String> markedVerses,
      String? selectedBookName,
      int? selectedBookNumber,
      int? selectedChapter,
      int? selectedVerse,
      int maxChapter,
      int maxVerse,
      double fontSize,
      bool isLoading,
      bool isSearching,
      bool showFontControls,
      List<Map<String, dynamic>> searchResults});
}

/// @nodoc
class __$$BibleReaderStateImplCopyWithImpl<$Res>
    extends _$BibleReaderStateCopyWithImpl<$Res, _$BibleReaderStateImpl>
    implements _$$BibleReaderStateImplCopyWith<$Res> {
  __$$BibleReaderStateImplCopyWithImpl(_$BibleReaderStateImpl _value,
      $Res Function(_$BibleReaderStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BibleReaderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedVersion = null,
    Object? availableVersions = null,
    Object? books = null,
    Object? verses = null,
    Object? selectedVerses = null,
    Object? markedVerses = null,
    Object? selectedBookName = freezed,
    Object? selectedBookNumber = freezed,
    Object? selectedChapter = freezed,
    Object? selectedVerse = freezed,
    Object? maxChapter = null,
    Object? maxVerse = null,
    Object? fontSize = null,
    Object? isLoading = null,
    Object? isSearching = null,
    Object? showFontControls = null,
    Object? searchResults = null,
  }) {
    return _then(_$BibleReaderStateImpl(
      selectedVersion: null == selectedVersion
          ? _value.selectedVersion
          : selectedVersion // ignore: cast_nullable_to_non_nullable
              as BibleVersion,
      availableVersions: null == availableVersions
          ? _value._availableVersions
          : availableVersions // ignore: cast_nullable_to_non_nullable
              as List<BibleVersion>,
      books: null == books
          ? _value._books
          : books // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      verses: null == verses
          ? _value._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      selectedVerses: null == selectedVerses
          ? _value._selectedVerses
          : selectedVerses // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      markedVerses: null == markedVerses
          ? _value._markedVerses
          : markedVerses // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      selectedBookName: freezed == selectedBookName
          ? _value.selectedBookName
          : selectedBookName // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBookNumber: freezed == selectedBookNumber
          ? _value.selectedBookNumber
          : selectedBookNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedChapter: freezed == selectedChapter
          ? _value.selectedChapter
          : selectedChapter // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedVerse: freezed == selectedVerse
          ? _value.selectedVerse
          : selectedVerse // ignore: cast_nullable_to_non_nullable
              as int?,
      maxChapter: null == maxChapter
          ? _value.maxChapter
          : maxChapter // ignore: cast_nullable_to_non_nullable
              as int,
      maxVerse: null == maxVerse
          ? _value.maxVerse
          : maxVerse // ignore: cast_nullable_to_non_nullable
              as int,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      showFontControls: null == showFontControls
          ? _value.showFontControls
          : showFontControls // ignore: cast_nullable_to_non_nullable
              as bool,
      searchResults: null == searchResults
          ? _value._searchResults
          : searchResults // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// @nodoc

class _$BibleReaderStateImpl implements _BibleReaderState {
  const _$BibleReaderStateImpl(
      {required this.selectedVersion,
      required final List<BibleVersion> availableVersions,
      final List<Map<String, dynamic>> books = const [],
      final List<Map<String, dynamic>> verses = const [],
      final Set<String> selectedVerses = const {},
      final Set<String> markedVerses = const {},
      this.selectedBookName,
      this.selectedBookNumber,
      this.selectedChapter,
      this.selectedVerse,
      this.maxChapter = 1,
      this.maxVerse = 1,
      this.fontSize = 18.0,
      this.isLoading = false,
      this.isSearching = false,
      this.showFontControls = false,
      final List<Map<String, dynamic>> searchResults = const []})
      : _availableVersions = availableVersions,
        _books = books,
        _verses = verses,
        _selectedVerses = selectedVerses,
        _markedVerses = markedVerses,
        _searchResults = searchResults;

  @override
  final BibleVersion selectedVersion;
  final List<BibleVersion> _availableVersions;
  @override
  List<BibleVersion> get availableVersions {
    if (_availableVersions is EqualUnmodifiableListView)
      return _availableVersions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableVersions);
  }

  final List<Map<String, dynamic>> _books;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get books {
    if (_books is EqualUnmodifiableListView) return _books;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_books);
  }

  final List<Map<String, dynamic>> _verses;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  final Set<String> _selectedVerses;
  @override
  @JsonKey()
  Set<String> get selectedVerses {
    if (_selectedVerses is EqualUnmodifiableSetView) return _selectedVerses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedVerses);
  }

// Format: "bookName|chapter|verse"
  final Set<String> _markedVerses;
// Format: "bookName|chapter|verse"
  @override
  @JsonKey()
  Set<String> get markedVerses {
    if (_markedVerses is EqualUnmodifiableSetView) return _markedVerses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_markedVerses);
  }

// Persisted to SharedPreferences
  @override
  final String? selectedBookName;
  @override
  final int? selectedBookNumber;
  @override
  final int? selectedChapter;
  @override
  final int? selectedVerse;
  @override
  @JsonKey()
  final int maxChapter;
  @override
  @JsonKey()
  final int maxVerse;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSearching;
  @override
  @JsonKey()
  final bool showFontControls;
  final List<Map<String, dynamic>> _searchResults;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get searchResults {
    if (_searchResults is EqualUnmodifiableListView) return _searchResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResults);
  }

  @override
  String toString() {
    return 'BibleReaderState(selectedVersion: $selectedVersion, availableVersions: $availableVersions, books: $books, verses: $verses, selectedVerses: $selectedVerses, markedVerses: $markedVerses, selectedBookName: $selectedBookName, selectedBookNumber: $selectedBookNumber, selectedChapter: $selectedChapter, selectedVerse: $selectedVerse, maxChapter: $maxChapter, maxVerse: $maxVerse, fontSize: $fontSize, isLoading: $isLoading, isSearching: $isSearching, showFontControls: $showFontControls, searchResults: $searchResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BibleReaderStateImpl &&
            (identical(other.selectedVersion, selectedVersion) ||
                other.selectedVersion == selectedVersion) &&
            const DeepCollectionEquality()
                .equals(other._availableVersions, _availableVersions) &&
            const DeepCollectionEquality().equals(other._books, _books) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            const DeepCollectionEquality()
                .equals(other._selectedVerses, _selectedVerses) &&
            const DeepCollectionEquality()
                .equals(other._markedVerses, _markedVerses) &&
            (identical(other.selectedBookName, selectedBookName) ||
                other.selectedBookName == selectedBookName) &&
            (identical(other.selectedBookNumber, selectedBookNumber) ||
                other.selectedBookNumber == selectedBookNumber) &&
            (identical(other.selectedChapter, selectedChapter) ||
                other.selectedChapter == selectedChapter) &&
            (identical(other.selectedVerse, selectedVerse) ||
                other.selectedVerse == selectedVerse) &&
            (identical(other.maxChapter, maxChapter) ||
                other.maxChapter == maxChapter) &&
            (identical(other.maxVerse, maxVerse) ||
                other.maxVerse == maxVerse) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.showFontControls, showFontControls) ||
                other.showFontControls == showFontControls) &&
            const DeepCollectionEquality()
                .equals(other._searchResults, _searchResults));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedVersion,
      const DeepCollectionEquality().hash(_availableVersions),
      const DeepCollectionEquality().hash(_books),
      const DeepCollectionEquality().hash(_verses),
      const DeepCollectionEquality().hash(_selectedVerses),
      const DeepCollectionEquality().hash(_markedVerses),
      selectedBookName,
      selectedBookNumber,
      selectedChapter,
      selectedVerse,
      maxChapter,
      maxVerse,
      fontSize,
      isLoading,
      isSearching,
      showFontControls,
      const DeepCollectionEquality().hash(_searchResults));

  /// Create a copy of BibleReaderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BibleReaderStateImplCopyWith<_$BibleReaderStateImpl> get copyWith =>
      __$$BibleReaderStateImplCopyWithImpl<_$BibleReaderStateImpl>(
          this, _$identity);
}

abstract class _BibleReaderState implements BibleReaderState {
  const factory _BibleReaderState(
      {required final BibleVersion selectedVersion,
      required final List<BibleVersion> availableVersions,
      final List<Map<String, dynamic>> books,
      final List<Map<String, dynamic>> verses,
      final Set<String> selectedVerses,
      final Set<String> markedVerses,
      final String? selectedBookName,
      final int? selectedBookNumber,
      final int? selectedChapter,
      final int? selectedVerse,
      final int maxChapter,
      final int maxVerse,
      final double fontSize,
      final bool isLoading,
      final bool isSearching,
      final bool showFontControls,
      final List<Map<String, dynamic>> searchResults}) = _$BibleReaderStateImpl;

  @override
  BibleVersion get selectedVersion;
  @override
  List<BibleVersion> get availableVersions;
  @override
  List<Map<String, dynamic>> get books;
  @override
  List<Map<String, dynamic>> get verses;
  @override
  Set<String> get selectedVerses; // Format: "bookName|chapter|verse"
  @override
  Set<String> get markedVerses; // Persisted to SharedPreferences
  @override
  String? get selectedBookName;
  @override
  int? get selectedBookNumber;
  @override
  int? get selectedChapter;
  @override
  int? get selectedVerse;
  @override
  int get maxChapter;
  @override
  int get maxVerse;
  @override
  double get fontSize;
  @override
  bool get isLoading;
  @override
  bool get isSearching;
  @override
  bool get showFontControls;
  @override
  List<Map<String, dynamic>> get searchResults;

  /// Create a copy of BibleReaderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BibleReaderStateImplCopyWith<_$BibleReaderStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
