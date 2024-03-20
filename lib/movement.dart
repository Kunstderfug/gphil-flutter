class Movement {
  String key;
  bool authRequired;
  int index;
  String title;
  List sections;

  Movement(this.key, this.authRequired, this.index, this.title, this.sections);

  factory Movement.fromJson(Map<String, dynamic> json) {
    return Movement(json['_key'], json['authRequired'], json['index'],
        json['title'], json['sections']);
  }
}
