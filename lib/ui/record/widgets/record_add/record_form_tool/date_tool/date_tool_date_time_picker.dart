import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import '../../../../view_model/record_form_provider.dart';
import '../../../../../core/widgets/bottom_sheet_buttons.dart';

class DateToolDateTimePicker extends ConsumerWidget {
  const DateToolDateTimePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              // height: 300,
              child: DateTimePickerWidget(
                
                dateFormat: 'HH时:mm分',
                locale: DateTimePickerLocale.zh_cn,
                initDateTime: ref.watch(
                  recordFormNotifierProvider.select(
                    (state) => state.selectedDateTime,
                  ),
                ),
                pickerTheme: DateTimePickerTheme(
                  backgroundColor: Colors.transparent,
                  showTitle: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      '选择时间',
                      style: TextStyle(fontSize:Theme.of(context).textTheme.titleMedium?.fontSize),),),
                  selectionOverlay: Container(color: Colors.transparent),
                ),
                onChange: (dateTime, _) {
                  ref
                      .read(recordFormNotifierProvider.notifier)
                      .selectDateTime(dateTime);
                },
              ),
            ),

            BottomSheetButtons(
              onCancel: () => Navigator.pop(context),
              onConfirm: () {
                Navigator.pop(context);
              },
            )
          
          ],
        );
      
  }
}
