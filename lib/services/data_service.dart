import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/models/user_model.dart';

import 'prefs_service.dart';

class DataService {
  static final _instance = FirebaseFirestore.instance;
  static const String _folderUsers = "users";
  static const String _folderPosts = "posts";
  static const String _folderFeeds = "feeds";

  static Future<void> storeUser(User user) async {
    user.uid = (await Prefs.load(StorageKeys.UID))!;
    return _instance.collection(_folderUsers).doc(user.uid).set(user.toJson());
  }

  static Future<User> loadUser() async {
    String _uid = (await Prefs.load(StorageKeys.UID))!;
    var value = await _instance.collection(_folderUsers).doc(_uid).get();
    return User.fromJson(value.data()!);
  }

  static Future<void> updateUser(User user) async {
    // String _uid = (await Prefs.load(StorageKeys.UID))!;
    return _instance
        .collection(_folderUsers)
        .doc(user.uid)
        .update(user.toJson());
  }

  static Future<List<User>> searchUsers(String keyword) async {
    User user = await loadUser();
    List<User> users = [];

    // write request
    var querySnapshot = await _instance
        .collection(_folderUsers)
        .orderBy("full_name")
        .startAt([keyword]).endAt([keyword + '\uf8ff']).get();

    for (var element in querySnapshot.docs) {
      users.add(User.fromJson(element.data()));
    }

    users.remove(user);
    return users;
  }

  static Future<Post> storePost(Post post) async {
    User me = await loadUser();
    post.uid = me.uid;
    post.fullName = me.fullName;
    post.imgUser = me.imgUrl;
    post.date = DateTime.now().toString();

    String postId = _instance.collection(_folderUsers).doc(me.uid).collection(_folderPosts).doc().id;
    post.id = postId;
    await _instance.collection(_folderUsers).doc(me.uid).collection(_folderPosts).doc(postId).set(post.toJson());
    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    await _instance.collection(_folderUsers).doc(post.uid).collection(_folderFeeds).doc(post.id).set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String uid = (await Prefs.load(StorageKeys.UID))!;
    var querySnapshot = await _instance.collection(_folderUsers).doc(uid).collection(_folderFeeds).get();

    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      if(post.uid == uid) post.mine = true;
      posts.add(post);
    }

    return posts;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String uid = (await Prefs.load(StorageKeys.UID))!;
    var querySnapshot = await _instance.collection(_folderUsers).doc(uid).collection(_folderPosts).get();

    for (var element in querySnapshot.docs) {
      posts.add(Post.fromJson(element.data()));
    }

    return posts;
  }

}
