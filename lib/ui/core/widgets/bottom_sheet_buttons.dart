import 'package:flutter/material.dart';

class BottomSheetButtons extends StatelessWidget {

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final bool isLoading; // 添加loading状态参数
  const BottomSheetButtons({super.key, this.onCancel, this.onConfirm, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: 
      isLoading ? 
      SizedBox(
        height: 52,
      ) :
      Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: isLoading ? null : onCancel, // loading时禁用取消按钮
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 60), // 宽度无限延伸，高度50
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                '取消',
                style: TextStyle(
                  color: isLoading? Colors.grey[600] : Theme.of(context).colorScheme.onSurface,
                  
                ),
              ),
            ),
          ),

          Container(
            width: 1,
            height: 52, // 分隔线高度
            color: Colors.grey[200],
          ),
          Expanded(
            child: TextButton(
              onPressed: isLoading ? null : onConfirm, // loading时禁用确定按钮
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 60), // 宽度无限延伸，高度50
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child:  Text('确定', style: TextStyle(color: isLoading? Colors.grey[600] : Theme.of(context).colorScheme.onSurface,),),
            ),
          ),
        ],
      ),
    );
  }
}
