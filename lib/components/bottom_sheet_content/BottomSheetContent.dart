import 'package:flutter/material.dart';

class BottomSheetContent extends StatefulWidget {
  final List dataList;
  final List selectItems;
  BottomSheetContent({required this.dataList, required this.selectItems});

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late List selectedItems = [];
  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.selectItems);
    print('widget.dataList${widget.dataList}');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.dataList.map((item) {
                    return ListTile(
                      title: Text(item['name']),
                      onTap: () {
                        setState(() {
                          if (selectedItems.contains(item['id'])) {
                            selectedItems.remove(item['id']);
                          } else {
                            selectedItems.add(item['id']);
                          }
                        });
                      },
                      // 根据选中状态显示对勾
                      trailing: selectedItems.contains(item['id'])
                          ? Icon(Icons.check_box)
                          : Icon(Icons.check_box_outline_blank),
                    );
                  }).toList(),
                ),
              ),
            ),
            Column(
              children: [
                if (selectedItems.isEmpty)
                  Text('You need to select at least one'),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary, // 使用主题中的主要颜色
                        ),
                      ),
                      onPressed: () {
                        if (selectedItems.isNotEmpty) {
                          // 选中了至少一个项目，传回选中的数据并关闭底部弹出框
                          Navigator.of(context).pop(selectedItems);
                        }
                      },
                      child: Text(
                        'ok',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer, // 使用主题中的文本颜色
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
