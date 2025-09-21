import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../view_model/record_form_provider.dart';

class VoiceRecorder extends ConsumerStatefulWidget {
  const VoiceRecorder({super.key});

  @override
  ConsumerState<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends ConsumerState<VoiceRecorder> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Timer? _timer;
  String? _recordPath;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // 开始录音
  Future<void> _startRecording() async {
    // 在异步操作前保存ScaffoldMessenger
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      // 检查权限
      if (await _audioRecorder.hasPermission()) {
        // 获取存储路径
        final directory = await getApplicationDocumentsDirectory();
        final path = 
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);

        

        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
          _recordPath = path;
        });
        
        ref.read(recordFormNotifierProvider.notifier).updateAudio(path);

        // 开始计时
        _startTimer();
      } else {
        openAppSettings(); // 跳转到应用设置页面
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('开始录音失败: ${e.toString()}')));
    }
  }

  // 停止录音
  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });
  }

  // 播放录音
  Future<void> _playRecording() async {
    if (_recordPath == null) return;
    try {
      setState(() {
        _isPlaying = true;
      });

      await _audioPlayer.setFilePath(_recordPath!);
      _audioPlayer.play();

      // 先取消之前可能存在的订阅
      if (_positionSubscription != null) {
        _positionSubscription?.cancel();
      }
      
      // 监听播放位置
      _positionSubscription = _audioPlayer.positionStream.listen((position) {
        setState(() {
          _playbackPosition = position;
        });
      });

      // 监听播放状态
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
            _playbackPosition = Duration.zero;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  // 停止播放
  Future<void> _stopPlaying() async {
    await _audioPlayer.stop();
    _positionSubscription?.cancel();
    setState(() {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
    });
  }

  // 删除录音
  Future<void> _deleteRecording() async {
    if (_recordPath == null) return;

    // 在异步操作前保存ScaffoldMessenger
    final messenger = ScaffoldMessenger.of(context);

    // 如果正在播放，先停止播放
    if (_isPlaying) {
      await _stopPlaying();
    }

    try {
      // 删除录音文件
      final file = File(_recordPath!);
      if (await file.exists()) {
        await file.delete();
      }
      // 通知Provider更新录音文件
      ref.read(recordFormNotifierProvider.notifier).updateAudio('');

      setState(() {
        _recordPath = null;
        _recordDuration = Duration.zero;
        _playbackPosition = Duration.zero;
      });
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('删除录音失败: ${e.toString()}')));
    }
  }

  // 计时器
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordDuration += Duration(seconds: 1);
      });
    });
  }

  // 格式化时间显示
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) async {
        if(_recordPath == null){
          await _startRecording();
        } 
      },
      onLongPressEnd: (_) async {
        await _stopRecording();
      },
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: _isRecording ?Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_recordPath == null || _isRecording)
              Column(
                children: [
                  IconButton(
                    onPressed: () => {},
                    icon: Icon(
                      _isRecording ? Icons.mic_off : Icons.mic,
                      size: 50,
                      color: _isRecording ?Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  // 录音时长显示
                  _isRecording
                    ?
                    Text(
                      _formatDuration(_recordDuration),
                      style: TextStyle(fontSize: 12),
                    )
                     : Text(
                        '长按开始录音',
                        style: TextStyle(fontSize: 12),
                      ),
                ],
              ),

            // 播放控制
            if (_recordPath != null && !_isRecording)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _isPlaying ? _stopPlaying : _playRecording,
                  ),
                  Text(
                    _isPlaying
                        ? '剩余: ${_formatDuration(_recordDuration - _playbackPosition)}'
                        : '已录制: ${_formatDuration(_recordDuration)}',
                    style: TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_outlined, 
                      size: 36,
                      color: Colors.red,
                    ),
                    onPressed: _deleteRecording,
                  ),
                  //Text('文件路径: ${_recordPath!.split('/').last}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
