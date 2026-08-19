import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_textfield.dart';
import 'package:vn_template/common_widgets/common_toast.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/core/utils/app_validations.dart';
import 'package:vn_template/data/models/feedback_model.dart';
import 'package:vn_template/screens/feedback_center/bloc/feedback_center_bloc.dart';
import 'package:vn_template/screens/feedback_center/widgets/reference_image_card.dart';
import 'package:vn_template/screens/feedback_center/widgets/selected_feedback_card.dart';

class FeedbackCenterView extends StatefulWidget {
  const FeedbackCenterView({super.key});

  @override
  State<FeedbackCenterView> createState() => _FeedbackCenterViewState();
}

class _FeedbackCenterViewState extends State<FeedbackCenterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CommonAppBar(title: AppStrings.txtFeedbackCenter.getString(context)),
      ),

      body: BlocListener<FeedbackCenterBloc, FeedbackCenterState>(
        listener: (context, state) {
          if (state.status == FeedbackCenterStatus.error || state.status == FeedbackCenterStatus.submitError) {
            CommonToast.showToast(
              context: context,
              message: state.errorMessage != null ? state.errorMessage!.getString(context) : AppStrings.txtSomethingWentWrong.getString(context),
              isError: true,
            );
          } else if (state.status == FeedbackCenterStatus.submitLoading) {
            CommonDialog.loaderDialog(context: context);
          } else if (state.status == FeedbackCenterStatus.submitLoaded) {
            CommonDialog.closeDialog(context: context);
            context.pop();
          }
        },
        child: BlocBuilder<FeedbackCenterBloc, FeedbackCenterState>(
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: SingleChildScrollView(
                  child: Form(
                    key: context.read<FeedbackCenterBloc>().formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SBH10(),
                        CommonTextWidget(
                          text: AppStrings.txtWeLove.getString(context),
                          textStyle: size20TextStyle(
                            textColor: AppColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CommonTextWidget(
                          text: AppStrings.txtYourFeedback.getString(context),
                          isUnderline: true,
                          textStyle: size20TextStyle(
                            textColor: AppColors.accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SBH5(),
                        CommonTextWidget(
                          text: AppStrings.txtWeValueYourFeedbackAndUseItToMakeTheAppBetter.getString(context),
                          textStyle: size14TextStyle(
                            textColor: AppColors.greyColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SBH15(),

                        /// selected feedback card
                        SelectedFeedbackCard(isSelectedFeedback: state.selectedOption),
                        const SBH15(),

                        /// phone number
                        CommonTextWidget(
                          text: AppStrings.txtPhoneNumber.getString(context),
                          textStyle: size16TextStyle(
                            textColor: AppColors.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SBH5(),

                        /// Phone number field
                        CommonTextField(
                          focusNode: FocusNode(),
                          hintText: AppStrings.txtEnterPhoneNumber.getString(context),
                          maxLines: 1,
                          controller: context.read<FeedbackCenterBloc>().phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            return AppValidations.validateNotEmpty(
                              errorMessage: AppStrings.txtPleaseEnterThisField.getString(context),
                              inputValue: value ?? '',
                            );
                          },
                        ),
                        const SBH15(),

                        /// facing issue
                        CommonTextWidget(
                          text: AppStrings.txtWhatIssueAreYouFacing.getString(context),
                          textStyle: size16TextStyle(
                            textColor: AppColors.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SBH5(),

                        /// issue facing
                        CommonTextField(
                          focusNode: FocusNode(),
                          hintText: AppStrings.txtWhatIssueAreYouFacing.getString(context),
                          maxLines: 5,
                          controller: context.read<FeedbackCenterBloc>().facingIssueController,
                          validator: (value) {
                            return AppValidations.validateNotEmpty(
                              errorMessage: AppStrings.txtPleaseEnterThisField.getString(context),
                              inputValue: value ?? '',
                            );
                          },
                        ),
                        const SBH15(),

                        /// terms and condition
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: state.isChecked ?? false,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                activeColor: AppColors.accentColor,
                                checkColor: AppColors.blackColor,
                                side: const BorderSide(color: AppColors.greyColor),
                                onChanged: (value) {
                                  context.read<FeedbackCenterBloc>().add(
                                    CheckedTermConditionEvent(isChecked: value ?? false),
                                  );
                                },
                              ),
                            ),

                            const SBW5(),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: CommonTextWidget(
                                  text: AppStrings.txtAgreeToPrivacyPolicyTerms.getString(context),
                                  maxLine: 2,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  minFontSize: 12,
                                  textStyle: size14TextStyle(
                                    textColor: AppColors.whiteColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SBH15(),

                        /// image picker
                        CommonTextWidget(
                          text: AppStrings.txtUploadReferenceImage.getString(context),
                          textStyle: size16TextStyle(
                            textColor: AppColors.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SBH5(),

                        /// reference image card
                        ReferenceImageCard(imageFile: state.imageFile),
                        const SBH30(),
                        CommonButton(
                          text: AppStrings.txtSubmit.getString(context),
                          onTap: () {
                            if (context.read<FeedbackCenterBloc>().formKey.currentState!.validate()) {
                              context.read<FeedbackCenterBloc>().add(
                                SubmitFeedbackEvent(
                                  model: FeedbackModel(
                                    id: '',
                                    feedBackCategory: state.selectedOption ?? AppStrings.txtFeedbackIssue.getString(context),
                                    description: context
                                        .read<FeedbackCenterBloc>()
                                        .facingIssueController
                                        .text,
                                    privacyPolicy: state.isChecked ?? false,
                                    referenceImage: state.imageFile?.path,
                                    phoneNumber: context
                                        .read<FeedbackCenterBloc>()
                                        .phoneNumberController
                                        .text,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SBH30(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BlocProvider(
        create: (_) => BannerAdBloc(),
        child: BannerAdWidget(adId: AppAdIdString.feedbackBannerAd),
      ),
    );
  }
}
