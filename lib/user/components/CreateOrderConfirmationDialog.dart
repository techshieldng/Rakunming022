import 'package:flutter/material.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main/utils/Widgets.dart';

import '../../main.dart';

class CreateOrderConfirmationDialog extends StatefulWidget {
  static String tag = '/CreateOrderConfirmationDialog';
  final Function() onSuccess;
  final Function()? onCancel;
  final String? message;
  final String? primaryText;

  CreateOrderConfirmationDialog({required this.onSuccess, required this.message, this.primaryText, this.onCancel});

  @override
  CreateOrderConfirmationDialogState createState() => CreateOrderConfirmationDialogState();
}

class CreateOrderConfirmationDialogState extends State<CreateOrderConfirmationDialog> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.confirmation, style: boldTextStyle(size: 18)),
            CloseButton(),
          ],
        ),
        16.height,
        Text(widget.message!, style: primaryTextStyle(size: 16)),
        30.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            commonButton(language.cancel, () {
              widget.onCancel != null ? widget.onCancel!.call() : finish(context);
            }, color: Colors.grey),
            16.width,
            commonButton(widget.primaryText ?? language.create, widget.onSuccess),
          ],
        ),
      ],
    );
  }
}
