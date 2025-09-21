import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/core/providers/auth_provider.dart';
import '../view_model/settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text('意见反馈'),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.feedback_outlined, size: 22,),
            ),
            onTap: () {
              final feedbackFormKey = GlobalKey<FormState>();
              final contentController = TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Consumer(
                    builder: (context, ref, child) {
                      final settingsState = ref.watch(settingNotifierProvider);
                      final isLoading = settingsState is AsyncLoading;
                       
                      return AlertDialog(
                        title: Text(
                          '意见反馈',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,),
                        ),
                        titlePadding: EdgeInsets.only(top: 15, bottom: 5),
                        actionsPadding: EdgeInsets.all(5),
                        contentPadding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
                        content: Form(
                          key: feedbackFormKey,
                          child: TextFormField(
                            controller: contentController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入反馈内容';
                              }
                              return null;
                            },
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '请输入反馈内容',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              errorStyle: TextStyle(
                                height: 0,
                                fontSize: 0,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: isLoading ? null : () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('取消', style: TextStyle(color: Theme.of(context).colorScheme.outline),),
                              ),
                              SizedBox(width: 10,),
                              TextButton(
                                onPressed: isLoading ? null : () {
                                  if (feedbackFormKey.currentState?.validate() ?? false) {
                                    final content = contentController.text;
                                    // 提交反馈
                                    ref.read(settingNotifierProvider.notifier).feedback(content);
                                  }
                                },
                                child: isLoading 
                                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text('确定'),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          Divider(thickness: 1, height: 1, indent: 0, endIndent: 0),
          ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: const Text('退出登录'),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.exit_to_app_outlined, size: 22,),
            ),
            onTap: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}