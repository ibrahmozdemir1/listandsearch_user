class UsersPhoto {
  String? id;
  String? author;
  int? width;
  int? height;
  String? url;
  // ignore: non_constant_identifier_names
  String? download_url;

  UsersPhoto(
      {this.id,
      this.author,
      this.width,
      this.height,
      this.url,
      // ignore: non_constant_identifier_names
      this.download_url});

  UsersPhoto.fromJson(Map json) {
    id = json['id'];
    author = json['author'];
    width = json['width'];
    height = json['height'];
    url = json['url'];
    download_url = json['download_url'];
  }
}
