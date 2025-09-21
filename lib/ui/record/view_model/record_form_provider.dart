
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'record_state_provider.dart';

part 'record_form_provider.g.dart';

enum RecordFormToolTab { none, category, tag, timer }

// 定义表单状态的数据模型
class RecordFormState {
  final List<String> categories;
  final String selectedCategory;
  final List<String> tags;
  final List<String> selectedTags;
  final String textInput;
  final DateTime? selectedDate;
  final bool isSubmitted;
  final bool isShowCategoryTextField;
  final bool isShowTagTextField;
  final RecordFormToolTab activeTab;
  final DateTime? selectedDateTime; // 
  final Map<String, dynamic>? notificationOptions; 
  final Map<String, bool>? repeatingOptions; 
  final File? recordLocalImageFile; // 本地图片
  final File? recordAudioFile; // 本地音频
  final bool isSubmitting; // 添加loading状态字段
  final bool forceClearImage; // 强制清除图片

  const RecordFormState({
    this.categories = const [],
    this.tags = const [],
    this.textInput = '',
    this.selectedCategory = '',
    this.selectedTags = const [],
    this.selectedDate,
    this.isSubmitted = false,
    this.isShowCategoryTextField = false,
    this.isShowTagTextField = false,
    this.activeTab = RecordFormToolTab.none,
    this.selectedDateTime,
    this.notificationOptions,
    this.repeatingOptions,
    this.recordLocalImageFile,
    this.recordAudioFile,
    this.isSubmitting = false, // 默认值为false
    this.forceClearImage = false,

  });

  RecordFormState copyWith({
    List<String>? categories,
    List<String>? tags,
    String? textInput,
    String? selectedCategory,
    List<String>? selectedTags,
    DateTime? selectedDate,
    bool? isSubmitted,
    bool? isShowCategoryTextField,
    bool? isShowTagTextField,
    RecordFormToolTab? activeTab,
    DateTime? selectedDateTime, 
    Map<String, dynamic>? notificationOptions,
    Map<String, bool> ? repeatingOptions,
    File? recordLocalImageFile,
    File? recordAudioFile,
    bool? isSubmitting, // 添加到copyWith方法
    bool? forceClearImage, // 强制清除图片
  }) {
    return RecordFormState(
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      textInput: textInput ?? this.textInput,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedDate: selectedDate ?? this.selectedDate,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isShowCategoryTextField: isShowCategoryTextField ?? false,
      isShowTagTextField: isShowTagTextField ?? false,
      activeTab: activeTab ?? this.activeTab,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      notificationOptions: notificationOptions?? this.notificationOptions,
      repeatingOptions: repeatingOptions ?? this.repeatingOptions,
      recordLocalImageFile: forceClearImage ?? false ? null : (recordLocalImageFile ?? this.recordLocalImageFile),
      recordAudioFile: recordAudioFile ?? this.recordAudioFile,
      isSubmitting: isSubmitting ?? this.isSubmitting, // 更新copyWith方法
    );
  }
}

// 主表单 Provider
@riverpod
class RecordFormNotifier extends _$RecordFormNotifier {
  @override
  RecordFormState build() {
    // 初始状态
    final initialState = RecordFormState(
      categories: ['知识收集', '个人财务', '行程管理', '其他A', '其他B', '其他C', '其他D'],
      tags: ['标签A', '标签B', '标签C', '标签D'],
      selectedDateTime: DateTime.now(),
      notificationOptions: {
        'none': true,
        'custom': {
          'isCustom': false,
          'time': Duration.zero,
          'showTimeText': '00天00小时00分',
        },
        'onTime': false,
      },
      repeatingOptions: {
        '周一': false,
        '周二': false,
        '周三': false,
        '周四': false,
        '周五': false,
        '周六': false,
        '周日': false,
      },
    );
    print('record_form_provider.dart - build: Initial state.textInput: ${initialState.textInput}');
    print('record_form_provider.dart - build: Initial state hashcode: ${initialState.hashCode}');
    return initialState;
  }

  // 输入记录
  void setTextInput(String text) {
    state = state.copyWith(textInput: text);
  }

