import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/models/user_model.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/prefs_service.dart';

class SomeOneProfile extends StatefulWidget {
  const SomeOneProfile({Key? key, required this.uid}) : super(key: key);

  final String uid;
  static const id = "/someone_profile";

  @override
  State<SomeOneProfile> createState() => _SomeOneProfileState();
}

class _SomeOneProfileState extends State<SomeOneProfile>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  bool isLoading = false;
  User? user;
  int countPosts = 0;
  String? myUid;
  List<Post> postList = [];

  @override
  void initState() {
    super.initState();
    controller = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    _loadUser();
    _loadPosts();
  }

  void _loadUser() async {
    setState(() => isLoading = true);
    myUid = (await Prefs.load(StorageKeys.UID));
    user = await DataService.loadUserWithId(widget.uid);
    setState(() => isLoading = false);
  }

  void _loadPosts() async {
    setState(() => isLoading = true);
    postList = await DataService.loadPostsWithId(widget.uid);
    countPosts = postList.length;
    setState(() => isLoading = false);
  }

  void _apiFollowUser(User someone) async {
    setState(() => isLoading = true);

    await DataService.followUser(someone);

    setState(() {
      someone.followed = true;
      isLoading = false;
    });

    await DataService.storePostsToMyFeed(someone);
  }

  void _apiUnfollowUser(User someone) async {
    setState(() => isLoading = true);

    await DataService.unfollowUser(someone);

    setState(() {
      someone.followed = false;
      isLoading = false;
    });

    await DataService.removePostsFromMyFeed(someone);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          )
        : Scaffold(
            appBar: AppBar(),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    leading: const SizedBox.shrink(),
                    toolbarHeight: 170,

                    /// * title
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: title(),
                    ),

                    floating: true,
                    pinned: true,
                    // snap: true,
                    bottom: TabBar(
                      controller: controller,
                      indicatorColor: Colors.white,
                      tabs: const [
                        Tab(
                          icon: Icon(
                            Icons.apps_outlined,
                            color: Colors.black,
                          ),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.person_pin_outlined,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: controller,
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    children: postList.map((e) => photosField(e)).toList(),
                  ),
                  GridView.count(
                    crossAxisCount: 1,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    children: postList.map((e) => photosField(e)).toList(),
                  ),
                ],
              ),
            ),
          );
  }

  Padding title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// * header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: user!.imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user!.imgUrl,
                            placeholder: (context, url) => const Image(
                              image: AssetImage("assets/images/im_user.jpg"),
                              fit: BoxFit.cover,
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          )
                        : const Image(
                            image: AssetImage("assets/images/im_user.jpg"),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    "$countPosts",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Text(
                    "Posts",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "${user!.followersCount}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Text(
                    "Followers",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "${user!.followingCount}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Text(
                    "Following",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          /// * edit button
          (myUid != widget.uid)
              ? TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1.2,
                        )),
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: () {
                    user!.followed
                        ? _apiUnfollowUser(user!)
                        : _apiFollowUser(user!);
                  },
                  child: user!.followed
                      ? const Text(
                          "Following",
                          style: TextStyle(color: Colors.black),
                        )
                      : const Text(
                          "Follow",
                          style: TextStyle(color: Colors.black),
                        ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget photosField(Post e) {
    return CachedNetworkImage(
      imageUrl: e.imgPost!,
      placeholder: (context, url) => const Image(
        image: AssetImage("assets/images/im_user.jpg"),
        fit: BoxFit.cover,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }
}
