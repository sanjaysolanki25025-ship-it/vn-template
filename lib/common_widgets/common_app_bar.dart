import 'package:flutter/material.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? leading;

  const CommonAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.backgroundColor,
    this.textColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryColor;
    final txtColor = textColor ?? AppColors.whiteColor;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: CommonTextWidget(
        text: title,
        textStyle: size18TextStyle(
          fontWeight: FontWeight.w600,
          textColor: txtColor,
        ),
      ),
      iconTheme: IconThemeData(color: txtColor),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