  // 选择分类
  void toggleCategory(String? category) {
    if (category == state.selectedCategory) {
      state = state.copyWith(selectedCategory: null);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  // 选择标签
  void toggleTag(String? tag) {
    if (tag == null) return;
    final selected = List<String>.from(state.selectedTags);
    if (selected.contains(tag)) {
      selected.remove(tag);
    } else {
      selected.add(tag);
    }
    state = state.copyWith(selectedTags: selected);
  }

  // 选择时间
  void selectDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }

  // 控制分类输入框的显示
  void toggleCategoryTextField() {
    state = state.copyWith(
      isShowCategoryTextField: !state.isShowCategoryTextField,
    );
  }

  // 控制标签输入框的显示
  void toggleTagTextField() {
    state = state.copyWith(isShowTagTextField: !state.isShowTagTextField);
  }

  // 切换选项卡
  void setActiveTab(RecordFormToolTab? tab) {
    if (state.activeTab == tab) {
      state = state.copyWith(activeTab: RecordFormToolTab.none);
    } else {
      state = state.copyWith(activeTab: tab);
    }
  }

  // 选择具体时间HH:MM
  void selectDateTime(DateTime? dateTime) {
    state = state.copyWith(selectedDateTime: dateTime);
  }

  // 设置重复提醒选项
  void setRepeatingOptions(Map<String, bool> options) {
    state = state.copyWith(repeatingOptions: options);
  }


  // 修改notificationOptions中的none
  void setNotificationOptions(Map<String, dynamic> options) {

    Map<String, dynamic> updateOptions = {...state.notificationOptions!};

    if (options.containsKey('none') && options['none'] ) {
      if(updateOptions['onTime'])  updateOptions['onTime'] = false;
      if(updateOptions['custom']['isCustom']) updateOptions['custom']['isCustom'] = false;
    }

    if (options.containsKey('onTime') && options['onTime']) {
      if (updateOptions['none']) updateOptions['none'] = false;
      if(updateOptions['custom']?['isCustom']) updateOptions['custom']?['isCustom'] = false;
    }

    if (options.containsKey('custom') && options['custom']['isCustom']) {
      if (updateOptions['none']) updateOptions['none'] = false;
      if (updateOptions['onTime']) updateOptions['onTime'] = false;
    }

    state = state.copyWith(notificationOptions: {
      ...updateOptions,
      ...options
    });
  }

  Future<void> pickImage(ImageSource source, Function showAlertDialog) async {
    const int maxFileSize = 1024 * 1024; // 1MB
    final XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    final fileSize = await imageFile.length();
    final fileSizeInMB = fileSize / (1024 * 1024); // 将字节转换为 MB

    if (fileSizeInMB > 10) {
      showAlertDialog('图片大小不能超过10MB');
      return;
    }
    // 自动压缩过大图片
    if (fileSize > maxFileSize) {
      imageFile = await compressImage(imageFile);
    }
    state = state.copyWith(recordLocalImageFile: imageFile);

    print('selected image ...${state.recordLocalImageFile}');

  }

  void deleteImage() {
    // 使用新的标志参数来强制清空图片
    state = state.copyWith(forceClearImage: true);
  }

  // 图片压缩
  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // 质量压缩到70%
      format: CompressFormat.jpeg,
    );

    return File(result!.path);
  }

  void updateAudio(String filePath) {

    if (filePath.isNotEmpty) {
      File audioFile = File(filePath);
      state = state.copyWith(recordAudioFile: audioFile);
    } else {
      state = state.copyWith(recordAudioFile: null);
    }
    
  }

  // 提交表单数据
  Future<void> submitForm() async {
    // 设置loading状态为true
    state = state.copyWith(isSubmitting: true);
    
    // 创建一个Map来存储数据
    final Map<String, dynamic> data  = {};
  
    if (state.textInput.isNotEmpty) {
      data['raw_inputs'] = jsonEncode([{"type": "text", "content": state.textInput}]);
    }

    final files = <MultipartFile>[];
    
    // 正确的文件处理方式
    if (state.recordLocalImageFile != null) {
      // 从文件路径中提取文件名
      final filePath = state.recordLocalImageFile!.path;
      final fileName = filePath.split('/').last;
      
      // 将File对象转换为MultipartFile
      final multipartImage = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
      
      // 添加到数据中
      files.add(multipartImage);
    }

    if (state.recordAudioFile != null) {
      // 从文件路径中提取文件名
      final filePath = state.recordAudioFile!.path;
      final fileName = filePath.split('/').last;
      
      // 将File对象转换为MultipartFile
      final multipartAudio = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
      
      // 添加到数据中
      files.add(multipartAudio);
    }


    try {
      await ref.read(recordsNotifierProvider.notifier).addRecord(data, files);
      state = state.copyWith(forceClearImage: true);
    } catch (e) {
      print('record_form_provider.dart - submitForm: Error submitting form: $e');
      rethrow;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

}
