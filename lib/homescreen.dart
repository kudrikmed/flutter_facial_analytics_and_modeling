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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


String WEBPATH = '';
Map<String, dynamic> DATA  = {};

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
        title: Text(AppLocalizations.of(context)!.appName),
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
                    ? Image.asset('assets/images/portrait_placeholder.png', /*height: 500, width: 500,*/ fit: BoxFit.fill,)
                    : Image.file(File(selectedImagePath), scale: 1.0, height: 500, fit: BoxFit.fitHeight, filterQuality: FilterQuality.none,),
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
                buttonText: AppLocalizations.of(context)!.selectImage,
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
                buttonText: AppLocalizations.of(context)!.transformImage,
                onTap: () async {
                  selectedImagePath == ''
                      ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noImageSelected)))
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
                      AppLocalizations.of(context)!.selectImageFrom,
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
                                content: Text(AppLocalizations.of(context)!.noImageSelected),
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
                                    Text(AppLocalizations.of(context)!.gallery),
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
                                content: Text(AppLocalizations.of(context)!.noImageCaptured),
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
                                    Text(AppLocalizations.of(context)!.camera),
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
          var responseBody = jsonDecode(response.body);
          if (responseBody['path'] == 'bad image ...') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.uploadImageWithPortrait),
            ));
          }
          else {
            print(responseBody);
            WEBPATH = responseBody['path'];
            DATA['lips_ratio'] = double.tryParse(responseBody['data']['lips_ratio']);
            DATA['mouth_cant_left'] = double.tryParse(responseBody['data']['mouth_cant_left']);
            DATA['mouth_cant_right'] = double.tryParse(responseBody['data']['mouth_cant_right']);
            DATA['upper_lip_ratio'] = double.tryParse(responseBody['data']['upper_lip_ratio']);
            DATA['bigonial_bizygomatic_ratio'] = double.tryParse(responseBody['data']['bigonial_bizygomatic_ratio']);
            DATA['canthal_tilt_left'] = double.tryParse(responseBody['data']['canthal_tilt_left']);
            DATA['canthal_tilt_right'] = double.tryParse(responseBody['data']['canthal_tilt_right']);
            DATA['brow_apex_projection_left'] = double.tryParse(responseBody['data']['brow_apex_projection_left']);
            DATA['brow_apex_projection_right'] = double.tryParse(responseBody['data']['brow_apex_projection_right']);
            DATA['medial_eyebrow_tilt_left'] = double.tryParse(responseBody['data']['medial_eyebrow_tilt_left']);
            DATA['medial_eyebrow_tilt_right'] = double.tryParse(responseBody['data']['medial_eyebrow_tilt_right']);
            print(DATA);
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
    ModelingDashboard(),
    AnalyticsDashboard(),
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
        title: Text(AppLocalizations.of(context)!.results),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.face_retouching_natural_outlined),
            label: AppLocalizations.of(context)!.modeling,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: AppLocalizations.of(context)!.analytics,
          )
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
        title: Text(AppLocalizations.of(context)!.lipsAnalytics),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_cant.png',
                          fit: BoxFit.fitWidth,
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
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  AppLocalizations.of(context)!.mouthCanthalTilt,
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.grey[800],
                                  )
                              ),
                              Container(height: 10),
                              Text(
                                AppLocalizations.of(context)!.mouthCornerAngleTheory,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Container(height: 10),
                              Text(
                                MakeConclusion.getMouthCanthalTilt(context),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  // Add a spacer to push the buttons to the right side of the card
                                  const Spacer(),
                                  // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.shareImage,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onPressed: () async {
                                      Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_cant.png', );
                                    },
                                  ),
                                  // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.saveImage,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onPressed: () async {
                                      await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_cant.png').then<void>((bool? success) {
                                        if (success ?? false) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text(AppLocalizations.of(context)!.imageSaved),
                                          ));
                                        }});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_ratio.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.lipsRatio,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Container(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.lipsRatioTheory,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(height: 10),
                                Text(
                                  MakeConclusion.getLipsRatio(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_ratio.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/lips_ratio.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/upper_lip_ratio.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.lowerThirdRatio,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Container(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.upperLipRatioTheory,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(height: 10),
                                Text(
                                  MakeConclusion.getUpperLipRatio(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/upper_lip_ratio.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/upper_lip_ratio.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
        title: Text(AppLocalizations.of(context)!.eyesAnalytics),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/canthal_tilt.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.intercanthalTilt,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Container(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.intercanthalTiltTheory,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(height: 10),
                                Text(
                                  MakeConclusion.getIntercanthalTilt(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/canthal_tilt.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/canthal_tilt.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
        title: Text(AppLocalizations.of(context)!.eyebrowsAnalytics),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/medial_eyebrow_tilt.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.medialEyebrowTilt,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Container(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.medialEyebrowTiltTheory,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(height: 10),
                                Text(
                                  MakeConclusion.getMedialEyebrowTilt(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/medial_eyebrow_tilt.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/medial_eyebrow_tilt.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )

                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/brow_apex_projection.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.eyebrowApexProjection,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Container(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.browApexProjectionTheory,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(height: 10),
                                Text(
                                  MakeConclusion.getBrowApexProjection(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/brow_apex_projection.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/brow_apex_projection.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
        title: Text(AppLocalizations.of(context)!.facialFormAnalytics),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/bigonial_bizygomatic_ratio.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.bigonialBizygomaticRatio,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Container(height: 10),
                                Text(
                                  AppLocalizations.of(context)!.bigonialBizygomaticRatioTheory,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Container(height: 10),
                                Text(
                                  MakeConclusion.getBigonialBizygomaticRatio(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/bigonial_bizygomatic_ratio.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/bigonial_bizygomatic_ratio.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                          Text(AppLocalizations.of(context)!.lips)
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
                          Text(AppLocalizations.of(context)!.eyes)
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
                          Text(AppLocalizations.of(context)!.eyebrows)
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
                          Text(AppLocalizations.of(context)!.faceForm)
                        ]
                    )
                )
            ),
            GestureDetector(
                onTap: (){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.functionUnderDevelopment),
                  ));
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
                          Image.asset('assets/images/nose_bw.png', height: 128, width: 128, fit: BoxFit.fill,),
                          Text(AppLocalizations.of(context)!.nose)
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
                        Text(AppLocalizations.of(context)!.lips)
                      ]
                  )
              )
          ),
          GestureDetector(
              onTap: (){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.functionUnderDevelopment),
                ));
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
                        Image.asset('assets/images/visibility_bw.png', height: 128, width: 128, fit: BoxFit.fill,),
                        Text(AppLocalizations.of(context)!.eyes)
                      ]
                  )
              )
          ),
          GestureDetector(
              onTap: (){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.functionUnderDevelopment),
                ));
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
                        Image.asset('assets/images/eyebrow_bw.png', height: 128, width: 128, fit: BoxFit.fill,),
                        Text(AppLocalizations.of(context)!.eyebrows)
                      ]
                  )
              )
          ),
          GestureDetector(
              onTap: (){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.functionUnderDevelopment),
                ));
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
                        Image.asset('assets/images/face_bw.png', height: 128, width: 128, fit: BoxFit.fill,),
                        Text(AppLocalizations.of(context)!.faceForm)
                      ]
                  )
              )
          ),
          GestureDetector(
              onTap: (){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.functionUnderDevelopment),
                ));
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
                        Image.asset('assets/images/nose_bw.png', height: 128, width: 128, fit: BoxFit.fill,),
                        Text(AppLocalizations.of(context)!.nose)
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
        title: Text(AppLocalizations.of(context)!.lipsModeling),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_1.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.variant_one,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_1.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_1.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )

                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_2.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.variant_two,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_2.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_2.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )

                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_3.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.variant_three,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_3.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_3.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )

                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_4.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.variant_four,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_4.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_4.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )

                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_5.png',
                            fit: BoxFit.fitWidth,
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!.variant_five,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.grey[800],
                                    )
                                ),
                                Row(
                                  children: <Widget>[
                                    // Add a spacer to push the buttons to the right side of the card
                                    const Spacer(),
                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.shareImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        Share.share('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_5.png', );
                                      },
                                    ),
                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.saveImage,
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      onPressed: () async {
                                        await GallerySaver.saveImage('http://dkcosmetics.by/facial/photos/lipsapi/' + WEBPATH + '/merged_5.png').then<void>((bool? success) {
                                          if (success ?? false) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.imageSaved),
                                            ));
                                          }});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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

