import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/utils.dart';
import 'package:flutter_instagram/views/main_texts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

import 'someone_profile_page.dart';

class LikePage extends StatefulWidget {
  const LikePage({Key? key}) : super(key: key);

  static const id = "/like_page";

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  bool isLoading = false;
  List<Post> postList = [];

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });
    DataService.loadLikes().then((value) => {
          _resLoadLikes(value),
        });
  }

  void _resLoadLikes(List<Post> posts) {
    setState(() {
      postList = posts;
      isLoading = false;
    });
  }

  void _apiPostUnLike(Post post) {
    setState(() {
      isLoading = true;
      post.liked = false;
    });
    DataService.likePost(post, false).then((value) => {
          _apiLoadLikes(),
        });
  }

  void _actionRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
        context, "Insta Clone", "Do you want to remove this post?", false);
    if (result) {
      setState(() => isLoading = true);
      DataService.removePost(post).then((value) => {
            _apiLoadLikes(),
          });
    }
  }

  @override
  void initState() {
    super.initState();
    _apiLoadLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MainTexts(
          mainText: "Likes",
          mainTextSize: 30,
          color: Colors.black,
        ),
      ),
      body: Stack(
        children: [
          postList.isNotEmpty
              ? ListView.builder(
                  itemCount: postList.length,
                  itemBuilder: (context, index) {
                    return _postField(postList[index]);
                  },
                )
              : const Center(
                  child: Text("No liked posts"),
                ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _postField(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(),
          //userinfo
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SomeOneProfile(
                          uid: post.uid!,
                        ),
                      ),
                    ),
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: (post.imgUser != null && post.imgUser!.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: CachedNetworkImage(
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  imageUrl: post.imgUser!,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              )
                            : const Image(
                                image: AssetImage("assets/images/im_user.jpg"),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${post.fullName?.substring(0, 1).toUpperCase()}${post.fullName?.substring(1, post.fullName!.length)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          Text(
                            Utils.getMonthDayYear(post.date!),
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                post.mine
                    ? IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {
                          _actionRemovePost(post);
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),

          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            imageUrl: post.imgPost!,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator.adaptive()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          //#likeshare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (post.liked) _apiPostUnLike(post);
                    },
                    icon: post.liked
                        ? const Icon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red,
                          )
                        : const Icon(
                            FontAwesomeIcons.heart,
                            color: Colors.red,
                          ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            ],
          ),
          // #caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: " ${post.caption}",
                    style: const TextStyle(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
