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

/******    New Custom Dialog with various types of dialog animations ***********/

enum DialogType {
  success,
  error,
  info,
  message,
  cancel,
}

enum DialogAnimationType {
  fade,
  scale,
  slideFromTop,
  slideFromBottom,
  slideFromLeft,
  slideFromRight,
  rotateClockwise,
  rotateCounterClockwise,
}

class CustomAlert extends StatefulWidget {
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
  final Widget? confirmButtonIcon;
  final Widget? cancelButtonIcon;
  final Function(BuildContext context)? cancelCallBack;
  final Function(BuildContext context)? confirmCallBack;
  final Function(BuildContext context)? crossCallBack;
  final VoidCallback? cancelButtonCallback;
  final VoidCallback? confirmButtonCallback;
  final VoidCallback? crossButtonCallback;
  final DialogType? dialogType;
  final Image? dialogImage;
  final bool? showImage;
  final bool? scrollable;
  final DialogAnimationType? animationType;

  const CustomAlert(BuildContext context, {
    super.key,
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
    this.confirmButtonIcon,
    this.cancelButtonIcon,
    this.dialogType,
    this.dialogImage,
    this.showImage,
    this.scrollable,
    this.animationType, bool? scrollAble,
  });

  @override
  CustomAlertState createState() => CustomAlertState();
}

class CustomAlertState extends State<CustomAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotatingAnimation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = _getSlideAnimation();
    _rotatingAnimation = _getRotatingAnimation();
    _animationController.forward();
  }

  Animation<Offset> _getSlideAnimation() {
    switch (widget.animationType) {
      case DialogAnimationType.slideFromTop:
        return Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
      case DialogAnimationType.slideFromBottom:
        return Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
      case DialogAnimationType.slideFromLeft:
        return Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
      case DialogAnimationType.slideFromRight:
        return Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
      default:
        return Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
          CurvedAnimation(
              parent: _animationController, curve: Curves.easeInOut),
        );
    }
  }

  Animation<double> _getRotatingAnimation() {
    switch (widget.animationType) {
      case DialogAnimationType.rotateClockwise:
        return Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
      case DialogAnimationType.rotateCounterClockwise:
        return Tween<double>(begin: -1.0, end: 0.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
      default:
        return Tween<double>(begin: 0.0, end: -1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
        );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getIcon(DialogType? dialogType) {
    if (dialogType == null) {
      return AppIcons.messageDialogIcon;
    }
    switch (dialogType) {
      case DialogType.success:
        return AppIcons.successDialogIcon;
      case DialogType.error:
        return AppIcons.errorDialogIcon;
      case DialogType.info:
        return AppIcons.infoDialogIcon;
      case DialogType.message:
        return AppIcons.messageDialogIcon;
      case DialogType.cancel:
        return AppIcons.cancelAppointmentDialogIcon;
      default:
        return AppIcons.messageDialogIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        Widget animatedChild = child!;
        switch (widget.animationType) {
          case DialogAnimationType.fade:
            animatedChild = Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            );
            break;
          case DialogAnimationType.scale:
            animatedChild = Transform.scale(
              scale: _opacityAnimation.value,
              child: child,
            );
            break;
          case DialogAnimationType.slideFromTop:
          case DialogAnimationType.slideFromBottom:
          case DialogAnimationType.slideFromLeft:
          case DialogAnimationType.slideFromRight:
            animatedChild = SlideTransition(
              position: _slideAnimation,
              child: child,
            );
            break;
          case null:
            animatedChild = Transform.scale(
              scale: _opacityAnimation.value,
              child: child,
            );
          case DialogAnimationType.rotateClockwise:
            animatedChild = Transform.rotate(angle: _rotatingAnimation.value * 3.14159, child: child);
            break;
          case DialogAnimationType.rotateCounterClockwise:
            animatedChild = Transform.rotate(angle: _rotatingAnimation.value * -3.14159, child: child);
            break;
        }
        return animatedChild;
      },
      child: AlertDialog(
        scrollable: widget.scrollable ?? false,
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 13.0, right: 10.0),
              padding:
                  const EdgeInsets.only(top: 10, bottom: 20, left: 5, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(width: double.maxFinite),
                      if (((widget.showImage ?? true)) &&
                          (widget.dialogImage == null))
                        Image.asset(
                          getIcon(widget.dialogType),
                          scale: (widget.dialogType == DialogType.message)
                              ? 1.7
                              : (widget.dialogType == DialogType.cancel)
                                  ? 1.8
                                  : 3.5,
                        ),
                      if (widget.dialogImage != null) widget.dialogImage!,
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.titleWidget == null)
                    Text(
                      widget.title ?? "",
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  else
                    widget.titleWidget!,
                  const SizedBox(height: 10),
                  if (widget.content == null)
                    Text(
                      widget.contentText ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    )
                  else
                    widget.content!,
                  const SizedBox(height: 15),
                  if (widget.showButtons ?? true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: widget.cancelButtonCallback ??
                              () async {
                                if (widget.cancelCallBack != null) {
                                  widget.cancelCallBack!(context);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 100,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.0),
                                    offset: Offset(0, 0),
                                    blurRadius: 22,
                                  )
                                ],
                                border: Border.all(
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (widget.cancelButtonIcon != null) ...[
                                        widget.cancelButtonIcon!,
                                        const SizedBox(width: 5),
                                      ],
                                      Text(
                                        widget.cancelButtonText ?? 'Cancel',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: widget.confirmButtonCallback ??
                              () {
                                if (widget.confirmCallBack != null) {
                                  widget.confirmCallBack!(context);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                          splashColor: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: const Color.fromRGBO(60, 150, 230, 1),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 100,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.0),
                                    offset: Offset(0, 0),
                                    blurRadius: 22,
                                  )
                                ],
                                color: const Color.fromRGBO(16, 106, 186, 1),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color.fromRGBO(60, 150, 230, 1),
                                    Color.fromRGBO(16, 106, 186, 1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (widget.confirmButtonIcon != null) ...[
                                        widget.confirmButtonIcon!,
                                        const SizedBox(width: 5),
                                      ],
                                      Text(
                                        widget.confirmButtonText ?? 'Confirm',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (widget.showCrossButton ?? false)
              Positioned(
                right: 0.0,
                child: InkWell(
                  onTap: widget.crossButtonCallback ??
                      () {
                        if (widget.crossCallBack != null) {
                          widget.crossCallBack!(context);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future showCustomDialog(
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
      bool? showCrossButton,
      DialogType? dialogType,
      bool? showImage,
      bool? scrollable,
      bool? barrierDismissible,
      DialogAnimationType? animationType,
    }) async {
  await showDialog(
    context: context,
    builder: (context) {
      return CustomAlert(
        context,
        title: title,
        scrollAble: scrollable,
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
        dialogType: dialogType,
        showCrossButton: showCrossButton,
        showImage: showImage, animationType: animationType,
      );
    },
    barrierDismissible: barrierDismissible ?? true,
  );
}
