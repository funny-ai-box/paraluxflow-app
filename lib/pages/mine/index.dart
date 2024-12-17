import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lazyreader/models/CustomUser.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

enum DisplayMode { light, dark, system }

enum Language {
  English,
  Spanish,
  French,
  Chinese,
  German,
  Russian,
  Japanese,
  Korean,
  Portuguese,
  Italian,
  Dutch,
  Swedish,
  Finnish,
  Danish,
  Norwegian,
  Polish,
  Hungarian,
  Czech,
  Turkish,
  Arabic
}

String getLanguageName(Language language) {
  switch (language) {
    case Language.English:
      return "English";
    case Language.Spanish:
      return "Español";
    case Language.French:
      return "Français";
    case Language.Chinese:
      return "中文";
    case Language.German:
      return "Deutsch";
    case Language.Russian:
      return "Русский";
    case Language.Japanese:
      return "日本語";
    case Language.Korean:
      return "한국어";
    case Language.Portuguese:
      return "Português";
    case Language.Italian:
      return "Italiano";
    case Language.Dutch:
      return "Nederlands";
    case Language.Swedish:
      return "Svenska";
    case Language.Finnish:
      return "Suomi";
    case Language.Danish:
      return "Dansk";
    case Language.Norwegian:
      return "Norsk";
    case Language.Polish:
      return "Polski";
    case Language.Hungarian:
      return "Magyar";
    case Language.Czech:
      return "Čeština";
    case Language.Turkish:
      return "Türkçe";
    case Language.Arabic:
      return "العربية";
    default:
      return "Unknown";
  }
}

class MineMainPage extends StatefulWidget {
  @override
  _MineMainPageState createState() => _MineMainPageState();
}

class _MineMainPageState extends State<MineMainPage> {
  bool isPrivateProfile = false;
  bool isNotificationsOn = true;
  DisplayMode displayMode = DisplayMode.light; // 默认为 light
  Language currentLanguage = Language.English; // Default to English

  void _changeDisplayMode(DisplayMode mode) {
    setState(() {
      displayMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserHeader(),

              SizedBox(
                height: 20,
              ),
              SettingSection(
                title: 'General',
                tiles: [
                  SettingTile.switchTile(
                    title: 'Notifications',
                    value: isNotificationsOn,
                    onChanged: (bool val) {
                      setState(() {
                        isNotificationsOn = val;
                      });
                    },
                  ),
                  SettingTile(
                    title: 'Display Mode',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          displayMode.toString().split('.').last,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ), // 显示当前选择的显示模式
                        Icon(Icons.chevron_right), // 提供一个指示符，表明可以点击
                      ],
                    ),
                    onTap: showDisplayModeBottomSheet,
                  ),
                  SettingTile(
                    title: 'Local Language',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          getLanguageName(
                              currentLanguage), // Display the selected language in its own language
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons
                            .chevron_right), // Indicator to show that it can be expanded
                      ],
                    ),
                    onTap: showLanguageSelectionBottomSheet,
                  ),
                ],
              ),
              // SettingSection(
              //   title: 'Account',
              //   tiles: [
              //     SettingTile(
              //       title: 'Privacy',
              //       onTap: () {/* Navigate to privacy settings */},
              //     ),
              //     SettingTile(
              //       title: 'Security',
              //       onTap: () {/* Navigate to security settings */},
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 20,
              ),
              SettingSection(
                title: 'Support',
                tiles: [
                  SettingTile(
                    title: 'Terms & Conditions',
                    onTap: () {/* Navigate to terms & conditions */},
                  ),
                  SettingTile(
                    title: 'Contact',
                    onTap: () {/* Navigate to contact */},
                  ),
                ],
              ),
              SettingTile(
                title: 'Logout',
                onTap: () {/* Handle logout */},
              ),
            ],
          ),
        ));
  }

  void showLanguageSelectionBottomSheet() {
    showBarModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            children: Language.values
                .map((lang) => ListTile(
                      title: Text(getLanguageName(lang)),
                      onTap: () {
                        setState(() {
                          currentLanguage = lang;
                        });
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  void showDisplayModeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.brightness_4),
                title: Text('Light'),
                onTap: () {
                  _changeDisplayMode(DisplayMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.brightness_2),
                title: Text('Dark'),
                onTap: () {
                  _changeDisplayMode(DisplayMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.phone_android),
                title: Text('System Default'),
                onTap: () {
                  _changeDisplayMode(DisplayMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserHeader extends StatefulWidget {
  @override
  _UserHeaderState createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  Future<CustomUser?>? userInfoFuture;
  @override
  void initState() {
    super.initState();
    // 获取用户信息
    userInfoFuture = CustomUser.getFromLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder<CustomUser?>(
          future: userInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return LayoutBuilder(
                  builder: (context, constraints) => Row(
                    children: [
                      CircleAvatar(
                        radius: 30, // Adjust the size of the avatar
                        backgroundImage: AssetImage('assets/tony.png'),
                      ),
                      SizedBox(width: 16), // Space between avatar and text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(snapshot.data!.displayName!,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)), // 显示用户名
                            Text(snapshot.data!.email!,
                                style: TextStyle(fontSize: 16)), // 显示邮箱
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                // 处理错误
                return Text("Error: ${snapshot.error}");
              }
            }
            // 数据加载中的占位符
            return CircularProgressIndicator();
          },
        ));
  }
}

class SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  SettingSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...tiles
            .map((tile) => Padding(
                  padding: EdgeInsets.only(bottom: 0.0), // 减少底部间距
                  child: tile,
                ))
            .toList(),
      ],
    );
  }
}

class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Function()? onTap;

  SettingTile({required this.title, this.subtitle, this.trailing, this.onTap});

  SettingTile.switchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) : this(
          title: title,
          trailing: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0), // 减少上下间距
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 0), // 调整 ListTile 内部的填充，可根据需要调整
        title: Text(
          title,
          style: TextStyle(fontSize: 16),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: trailing ?? Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