class MakeConclusion {

  static String getMouthCanthalTilt(BuildContext context)
  {
    double mouthCantLeft = DATA['mouth_cant_left'];
    double mouthCantRight = DATA['mouth_cant_right'];

    if ((mouthCantLeft + mouthCantRight) / 2 > 0)
    {
      return AppLocalizations.of(context)!.mouthCornerAnglePositive;
    }
    else{
      return AppLocalizations.of(context)!.mouthCornerAngleNegative;
    }
  }

  static String getLipsRatio(BuildContext context)
  {
    double lipsRatio = DATA['lips_ratio'];

    if (lipsRatio > 1.6)
    {
      return AppLocalizations.of(context)!.smallUpperLip;
    }
    if (lipsRatio < 1.0)
    {
      return AppLocalizations.of(context)!.bigUpperLip;
    }
    else{
      return AppLocalizations.of(context)!.idealUpperLip;
    }
  }
  static String getUpperLipRatio(BuildContext context)
  {
    double upperLipRatio = DATA['upper_lip_ratio'];

    if (upperLipRatio > 2.2)
    {
      return AppLocalizations.of(context)!.bigWhiteUpperLip;
    }
    if (upperLipRatio < 1.8)
    {
      return AppLocalizations.of(context)!.smallWhiteUpperLip;
    }
    else{
      return AppLocalizations.of(context)!.idealWhiteUpperLip;
    }
  }

