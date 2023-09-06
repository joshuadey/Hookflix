import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/globalvariables.dart';

class AvatarDialog extends StatefulWidget {
  const AvatarDialog({super.key});

  @override
  State<AvatarDialog> createState() => _AvatarDialogState();
}

class _AvatarDialogState extends State<AvatarDialog> {
  List<AvatarModel> _profiles = [];

  loadAvatar() {
    _profiles.clear();

    var a1 = AvatarModel(fol: 0, profile: 'Decklinz', image: 'images/cat-o.png');
    var a2 = AvatarModel(fol: 1, profile: 'Temi', image: 'images/dog.png');
    var a3 = AvatarModel(fol: 2, profile: 'Mildred', image: 'images/cat.png');
    var a4 =
        AvatarModel(fol: 3, profile: 'James', image: 'images/chicken.png');
    var a5 = AvatarModel(fol: 4, profile: 'Prince', image: 'images/goat-o.png');
    var a6 =
        AvatarModel(fol: 5, profile: 'Habibi', image: 'images/horse-o.png');
    var a7 =
        AvatarModel(fol: 6, profile: 'Magaritta', image: 'images/monkey-o.png');
    var a8 = AvatarModel(fol: 7, profile: 'Joyce', image: 'images/rabbit.png');
    var a9 = AvatarModel(fol: 8, profile: 'Daniella', image: 'images/monkey.png');

    _profiles.add(a1);
    _profiles.add(a2);
    _profiles.add(a3);
    _profiles.add(a4);
    _profiles.add(a5);
    _profiles.add(a6);
    _profiles.add(a7);
    _profiles.add(a8);
    _profiles.add(a9);
  }

  @override
  void initState() {
    loadAvatar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          color: Colors.black54,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Select profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 3,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.white54,
              ),

              // list
              _profiles.isEmpty
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        height: 280,
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, mainAxisExtent: 90),
                          itemCount: _profiles.length,
                          itemBuilder: (context, index) =>
                              _avatarTile(_profiles[index]),
                        ),
                      ),
                    ),

              // add button
              Padding(
                padding: EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 30,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Add profile',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarTile(AvatarModel profile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // avatar
          InkWell(
            onTap: () async {
              var box = Hive.box('myProfile');

              Map prof = {
                'name': profile.profile,
                'image': profile.image,
              };

              box.put('profile', prof);

              setState(() {
                user_name = profile.profile;
                selectedImage = profile.image;
              });
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 3,
                  color: user_name == profile.profile
                      ? Colors.blue.shade600
                      : Colors.transparent,
                ),
              ),
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  profile.image,
                  width: 60,
                  height: 60,
                ),
              ),
            ),
          ),

          SizedBox(height: 5),

          // name
          Text(
            profile.profile,
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AvatarModel {
  int fol;
  String profile;
  String image;

  AvatarModel({
    required this.fol,
    required this.profile,
    required this.image,
  });
}
