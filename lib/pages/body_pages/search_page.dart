import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/models/user_model.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/views/main_texts.dart';
import 'package:flutter_instagram/views/themes.dart' show colorTwo;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  static const id = "/search_page";

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController controller = TextEditingController();
  List<User> user = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiSearchUsers("");
  }

  void _apiSearchUsers(String keyword) {
    setState(() {
      isLoading = true;
    });
    DataService.searchUsers(keyword).then((users) => _resSearchUser(users));
  }

  void _resSearchUser(List<User> users) {
    setState(() {
      isLoading = false;
      user = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MainTexts(
          mainText: "Search",
          mainTextSize: 25,
          color: Colors.black,
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                //#searchuser
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  height: 45,
                  child: TextField(
                    style: const TextStyle(color: Colors.black87),
                    controller: controller,
                    onChanged: _apiSearchUsers,
                    decoration: const InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: user.length,
                    itemBuilder: (ctx, index) {
                      return _itemOfUser(user[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _itemOfUser(User user) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                width: 1.5,
                color: colorTwo,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: user.imgUrl.isNotEmpty
                  ? CachedNetworkImage(
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                      imageUrl: user.imgUrl,
                      placeholder: (context, url) =>
                      const Image(
                        image: AssetImage("assets/images/im_user.jpg"),
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : const Image(
                      image: AssetImage("assets/images/im_user.jpg"),
                      height: 40,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Text(
                user.email,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: user.followed
                          ? const Text("Following")
                          : const Text("Follow"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
