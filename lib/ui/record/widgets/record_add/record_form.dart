import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:float_note/ui/record/view_model/record_form_provider.dart';
import '../../../core/widgets/bottom_sheet_buttons.dart';
import 'voice_recorder.dart';
import 'image_uploader.dart';
import '../../../../utils/utils.dart';

class RecordForm extends ConsumerStatefulWidget {
  const RecordForm({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RecordFormState();
}

class _RecordFormState extends ConsumerState<RecordForm>
    with SingleTickerProviderStateMixin {
  final _recordFormKey = GlobalKey<FormState>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前表单状态
    final recordFormState = ref.watch(recordFormNotifierProvider);
    final isSubmitting = recordFormState.isSubmitting;

    return Form(
      key: _recordFormKey,
      child: Container(
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 让子组件左对齐
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '添加记录',
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.titleLarge?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: 220,
                    alignment: Alignment.centerLeft, // 左对齐
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(icon: Icon(Icons.edit, size: 26)), // 调整图标大小
                        Tab(icon: Icon(Icons.mic_outlined, size: 26)),
                        Tab(icon: Icon(Icons.camera_alt_outlined, size: 26)),
                      ],
                      isScrollable: false, // 确保 TabBar 不可滚动
                      physics: const NeverScrollableScrollPhysics(), // 禁止滚动
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 200,
                    child: isSubmitting
                        ? Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            physics:
                                const NeverScrollableScrollPhysics(), // 禁止滚动
                            children: [
                              // Tab 1: 文本输入
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  5,
                                  5,
                                  5,
                                  5,
                                ), // 左右留白，上下紧凑
                                child: TextFormField(
                                  maxLines: 7, // 调整为 5 行，200px 高度内更合理（7行太高）
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? ' ' : null,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: '请输入记录',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    errorStyle: TextStyle(
                                      height: 0,
                                      fontSize: 0,
                                    ), // 完全隐藏错误文本
                                  ),
                                  onChanged: (value) {
                                    ref
                                        .read(
                                          recordFormNotifierProvider.notifier,
                                        )
                                        .setTextInput(value);
                                  },
                                ),
                              ),

                              // Tab 2: 语音
                              const VoiceRecorder(),

                              // Tab 3: 图片
                              const ImageUploader(),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            BottomSheetButtons(
              onCancel: () {
                Navigator.pop(context);
              },
              onConfirm: () async {
                if (_recordFormKey.currentState!.validate()) {
                  // 提交表单数据
                  try {
                    await ref
                        .read(recordFormNotifierProvider.notifier)
                        .submitForm();
                    // Navigator.pop(context);
                  } catch (e) {
                    print(
                      'record_form.dart - onConfirm: Error submitting form: ${Utils.getErrorMessage(e)}',
                    );
                  }
                }
              },
              isLoading: ref
                  .watch(recordFormNotifierProvider)
                  .isSubmitting, // 传递loading状态
            ),
          ],
        ),
      ),
    );
  }
}
