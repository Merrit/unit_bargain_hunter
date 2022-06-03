import 'dart:convert';

class Source {
  String? type;
  String? url;
  String? sha256;
  String? tag;
  String? path;

  Source({this.type, this.url, this.sha256, this.tag, this.path});

  @override
  String toString() {
    return 'Source(type: $type, url: $url, sha256: $sha256, tag: $tag, path: $path)';
  }

  factory Source.fromMap(Map<String, dynamic> data) => Source(
        type: data['type'] as String?,
        url: data['url'] as String?,
        sha256: data['sha256'] as String?,
        tag: data['tag'] as String?,
        path: data['path'] as String?,
      );

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    if (type != null) map['type'] = type;
    if (url != null) map['url'] = url;
    if (sha256 != null) map['sha256'] = sha256;
    if (tag != null) map['tag'] = tag;
    if (path != null) map['path'] = path;
    return map;
  }

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Source].
  factory Source.fromJson(String data) {
    return Source.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Source] to a JSON string.
  String toJson() => json.encode(toMap());

  Source copyWith({
    String? type,
    String? url,
    String? sha256,
    String? tag,
    String? path,
  }) {
    return Source(
      type: type ?? this.type,
      url: url ?? this.url,
      sha256: sha256 ?? this.sha256,
      tag: tag ?? this.tag,
      path: path ?? this.path,
    );
  }
}
