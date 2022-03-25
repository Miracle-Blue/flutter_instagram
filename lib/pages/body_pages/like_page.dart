import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/views/main_texts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class LikePage extends StatefulWidget {
  const LikePage({Key? key}) : super(key: key);

  static const id = "/like_page";

  @override
  _LikePageState createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  final bool isLoading = false;

  final List<Post> postList = [
    Post(imgPost: "assets/images/im_user.jpg", caption: "caption"),
    Post(imgPost: "assets/images/im_user.jpg", caption: "caption"),
  ];

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
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: const Image(
                        image: AssetImage("assets/images/im_user.jpg"),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Text(
                          "date ####-##-##",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ],
                ),
                post.mine
                    ? IconButton(
                        icon: const Icon(LineIcons.creativeCommonsShareAlike),
                        onPressed: () {},
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          //#image
          //Image.network(post.postImage, fit: BoxFit.cover),

          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl:
                "https://c4.wallpaperflare.com/wallpaper/161/942/374/minimalism-planet-blue-bright-wallpaper-preview.jpg",
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
                    onPressed: () {},
                    icon: post.liked
                        ? const Icon(
                            FontAwesomeIcons.heart,
                            color: Colors.red,
                          )
                        : const Icon(FontAwesomeIcons.solidHeart),
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
