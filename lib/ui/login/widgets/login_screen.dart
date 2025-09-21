import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:float_note/ui/login/view_model/login_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _agreeTerms = false;

  Future<void> _login() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先同意用户协议和隐私协议')));
      return;
    }

    // 调用登录provider中的登录方法, 暂用固定密码
    await ref.read(loginViewModelProvider.notifier).login({
      'username': 'admin',
      'password': 'admin123',
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 获取主题色
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // 监听登录状态变化
    ref.listen<AsyncValue<Map<String, dynamic>?>>(loginViewModelProvider, (
      previous,
      current,
    ) {
      // 处理登录成功的情况
      current.whenOrNull(
        data: (data) {
          if (data != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('登录成功'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: Duration(milliseconds: 300),
              ),
            );
          }
        },
        error: (error, stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('登录失败: $error')));
            // 重置登录状态，以便用户可以再次尝试
            Future.delayed(const Duration(milliseconds: 500), () {
              ref.read(loginViewModelProvider.notifier).reset();
            });
          }
        },
      );
    });

    // 获取登录状态
    final loginState = ref.watch(loginViewModelProvider);

    return Scaffold(
      appBar: null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo位置
              const Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  // 这里预留Logo位置，可以替换为实际的Logo图片
                  child: Placeholder(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // 标题
              const Center(
                child: Text(
                  '欢迎登录',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 64),

              // 微信一键登录按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loginState.isLoading ? null : _login,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        return primaryColor.withValues(
                          alpha:
                              ((primaryColor.a * 255.0).round() & 0xff) * 0.8,
                        );
                      }
                      return primaryColor;
                    }),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: loginState.isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          constraints: BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wechat, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              '微信一键登录',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // 同意协议单选
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeTerms = value ?? false;
                      });
                    },
                    // activeColor: const Color(0xFF8F9BB3),
                  ),
                  Expanded(
                    child: Text(
                      '已阅读并同意《用户协议》和《隐私协议》',
                      style: TextStyle(
                        color: const Color(0xFF8F9BB3),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