  static String getIntercanthalTilt(BuildContext context)
  {
    double intercanthalTiltLeft = DATA['canthal_tilt_left'];
    double intercanthalTiltRight = DATA['canthal_tilt_right'];

    if ((intercanthalTiltLeft + intercanthalTiltRight) / 2 > 7)
    {
      return AppLocalizations.of(context)!.canthalTiltIdeal;
    }
    if ((intercanthalTiltLeft + intercanthalTiltRight) / 2 < 4)
    {
      return AppLocalizations.of(context)!.canthalTiltLess;
    }
    else{
      return AppLocalizations.of(context)!.canthalTiltAverage;
    }
  }

  static String getMedialEyebrowTilt(BuildContext context)
  {
    double medialEyebrowTiltLeft = DATA['medial_eyebrow_tilt_left'];
    double medialEyebrowTiltRight = DATA['medial_eyebrow_tilt_right'];

    if ((medialEyebrowTiltLeft + medialEyebrowTiltRight) / 2 > 25)
    {
      return AppLocalizations.of(context)!.browMedialTiltBig;
    }
    if ((medialEyebrowTiltLeft + medialEyebrowTiltRight) / 2 < 15)
    {
      return AppLocalizations.of(context)!.browMedialTiltLow;
    }
    else{
      return AppLocalizations.of(context)!.browMedialTiltIdeal;
    }
  }

  static String getBrowApexProjection(BuildContext context)
  {
    double browApexProjectionLeft = DATA['brow_apex_projection_left'];
    double browApexProjectionRight = DATA['brow_apex_projection_right'];

    if ((browApexProjectionLeft + browApexProjectionRight) / 2 > 1)
    {
      return AppLocalizations.of(context)!.browApexIdeal;
    }
    if ((browApexProjectionLeft + browApexProjectionRight) / 2 < 0.7)
    {
      return AppLocalizations.of(context)!.browApexLow;
    }
    else{
      return AppLocalizations.of(context)!.browApexNormal;
    }
  }

  static String getBigonialBizygomaticRatio(BuildContext context)
  {
    double bigonialBizygomaticRatio = DATA['bigonial_bizygomatic_ratio'];

    if (bigonialBizygomaticRatio > 0.75)
    {
      return AppLocalizations.of(context)!.bigonialBizygomaticMore;
    }
    if (bigonialBizygomaticRatio < 0.7)
    {
      return AppLocalizations.of(context)!.bigonialBizygomaticLess;
    }
    else{
      return AppLocalizations.of(context)!.bigonialBizygomaticIdeal;
    }
  }
}