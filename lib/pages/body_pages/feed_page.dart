import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/log_service.dart';
import 'package:flutter_instagram/services/utils.dart';
import 'package:flutter_instagram/views/main_texts.dart';
import 'package:flutter_instagram/views/themes.dart' show colorTwo;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key, this.pageController}) : super(key: key);

  final PageController? pageController;
  static const id = "/feed_page";

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool isLoading = true;
  List<Post> postList = [];

  @override
  void initState() {
    super.initState();
    _apiLoadFeeds();
  }

  void _apiLoadFeeds() async {
    setState(() {
      isLoading = true;
    });

    DataService.loadFeeds().then((posts) => {_resLoadFeeds(posts)});
  }

  void _resLoadFeeds(List<Post> posts) {
    setState(() {
      isLoading = false;
      postList = posts;
    });
  }

  void _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  void _apiPostUnLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
    });
  }

  void _actionRemovePost(Post post) async{
    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to remove this post?", false);
    if(result != null && result){
      setState(() {
        isLoading = true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadFeeds(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MainTexts(
          mainText: "Instagram",
          mainTextSize: 30,
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: () {
              widget.pageController!.jumpToPage(2);
            },
            icon: const Icon(
              Icons.camera_alt,
              color: colorTwo,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: postList.length,
            itemBuilder: (context, index) {
              return _postField(postList[index]);
            },
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
    Log.d(post.toJson().toString());
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
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: post.imgUser != null
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
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    _actionRemovePost(post);
                  },
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
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
                      post.liked ? _apiPostUnLike(post) : _apiPostLike(post);
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
                    style: const TextStyle(color: Colors.black),
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
