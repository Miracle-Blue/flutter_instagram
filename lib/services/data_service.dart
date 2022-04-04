import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/models/user_model.dart';

import 'prefs_service.dart';
import 'utils.dart';

class DataService {
  static final _instance = FirebaseFirestore.instance;
  static const String _folderUsers = "users";
  static const String _folderPosts = "posts";
  static const String _folderFeeds = "feeds";
  static const String _folderFollowing = "following";
  static const String _folderFollowers = "followers";

  // ! User Related

  static Future<void> storeUser(User user) async {
    user.uid = (await Prefs.load(StorageKeys.UID))!;

    Map<String, String> params = await Utils.deviceParams();

    user.deviceId = params['device_id']!;
    user.deviceType = params['device_type']!;
    user.deviceToken = params['device_token']!;

    return _instance.collection(_folderUsers).doc(user.uid).set(user.toJson());
  }

  static Future<User> loadUser() async {
    String _uid = (await Prefs.load(StorageKeys.UID))!;
    var value = await _instance.collection(_folderUsers).doc(_uid).get();
    User user = User.fromJson(value.data()!);

    var querySnapshot1 = await _instance
        .collection(_folderUsers)
        .doc(_uid)
        .collection(_folderFollowers)
        .get();
    user.followingCount = querySnapshot1.docs.length;

    var querySnapshot2 = await _instance
        .collection(_folderUsers)
        .doc(_uid)
        .collection(_folderFollowing)
        .get();
    user.followingCount = querySnapshot2.docs.length;

    return user;
  }

  static Future<User> loadUserWithId(String uid) async {
    var value = await _instance.collection(_folderUsers).doc(uid).get();
    User user = User.fromJson(value.data()!);

    var querySnapshot1 = await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderFollowers)
        .get();
    user.followingCount = querySnapshot1.docs.length;

