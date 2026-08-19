import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:vn_template/screens/template_detail/bloc/template_detail_bloc.dart';
import 'package:vn_template/common_widgets/common_image.dart';
import 'package:vn_template/common_widgets/common_loader.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/data/models/template_model.dart';

class TemplateVideoPlayerWidget extends StatelessWidget {
  final TemplateModel template;

  const TemplateVideoPlayerWidget({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final String videoUrl = template.previewVideo ?? '';
    final lowerUrl = videoUrl.toLowerCase();
    final isImage = lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('.webp');

    if (isImage && videoUrl.isNotEmpty) {
      return Center(
        child: SizedBox(
          height: 350,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CommonImage(
              assetName: videoUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return BlocBuilder<TemplateDetailBloc, TemplateDetailState>(
      builder: (context, state) {
        if (state.status == TemplateDetailStatus.loading) {
          return const SizedBox(
            height: 200,
            child: Center(child: CommonLoader()),
          );
        }

        if (state.status == TemplateDetailStatus.loaded &&
            state.videoPlayerController != null) {
          final isPlaying = state.videoPlayerController!.value.isPlaying;
          return Center(
            child: GestureDetector(
              onTap: () {
                context.read<TemplateDetailBloc>().add(TogglePlayPauseEvent());
              },
              child: SizedBox(
                height: 350,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: state.videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(state.videoPlayerController!),
                      ),
                    ),
                    if (!isPlaying)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.blackColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppColors.whiteColor,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        if (template.previewImage != null &&
            template.previewImage!.isNotEmpty) {
          return Center(
            child: SizedBox(
              height: 350,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CommonImage(
                  assetName: template.previewImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        return const SizedBox(
          height: 200,
          child: Center(child: CommonLoader()),
        );
      },
    );
  }
}
