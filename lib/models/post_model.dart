import 'dart:convert';

class Post {
  String? uid;
  String? fullName;
  String? imgUser;
  String? id;
  String? imgPost;
  String? caption;
  String? date;

  bool liked = false;
  bool mine = false;

  Post({required this.imgPost, required this.caption});

  Post.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        fullName = json['fullName'],
        imgUser = json['img_user'],
        imgPost = json['img_post'],
        id = json['id'],
        caption = json['caption'],
        date = json['date'],
        liked = json['liked'];

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'fullName': fullName,
        'img_user': imgUser,
        'id': id,
        'img_post': imgPost,
        'caption': caption,
        'date': date,
        'liked': liked,
      };

  static String encode(List<Post> posts) => json.encode(
    posts.map<Map<String, dynamic>>((post) => post.toJson()).toList(),
  );

  static List<Post> decode(String posts) =>
      json.decode(posts).map<Post>((item) => Post.fromJson(item)).toList();
}