    var querySnapshot2 = await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderFollowing)
        .get();
    user.followingCount = querySnapshot2.docs.length;

    return user;
  }

  static Future<void> updateUser(User user) async {
    String _uid = (await Prefs.load(StorageKeys.UID))!;

    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(user.uid)
        .collection(_folderPosts)
        .get();

    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      post.uid = user.uid;
      post.fullName = user.fullName;
      post.imgUser = user.imgUrl;
      await _instance
          .collection(_folderUsers)
          .doc(user.uid)
          .collection(_folderPosts)
          .doc(post.id)
          .update(post.toJson());
      await _instance
          .collection(_folderUsers)
          .doc(user.uid)
          .collection(_folderFeeds)
          .doc(post.id)
          .update(post.toJson());
    }
    return _instance.collection(_folderUsers).doc(_uid).update(user.toJson());
  }

  static Future<List<User>> searchUsers(String keyword) async {
    String _uid = (await Prefs.load(StorageKeys.UID))!;
    List<User> users = [];

    var querySnapshot = await _instance
        .collection(_folderUsers)
        .orderBy("full_name")
        .startAt([keyword]).endAt([keyword + '\uf8ff']).get();

    for (var result in querySnapshot.docs) {
      User newUser = User.fromJson(result.data());
      if (newUser.uid != _uid) {
        users.add(newUser);
      }
    }

    List<User> following = [];

    var querySnapshot2 = await _instance
        .collection(_folderUsers)
        .doc(_uid)
        .collection(_folderFollowing)
        .get();
    for (var result in querySnapshot2.docs) {
      following.add(User.fromJson(result.data()));
    }

    for (User user in users) {
      if (following.contains(user)) {
        user.followed = true;
      } else {
        user.followed = false;
      }
    }
    return users;
  }

  // ! Post Related

  static Future<Post> storePost(Post post) async {
    User me = await loadUser();
    post.uid = me.uid;
    post.fullName = me.fullName;
    post.imgUser = me.imgUrl;
    post.date = DateTime.now().toString();

    String postId = _instance
        .collection(_folderUsers)
        .doc(me.uid)
        .collection(_folderPosts)
        .doc()
        .id;
    post.id = postId;
    await _instance
        .collection(_folderUsers)
        .doc(me.uid)
        .collection(_folderPosts)
        .doc(postId)
        .set(post.toJson());
    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    await _instance
        .collection(_folderUsers)
        .doc(post.uid)
        .collection(_folderFeeds)
        .doc(post.id)
        .set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String uid = (await Prefs.load(StorageKeys.UID))!;
    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderFeeds)
        .get();

    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    }

    return posts;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String uid = (await Prefs.load(StorageKeys.UID))!;
    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderPosts)
        .get();

    for (var element in querySnapshot.docs) {
      posts.add(Post.fromJson(element.data()));
    }

    return posts;
  }

  static Future<List<Post>> loadPostsWithId(String uid) async {
    List<Post> posts = [];

    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderPosts)
        .get();

    for (var element in querySnapshot.docs) {
      posts.add(Post.fromJson(element.data()));
    }

    return posts;
  }

  static Future<Post> likePost(Post post, bool liked) async {
    String uid = (await Prefs.load(StorageKeys.UID))!;
    post.liked = liked;

    await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderFeeds)
        .doc(post.id)
        .set(post.toJson());

    if (uid == post.uid) {
      await _instance
          .collection(_folderUsers)
          .doc(uid)
          .collection(_folderPosts)
          .doc(post.id)
          .set(post.toJson());
    }
    return post;
  }

  static Future<List<Post>> loadLikes() async {
    String uid = (await Prefs.load(StorageKeys.UID))!;
    List<Post> posts = [];

    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderFeeds)
        .where("liked", isEqualTo: true)
        .get();

    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      if (post.uid == uid) post.mine = true;
      posts.add(post);
    }

    return posts;
  }

  // ! Follower and Following Related

  static Future<User> followUser(User someone) async {
    User me = await loadUser();

    // I followed to someone
    await _instance
        .collection(_folderUsers)
        .doc(me.uid)
        .collection(_folderFollowing)
        .doc(someone.uid)
        .set(someone.toJson());

    // I am in someone`s followers
    await _instance
        .collection(_folderUsers)
        .doc(someone.uid)
        .collection(_folderFollowers)
        .doc(me.uid)
        .set(me.toJson());

    return someone;
  }

  static Future<User> unfollowUser(User someone) async {
    User me = await loadUser();

    // I un followed to someone
    await _instance
        .collection(_folderUsers)
        .doc(me.uid)
        .collection(_folderFollowing)
        .doc(someone.uid)
        .delete();

    // I am not in someone`s followers
    await _instance
        .collection(_folderUsers)
        .doc(someone.uid)
        .collection(_folderFollowers)
        .doc(me.uid)
        .delete();

    return someone;
  }

  static Future<void> updatePostsToFollowersFeed(User me) async {
    List<String> uids = [];

    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(me.uid)
        .collection(_folderFollowers)
        .get();

    for (var element in querySnapshot.docs) {
      User follower = User.fromJson(element.data());
      uids.add(follower.uid);
    }

    for (String follower in uids) {
      var querySnapshot = await _instance
          .collection(_folderUsers)
          .doc(follower)
          .collection(_folderFeeds)
          .where("uid", isEqualTo: me.uid)
          .get();

      for (var element in querySnapshot.docs) {
        Post post = Post.fromJson(element.data());
        post.imgUser = me.imgUrl;
        post.fullName = me.fullName;
        await _instance
            .collection(_folderUsers)
            .doc(follower)
            .collection(_folderFeeds)
            .doc(post.id)
            .update(post.toJson());
      }
    }
  }

  static Future<void> storePostsToMyFeed(User someone) async {
    // Store someone`s posts to my feed

    List<Post> posts = [];
    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(someone.uid)
        .collection(_folderPosts)
        .get();

    for (var result in querySnapshot.docs) {
      var post = Post.fromJson(result.data());
      post.liked = false;
      posts.add(post);
    }

    for (Post post in posts) {
      storeFeed(post);
    }
  }

  static Future<void> removePostsFromMyFeed(User someone) async {
    // Remove someone`s posts from my feed

    List<Post> posts = [];
    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(someone.uid)
        .collection(_folderPosts)
        .get();

    for (var result in querySnapshot.docs) {
      posts.add(Post.fromJson(result.data()));
    }

    for (Post post in posts) {
      removeFeed(post);
    }
  }

  static Future<void> removeFeed(Post post) async {
    String uid = (await Prefs.load(StorageKeys.UID))!;

    return await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderFeeds)
        .doc(post.id)
        .delete();
  }

  static Future<void> removePost(Post post) async {
    String uid = (await Prefs.load(StorageKeys.UID))!;
    await removeFeed(post);
    await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderPosts)
        .doc(post.id)
        .delete();
    List<String> uids = [];
    var querySnapshot = await _instance
        .collection(_folderUsers)
        .doc(uid)
        .collection(_folderFollowers)
        .get();
    for (var element in querySnapshot.docs) {
      User follower = User.fromJson(element.data());
      uids.add(follower.uid);
    }
    for (String follower in uids) {
      await _instance
          .collection(_folderUsers)
          .doc(follower)
          .collection(_folderFeeds)
          .doc(post.id)
          .delete();
    }
  }
}
