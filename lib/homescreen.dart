import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:share_plus/share_plus.dart';


String WEBPATH = '';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedImagePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SuperFace'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    selectedImagePath == ''
                    ? Image.asset('assets/images/portrait_placeholder.png', /*height: 200, width: 200,*/ fit: BoxFit.fill,)
                    : Image.file(File(selectedImagePath), scale: 1.0, fit: BoxFit.fill, filterQuality: FilterQuality.none,),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              // ElevatedButton(
              //     style: ButtonStyle(
              //         backgroundColor: MaterialStateProperty.all(Colors.blue),
              //         padding:
              //         MaterialStateProperty.all(const EdgeInsets.all(20)),
              //         textStyle: MaterialStateProperty.all(
              //             const TextStyle(fontSize: 14, color: Colors.white))),
              //     onPressed: () async {
              //       selectImage();
              //       setState(() {});
              //     },
              //     child: const Text('Select')),
              HomeScreenButton(
                iconData: Icons.account_box_outlined,
                buttonText: 'Select image',
                onTap: () async {
                  selectImage();
                  setState(() {});
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              // ElevatedButton(
              //      style: ButtonStyle(
              //         backgroundColor: MaterialStateProperty.all(Colors.blue),
              //         padding:
              //         MaterialStateProperty.all(const EdgeInsets.all(20)),
              //
              //         textStyle: MaterialStateProperty.all(
              //             const TextStyle(fontSize: 14, color: Colors.white))),
              //     onPressed: () async{
              //         print('Button Send pressed');
              //         uploadFile(selectedImagePath);
              //     },
              //     child: Text('Transform')),
              HomeScreenButton(
                iconData: Icons.upload,
                buttonText: 'Transform image',
                onTap: () async {
                  selectedImagePath == ''
                      ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Image Selected !")))
                      : uploadFile(selectedImagePath);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future selectImage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Select Image From:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromGallery();
                            print('Image_Path:-');
                            print(selectedImagePath);
                            if (selectedImagePath != '') {
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("No Image Selected !"),
                              ));
                            }
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/picture.png',
                                      height: 60,
                                      width: 60,
                                    ),
                                    Text('Gallery'),
                                  ],
                                ),
                              )),
                        ),
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromCamera();
                            print('Image_Path:-');
                            print(selectedImagePath);

                            if (selectedImagePath != '') {
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("No Image Captured !"),
                              ));
                            }
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/camera.png',
                                      height: 60,
                                      width: 60,
                                    ),
                                    Text('Camera'),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  selectImageFromGallery() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }

  //
  selectImageFromCamera() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 100);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }
  uploadFile(String selectedImagePath) async {
    var postUri = Uri.parse("http://194.177.20.128:5000/lipsapi");
    var request = new http.MultipartRequest("POST", postUri);

    // request.fields['user_id'] = user_id

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      selectedImagePath,
      contentType: new MediaType('application', 'x-tar'),
    ));
    showDialog(context: context, builder: (context)=> Center(child: CircularProgressIndicator(),),);
    request.send().then((result) async {

      http.Response.fromStream(result)
          .then((response) {

        if (response.statusCode == 200) {
          print("Uploaded! ");
          print('response.body ' + response.body);
          var responseBody = jsonDecode(response.body);
          if (responseBody['path'] == 'bad image ...') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Upload image with one portrait !"),
            ));
          }
          else {
            print(responseBody['path']);
            WEBPATH = responseBody['path'];
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomNavigationBarExample()));
          }

          return response.body;
        }
      });
    }).catchError((err) => print('error : '+err.toString()))
        .whenComplete(()
    {
      Navigator.of(context).pop();
    });


  }
}


class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    AnalyticsDashboard(),
    ModelingDashboard(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_retouching_natural_outlined),
            label: 'Modeling',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreenButton extends StatelessWidget {
  const HomeScreenButton({
    Key? key,
    required this.iconData,
    required this.buttonText,
    this.onTap,
  }) : super(key: key);
  final IconData iconData;
  final String buttonText;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 50.0,
            width: 150.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Container(
                  height: 50.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(
                    iconData,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Text(
                    buttonText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LipsAnalytics extends StatelessWidget {
  const LipsAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lips analytics'),
      ),
      body:
      SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text('Mouth canthal tilt',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                        Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_cant.png',
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },),
                      ],
                    )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Lips ratio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_ratio.png',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Lower third ratio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/upper_lip_ratio.png',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}

