/// Data models for the DataLens search feature.
///
/// Supports three search modes: metadata search (object names), full-text
/// data search (row values), and DDL search (object definitions). Plain
/// Dart classes — no JSON serialization needed.
library;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Types of database objects that can be searched.
enum MetadataObjectType {
  /// Database table.
  table,

  /// Database view.
  view,

  /// Table or view column.
  column,

  /// Stored function.
  function_,

  /// Stored procedure.
  procedure,

  /// Sequence / auto-increment generator.
  sequence,

  /// Index on a table.
  index_,

  /// Constraint (PK, FK, UNIQUE, CHECK).
  constraint,

  /// Trigger.
  trigger,

  /// Schema / database.
  schema;

  /// Human-readable display label.
  String get label => switch (this) {
        MetadataObjectType.table => 'Table',
        MetadataObjectType.view => 'View',
        MetadataObjectType.column => 'Column',
        MetadataObjectType.function_ => 'Function',
        MetadataObjectType.procedure => 'Procedure',
        MetadataObjectType.sequence => 'Sequence',
        MetadataObjectType.index_ => 'Index',
        MetadataObjectType.constraint => 'Constraint',
        MetadataObjectType.trigger => 'Trigger',
        MetadataObjectType.schema => 'Schema',
      };

  /// Short label for chips.
  String get shortLabel => switch (this) {
        MetadataObjectType.table => 'Tables',
        MetadataObjectType.view => 'Views',
        MetadataObjectType.column => 'Columns',
        MetadataObjectType.function_ => 'Functions',
        MetadataObjectType.procedure => 'Procedures',
        MetadataObjectType.sequence => 'Sequences',
        MetadataObjectType.index_ => 'Indexes',
        MetadataObjectType.constraint => 'Constraints',
        MetadataObjectType.trigger => 'Triggers',
        MetadataObjectType.schema => 'Schemas',
      };
}

/// Active search mode in the search dialog.
enum SearchMode {
  /// Search database object names.
  metadata,

  /// Search row data across tables.
  data,

  /// Search DDL / object definitions.
  ddl;

  /// Human-readable label.
  String get label => switch (this) {
        SearchMode.metadata => 'Metadata',
        SearchMode.data => 'Data',
        SearchMode.ddl => 'DDL',
      };
}

// ---------------------------------------------------------------------------
// Metadata Search
// ---------------------------------------------------------------------------

/// A single metadata search result (object name match).
class MetadataSearchResult {
  /// Type of the matched object.
  final MetadataObjectType objectType;

  /// Schema containing the object.
  final String schema;

  /// Object name (table, view, function, etc.).
  final String objectName;

  /// Parent object name (table name when searching columns/indexes).
  final String? parentName;

  /// Data type (for columns).
  final String? dataType;

  /// Name with the matched portion marked for highlighting.
  final String matchHighlight;

  /// Creates a [MetadataSearchResult].
  const MetadataSearchResult({
    required this.objectType,
    required this.schema,
    required this.objectName,
    this.parentName,
    this.dataType,
    required this.matchHighlight,
  });
}

// ---------------------------------------------------------------------------
// Data Search
// ---------------------------------------------------------------------------

/// Results of searching row data in a single table+column.
class DataSearchResult {
  /// Schema name.
  final String schema;

  /// Table name.
  final String table;

  /// Column that matched.
  final String column;

  /// Number of matching rows found.
  final int rowCount;

  /// Sample of matching rows (up to maxRowsPerTable).
  final List<DataSearchRow> sampleRows;

  /// Creates a [DataSearchResult].
  const DataSearchResult({
    required this.schema,
    required this.table,
    required this.column,
    required this.rowCount,
    required this.sampleRows,
  });
}

/// A single matching row in a data search.
class DataSearchRow {
  /// Primary key values identifying the row.
  final Map<String, dynamic> primaryKey;

  /// The cell value that matched.
  final String matchedValue;

  /// Value with the matched portion marked for highlighting.
  final String matchHighlight;

  /// Creates a [DataSearchRow].
  const DataSearchRow({
    required this.primaryKey,
    required this.matchedValue,
    required this.matchHighlight,
  });
}

// ---------------------------------------------------------------------------
// DDL Search
// ---------------------------------------------------------------------------

/// A single DDL search result (match within an object definition).
class DdlSearchResult {
  /// Type of the matched object.
  final MetadataObjectType objectType;

  /// Schema containing the object.
  final String schema;

  /// Object name.
  final String objectName;

  /// Snippet of DDL containing the match (with context).
  final String ddlSnippet;

  /// Line number in the full DDL where the match was found.
  final int matchLine;

  /// Snippet with the matched portion marked for highlighting.
  final String matchHighlight;

  /// Creates a [DdlSearchResult].
  const DdlSearchResult({
    required this.objectType,
    required this.schema,
    required this.objectName,
    required this.ddlSnippet,
    required this.matchLine,
    required this.matchHighlight,
  });
}

// ---------------------------------------------------------------------------
// Search Options
// ---------------------------------------------------------------------------

/// Options controlling how a search is executed.
class SearchOptions {
  /// Active search mode.
  final SearchMode mode;

  /// Schema filter (null = all schemas).
  final String? schema;

  /// Object types to include (null = all types).
  final List<MetadataObjectType>? objectTypes;

  /// Case-sensitive matching.
  final bool caseSensitive;

  /// Treat query as a regex (data mode only).
  final bool regex;

  /// Max result count.
  final int limit;

  /// Max rows per table (data mode).
  final int maxRowsPerTable;

  /// Max tables to search (data mode).
  final int maxTables;

  /// Creates a [SearchOptions].
  const SearchOptions({
    this.mode = SearchMode.metadata,
    this.schema,
    this.objectTypes,
    this.caseSensitive = false,
    this.regex = false,
    this.limit = 100,
    this.maxRowsPerTable = 50,
    this.maxTables = 20,
  });

  /// Creates a copy with the given overrides.
  SearchOptions copyWith({
    SearchMode? mode,
    String? schema,
    List<MetadataObjectType>? objectTypes,
    bool? caseSensitive,
    bool? regex,
    int? limit,
    int? maxRowsPerTable,
    int? maxTables,
  }) {
    return SearchOptions(
      mode: mode ?? this.mode,
      schema: schema ?? this.schema,
      objectTypes: objectTypes ?? this.objectTypes,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      regex: regex ?? this.regex,
      limit: limit ?? this.limit,
      maxRowsPerTable: maxRowsPerTable ?? this.maxRowsPerTable,
      maxTables: maxTables ?? this.maxTables,
    );
  }
}

/// Progress information for a data search.
class DataSearchProgress {
  /// Current table being searched.
  final int currentTable;

  /// Total tables to search.
  final int totalTables;

  /// Name of the current table.
  final String? currentTableName;

  /// Creates a [DataSearchProgress].
  const DataSearchProgress({
    required this.currentTable,
    required this.totalTables,
    this.currentTableName,
  });
}
