import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/screens/feedback_center/bloc/feedback_center_bloc.dart';

class ReferenceImageCard extends StatelessWidget {
  final File? imageFile;

  const ReferenceImageCard({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<FeedbackCenterBloc>().add(SelectedUploadImageEvent());
      },
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.secondaryColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
        ),
        child: imageFile != null && imageFile!.path.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        context.read<FeedbackCenterBloc>().add(RemoveReferenceImageEvent());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.blackColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.whiteColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: Icon(
                  Icons.add_a_photo,
                  color: AppColors.greyColor,
                  size: 32,
                ),
              ),
      ),
    );
  }
}
