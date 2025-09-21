import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../view_model/record_form_provider.dart';
import '../../../../../core/widgets/bottom_sheet_buttons.dart';

class DayPicker extends ConsumerWidget {
  const DayPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final repeatingOptions = ref.watch(recordFormNotifierProvider.select((s) => s.repeatingOptions));
    List<dynamic> days = repeatingOptions?.keys.toList() ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          ...days.map(
            (day) => Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.only(left: 20, right: 10),
                  title: Text(
                    day,
                    style: TextStyle(
                      fontSize: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.fontSize,
                    ),
                  ),
                  trailing: Checkbox(
                    value: repeatingOptions?[day],
                    onChanged: null,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (repeatingOptions?[day] == true) {
                        return Theme.of(context).colorScheme.primary;
                      }
                      return Colors.transparent;
                    }),
                  ),
                  onTap: () {
                    ref.read(recordFormNotifierProvider.notifier).setRepeatingOptions({
                           ...?repeatingOptions,
                        day: !(repeatingOptions?[day]?? false),
                    });
                  },
                ),
                if (days.indexOf(day) != days.length - 1)
                  Divider(height: 1, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    ),
    BottomSheetButtons(
      onCancel: () {
        Navigator.of(context).pop();
      },
      onConfirm: () {
        Navigator.of(context).pop();
      },
    )
      ],
    );
  }
}
