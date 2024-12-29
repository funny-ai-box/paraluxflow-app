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

// Language name getter remains the same...
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
  DisplayMode displayMode = DisplayMode.light;
  Language currentLanguage = Language.English;

  void _changeDisplayMode(DisplayMode mode) {
    setState(() {
      displayMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: UserHeader(),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    trailing: CupertinoSwitch(
                      value: isNotificationsOn,
                      onChanged: (val) {
                        setState(() => isNotificationsOn = val);
                      },
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.brightness_4_outlined,
                    title: 'Display Mode',
                    subtitle: displayMode.toString().split('.').last,
                    onTap: showDisplayModeBottomSheet,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: getLanguageName(currentLanguage),
                    onTap: showLanguageSelectionBottomSheet,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.support_outlined,
                    title: 'Contact Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () {/* Handle logout */},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black54),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }

  // Bottom sheet methods remain the same but with updated styling
  void showLanguageSelectionBottomSheet() {
    showBarModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: Language.values.length,
                  itemBuilder: (context, index) {
                    final lang = Language.values[index];
                    return ListTile(
                      title: Text(
                        getLanguageName(lang),
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: currentLanguage == lang
                          ? Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() => currentLanguage = lang);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDisplayModeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Display Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.brightness_5_outlined),
                title: Text('Light'),
                trailing: displayMode == DisplayMode.light
                    ? Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  _changeDisplayMode(DisplayMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.brightness_2_outlined),
                title: Text('Dark'),
                trailing: displayMode == DisplayMode.dark
                    ? Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  _changeDisplayMode(DisplayMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.brightness_4_outlined),
                title: Text('System Default'),
                trailing: displayMode == DisplayMode.system
                    ? Icon(Icons.check, color: Colors.blue)
                    : null,
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
    userInfoFuture = CustomUser.getFromLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<CustomUser?>(
        future: userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/tony.png'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.displayName!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        snapshot.data!.email!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined),
                  onPressed: () {/* Handle edit profile */},
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
