import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';
import 'package:vn_template/screens/subscription/widgets/info_bottomsheet_widget.dart';
import 'package:vn_template/screens/subscription/widgets/trial_button_widget.dart';
import 'package:vn_template/screens/subscription/widgets/faq_widget.dart';
import 'package:vn_template/core/utils/common_functions.dart';
import 'package:vn_template/common_widgets/common_toast.dart';
import 'package:vn_template/screens/subscription/bloc/subscription_bloc.dart';
import 'package:vn_template/screens/subscription/bloc/subscription_event.dart';
import 'package:vn_template/screens/subscription/bloc/subscription_state.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({Key? key}) : super(key: key);

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.transparentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.whiteColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.premiumGradientStart, AppColors.premiumGradientEnd],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 40, left: 24.0, right: 24.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // UNLOCK ALL VIDEOS
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(color: AppColors.whiteColor.withOpacity(0.1), width: 1),
                          ),
                        ),
                        child: CommonTextWidget(
                          text: AppStrings.txtUnlockAllVideos,
                          textStyle: size16TextStyle(textColor: AppColors.amberColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SBH40(),
                      // Main Offer
                      CommonTextWidget(
                        text: AppStrings.txtTry1DayFor,
                        textAlign: TextAlign.center,
                        textStyle: size24TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.bold),
                      ),
                      const SBH10(),
                      // Giant ₹1
                      Text(
                        AppStrings.txtRupee1,
                        textAlign: TextAlign.center,
                        style: size24TextStyle(
                          textColor: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ).copyWith(fontSize: 80),
                      ),
                      const SBH40(),
                      // Then ₹29/month with autopay
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonTextWidget(
                            text: AppStrings.txtThen29MonthWith,
                            textStyle: size16TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.w600),
                          ),
                          const SBW10(),
                          GestureDetector(
                            onTap: () {
                              CommonBottomSheet.showBottomSheet(
                                context: context,
                                widget: const InfoBottomSheetWidget(
                                  icon: Icons.autorenew,
                                  title: AppStrings.txtHowAutopayWorks,
                                  description: AppStrings.txtAutopayDescription,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.autorenew, color: AppColors.whiteColor, size: 16),
                                  const SBW5(),
                                  CommonTextWidget(
                                    text: AppStrings.txtAutopay,
                                    textStyle: size14TextStyle(textColor: AppColors.whiteColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SBH15(),
                      // Cancel Anytime
                      GestureDetector(
                        onTap: () {
                          CommonBottomSheet.showBottomSheet(
                            context: context,
                            widget: const InfoBottomSheetWidget(
                              icon: Icons.help_outline,
                              title: AppStrings.txtHowToCancel,
                              description: AppStrings.txtCancelDescription,
                            ),
                          );
                        },
                        child: CommonTextWidget(
                          text: AppStrings.txtCancelAnytime,
                          textStyle: size14TextStyle(textColor: AppColors.trialButtonBlue),
                        ),
                      ),
                      const SBH40(),
                      // VN Plus Benefits
                      CommonTextWidget(
                        text: AppStrings.txtVNPlusBenefits,
                        textStyle: size18TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.bold),
                      ),
                      const SBH20(),
                      // Benefits List
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.whiteColor.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: const [
                            _BenefitItem(icon: Icons.block, text: AppStrings.txtNoAds),
                            const SBH15(),
                            _BenefitItem(icon: Icons.auto_awesome_mosaic, text: AppStrings.txtUnlockPremiumTemplates),
                            const SBH15(),
                            _BenefitItem(icon: Icons.monetization_on, text: AppStrings.txtGetBonusCoin),
                          ],
                        ),
                      ),
                      const SBH30(),
                      // FAQ Widget
                      const FaqWidget(),
                    ],
                  ),
                ),
              ),
            ),
            // Pinned Bottom Button
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 30.0, top: 10.0),
              child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.read<SubscriptionBloc>().add(ToggleTermsAcceptedEvent());
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              state.isTermsAccepted ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: state.isTermsAccepted ? AppColors.amberColor : AppColors.whiteColor,
                              size: 20,
                            ),
                            const SBW10(),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: size14TextStyle(textColor: AppColors.whiteColor),
                                  children: [
                                    const TextSpan(text: AppStrings.txtByContinuingYouAgreeToOur),
                                    TextSpan(
                                      text: AppStrings.txtTerms,
                                      style: size14TextStyle(textColor: AppColors.amberColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          CommonFunction.launchUrlLink(AppStrings.termConditionUrl);
                                        },
                                    ),
                                    const TextSpan(text: AppStrings.txtAndSymbol),
                                    TextSpan(
                                      text: AppStrings.txtSubscriptionPrivacyPolicy,
                                      style: size14TextStyle(textColor: AppColors.amberColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          CommonFunction.launchUrlLink(AppStrings.privacyPolicyUrl);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SBH20(),
                      TrialButtonWidget(
                        onTap: () {
                          if (!state.isTermsAccepted) {
                            CommonToast.showToast(
                              context: context,
                              message: AppStrings.txtPleaseAcceptTerms,
                              isError: true,
                            );
                            return;
                          }
                          // Handle subscription action
                        },
                        onCancelTap: () {
                          CommonBottomSheet.showBottomSheet(
                            context: context,
                            widget: const InfoBottomSheetWidget(
                              icon: Icons.help_outline,
                              title: AppStrings.txtHowToCancel,
                              description: AppStrings.txtCancelDescription,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({Key? key, required this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.amberColor.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.amberColor, size: 20),
        ),
        const SBW15(),
        Expanded(
          child: CommonTextWidget(
            text: text,
            textStyle: size16TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