class EyesAnalytics extends StatelessWidget {
  const EyesAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eyes analytics'),
      ),
      body:
      SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Intercanthal tilt',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/canthal_tilt.png',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}

class BrowsAnalytics extends StatelessWidget {
  const BrowsAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eyebrows analytics'),
      ),
      body:
      SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Medial eyebrow tilt',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/medial_eyebrow_tilt.png',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Eyebrow apex projection',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/brow_apex_projection.png',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}

class FaceFormAnalytics extends StatelessWidget {
  const FaceFormAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facial form analytics'),
      ),
      body:
      SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Bigonial-bizygomatic ratio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/bigonial_bizygomatic_ratio.png',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          crossAxisCount: 2,
          primary: false,
          children: [
            GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LipsAnalytics()));
                },
                child:
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.all(20.0),
                    child: Column(
                        children: <Widget>[
                          Image.asset('assets/images/lips.png', height: 128, width: 128, fit: BoxFit.fill,),
                          Text('Lips')
                        ]
                    )
                )
            ),
            GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EyesAnalytics()));
                },
                child:
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.all(20.0),
                    child: Column(
                        children: <Widget>[
                          Image.asset('assets/images/visibility.png', height: 128, width: 128, fit: BoxFit.fill,),
                          Text('Eyes')
                        ]
                    )
                )
            ),
            GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BrowsAnalytics()));
                },
                child:
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.all(20.0),
                    child: Column(
                        children: <Widget>[
                          Image.asset('assets/images/eyebrow.png', height: 128, width: 128, fit: BoxFit.fill,),
                          Text('Eyebrows')
                        ]
                    )
                )
            ),
            GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FaceFormAnalytics()));
                },
                child:
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.all(20.0),
                    child: Column(
                        children: <Widget>[
                          Image.asset('assets/images/face.png', height: 128, width: 128, fit: BoxFit.fill,),
                          Text('Face form')
                        ]
                    )
                )
            ),
          ]

      );

  }
}

class ModelingDashboard extends StatelessWidget {
  const ModelingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
        primary: false,
        children: [
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LipsModeling()));
              },
              child:
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.all(20.0),
                  child: Column(
                      children: <Widget>[
                        Image.asset('assets/images/lips.png', height: 128, width: 128, fit: BoxFit.fill,),
                        Text('Lips')
                      ]
                  )
              )
          ),
        ]

    );

  }
}

class LipsModeling extends StatelessWidget {
  const LipsModeling({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lips modeling'),
      ),
      body:
      SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Flat bow',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_1.jpg',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeScreenButton(
                      iconData: Icons.save,
                      buttonText: 'Save image',
                      onTap: () async {
                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_1.jpg').then<void>((bool? success) {
                          if (success ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Image saved"),
                            ));
                          }});
                      },
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    HomeScreenButton(
                      iconData: Icons.share,
                      buttonText: 'Share image',
                      onTap: () async {
                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_1.jpg', );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('Vitreous',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_2.jpg',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeScreenButton(
                      iconData: Icons.save,
                      buttonText: 'Save image',
                      onTap: () async {
                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_2.jpg').then<void>((bool? success) {
                          if (success ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Image saved"),
                            ));
                              }});
                      },
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    HomeScreenButton(
                      iconData: Icons.share,
                      buttonText: 'Share image',
                      onTap: () async {
                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_2.jpg', );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('French',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_3.jpg',
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },),
                        ],
                      )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeScreenButton(
                      iconData: Icons.save,
                      buttonText: 'Save image',
                      onTap: () async {
                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_3.jpg').then<void>((bool? success) {
                          if (success ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Image saved"),
                            ));
                          }});
                      },
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    HomeScreenButton(
                      iconData: Icons.share,
                      buttonText: 'Share image',
                      onTap: () async {
                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/transfer_3.jpg', );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),

              ]
          ),
        ),
      ),
    );
  }
}