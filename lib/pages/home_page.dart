import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/user_model.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/views/themes.dart' show colorTwo;

import 'body_pages/feed_page.dart';
import 'body_pages/like_page.dart';
import 'body_pages/profile_page.dart';
import 'body_pages/search_page.dart';
import 'body_pages/upload_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const id = "/home_page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int currentPage = 0;
  User? user;

  List<IconData> icons = [
    Icons.home_outlined,
    Icons.search,
    Icons.add_box_outlined,
    Icons.favorite_border,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUser();
  }

  void _loadUser() async {
    user = await DataService.loadUser();
    setState(() {});
  }

  void pageViewChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void changePage(int index) {
    setState(() {
      currentPage = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: pageViewChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          FeedPage(pageController: _pageController),
          SearchPage(),
          UploadPage(),
          LikePage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        activeColor: colorTwo,
        currentIndex: currentPage,
        onTap: changePage,
        items: [
          ...icons.map((e) => bottomItem(e)).toList(),
          bottomUserItem(),
        ],
      ),
    );
  }

  BottomNavigationBarItem bottomItem(IconData icon) {
    return BottomNavigationBarItem(icon: Icon(icon, size: 28));
  }

  BottomNavigationBarItem bottomUserItem() {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(1),
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 1,
            color: (currentPage == 4) ? colorTwo : Colors.transparent,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: user != null ? (user!.imgUrl.isNotEmpty
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
                    )) : const Image(
            image: AssetImage("assets/images/im_user.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
