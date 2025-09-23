import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/providers/auth_provider.dart';
import '../view_model/settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  
  // 取消所有通知
  void _cancelAllNotifications(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认取消所有通知'),
          content: const Text('此操作将取消所有未处理的通知，是否继续？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await ref.read(settingNotifierProvider.notifier).cancelAllNotifications();
                Navigator.of(context).pop();
                
                // 显示操作成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('所有通知已取消'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingNotifierProvider);
    
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
          
          // 未处理通知部分
          settingsState.when(
            data: (settings) => ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: const Text('通知管理'),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.notifications_outlined, size: 22,),
              ),
              trailing: settings.pendingNotificationCount > 0 
                ? badges.Badge(
                    badgeContent: Text(settings.pendingNotificationCount.toString()),
                    child: const Icon(Icons.chevron_right),
                  )
                : const Icon(Icons.chevron_right),
              onTap: () => _cancelAllNotifications(context, ref),
            ),
            loading: () => const ListTile(
              title: Text('通知管理'),
              leading: Icon(Icons.notifications_outlined),
              trailing: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (error, stackTrace) => ListTile(
              title: Text('通知管理'),
              leading: Icon(Icons.error),
              subtitle: Text('加载通知数据失败'),
            ),
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