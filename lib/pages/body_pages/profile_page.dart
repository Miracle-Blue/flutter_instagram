import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/post_model.dart';
import 'package:flutter_instagram/models/user_model.dart';
import 'package:flutter_instagram/services/auth_service.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/file_service.dart';
import 'package:flutter_instagram/services/utils.dart';
import 'package:flutter_instagram/views/themes.dart' show colorTwo;
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const id = "/profile_page";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  bool isLoading = false;
  File? _image;
  User? user;
  int countPosts = 0;

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
    user = await DataService.loadUser();
    setState(() => isLoading = false);
  }

  void _imgPick(ImageSource source) async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      setState(() {
        _image = File(image.path);
        _changePhoto();
      });
    }
  }

  void _changePhoto() async {
    if (_image != null) {
      setState(() => isLoading = true);
      user!.imgUrl =
          await FileService.uploadImage(_image!, FileService.folderUser);
      await DataService.updateUser(user!);
      setState(() => isLoading = false);
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Pick Photo'),
                    onTap: () {
                      _imgPick(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    _imgPick(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  void _loadPosts() async {
    postList = await DataService.loadPosts();
    countPosts = postList.length;
    setState(() {});
  }

  void _actionLogout() async{
    var result = await Utils.dialogCommon(context, "Insta Clone", "Do you want to logout?", false);
    if(result) {
      AuthService.signOutUser(context);
    }
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
            appBar: AppBar(
              title: Row(
                children: [
                  const Icon(
                    Icons.lock_open,
                    size: 18,
                    color: Colors.black,
                  ),
                  Text(
                    " ${user?.fullName} ",
                    style: const TextStyle(color: Colors.black),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    _actionLogout();
                  },
                  icon: const Icon(Icons.exit_to_app),
                  color: colorTwo,
                ),
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
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
                child: GestureDetector(
                  onTap: () => _showPicker(context),
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
                    "${user?.followersCount}",
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
          TextButton(
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
            onPressed: () {},
            child: const Text(
              "Edit Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),

          /// * stores
          // SizedBox(
          //   height: 120,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     children: [
          //       GestureDetector(
          //         onTap: () {},
          //         child: Container(
          //           height: 100,
          //           width: 60,
          //           margin:
          //               const EdgeInsets.symmetric(horizontal: 7, vertical: 16),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.center,
          //             children: [
          //               Container(
          //                 height: 60,
          //                 width: 60,
          //                 alignment: Alignment.center,
          //                 decoration: BoxDecoration(
          //                   border: Border.all(width: 1, color: Colors.grey),
          //                   borderRadius: BorderRadius.circular(30),
          //                 ),
          //                 child: Container(
          //                   height: 54,
          //                   width: 54,
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(30),
          //                   ),
          //                   child: const Icon(Icons.add),
          //                 ),
          //               ),
          //               const SizedBox(height: 7),
          //             ],
          //           ),
          //         ),
          //       ),
          //       // ? if add new fiche
          //       // ...storyList.map((e) => StoryWidget(user: e)).toList(),
          //     ],
          //   ),
          // ),
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
