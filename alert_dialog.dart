import 'package:flutter/material.dart';

Future alertDialogNew(
    BuildContext context, {
      String? title,
      Widget? titleWidget,
      String? contentText,
      Widget? content,
      String? confirmButtonText,
      String? cancelButtonText,
      bool? showButtons,
      Function(BuildContext context)? cancelCallBack,
      Function(BuildContext context)? confirmCallBack,
      Function(BuildContext context)? crossCallBack,
      VoidCallback? cancelButtonCallback,
      VoidCallback? confirmButtonCallback,
      VoidCallback? crossButtonCallback,
    }) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialogNew(
          context,
          title: title,
          titleWidget: titleWidget,
          contentText: contentText,
          content: content,
          confirmButtonText: confirmButtonText,
          cancelButtonText: cancelButtonText,
          showButtons: showButtons,
          cancelCallBack: cancelCallBack,
          confirmCallBack: confirmCallBack,
          crossCallBack: crossCallBack,
          cancelButtonCallback: cancelButtonCallback,
          confirmButtonCallback: confirmButtonCallback,
          crossButtonCallback: crossButtonCallback,
        );
      });
}

///New Dialog Widget as per given UI
///
///Provide Either titleText or titleWidget, contentText or contentWidget
class AlertDialogNew extends StatelessWidget {
  final BuildContext context;
  final BorderRadius? borderRadius;
  final double? height;
  final String? title;
  final Widget? titleWidget;
  final String? contentText;
  final Widget? content;
  final bool? showButtons;
  final bool? showCrossButton;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final Function(BuildContext context)? cancelCallBack;
  final Function(BuildContext context)? confirmCallBack;
  final Function(BuildContext context)? crossCallBack;
  final VoidCallback? cancelButtonCallback;
  final VoidCallback? confirmButtonCallback;
  final VoidCallback? crossButtonCallback;
  const AlertDialogNew(
      this.context, {
        this.height,
        this.borderRadius,
        this.title,
        this.titleWidget,
        this.contentText,
        this.content,
        this.showButtons,
        this.showCrossButton,
        this.confirmButtonText,
        this.confirmButtonCallback,
        this.cancelButtonText,
        this.cancelButtonCallback,
        this.cancelCallBack,
        this.confirmCallBack,
        this.crossCallBack,
        this.crossButtonCallback,
        Key? key,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: titleWidget ??
                        Text(
                          title ?? 'Dialog Title',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                  ),
                  if (showCrossButton ?? true)
                    Positioned(
                      right: 10,
                      top: 8,
                      child: InkWell(
                        onTap: crossButtonCallback ??
                                () async {
                              if (crossCallBack != null) {
                                crossCallBack!(context);
                              } else {
                                Navigator.of(context).pop(true);
                              }
                            },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 25,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: content ??
                    Text(
                      contentText ??
                          'Dialog Sample Text For Testing Long Texts and Paragraphs for ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (showButtons ?? true)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: cancelButtonCallback ??
                            () {
                          if (cancelCallBack != null) {
                            cancelCallBack!(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.red),
                        fixedSize: const Size(100, 50)),
                    child: Text(
                      cancelButtonText ?? 'Cancel',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: confirmButtonCallback ??
                            () async {
                          if (confirmCallBack != null) {
                            confirmCallBack!(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        fixedSize: const Size(100, 50)),
                    child: Text(
                      confirmButtonText ?? 'Confirm',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}