import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/screens/discover/bloc/discover_bloc.dart';
import 'package:vn_template/screens/discover/view/discover_view.dart';
import 'package:vn_template/screens/home/bloc/home_bloc.dart';
import 'package:vn_template/screens/home/view/home_view.dart';
import 'package:vn_template/screens/favourite/bloc/favourite_bloc.dart';
import 'package:vn_template/screens/favourite/view/favourite_view.dart';
import 'package:vn_template/screens/setting/view/setting_view.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/common_widgets/common_toast.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final List<int> _navigationStack = [0];
  DateTime? _lastBackPressTime;

  final List<String> _tabNames = [
    AppStrings.txtHome,
    AppStrings.txtDiscover,
    AppStrings.txtFavourite,
    AppStrings.txtSetting,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (state.currentIndex == 0) {
              final now = DateTime.now();
              if (_lastBackPressTime == null ||
                  now.difference(_lastBackPressTime!) >
                      const Duration(seconds: 2)) {
                _lastBackPressTime = now;
                CommonToast.showToast(
                  isError: false,
                  context: context,
                  message: AppStrings.txtPressBackAgainToExit.getString(
                    context,
                  ),
                );
                NativeAdManager().preCacheAd(AppAdIdString.exitAppNativeAd);
                return false;
              } else {
                CommonBottomSheet.showCommonBottomSheet(
                  context: context,
                  title: AppStrings.txtExitAppDescription.getString(context),
                  adId: AppAdIdString.exitAppNativeAd,
                  firstButtonText: AppStrings.txtNo.getString(context),
                  firstButtonOnTap: () {
                    Navigator.pop(context);
                  },
                  secondButtonText: AppStrings.txtYes.getString(context),
                  secondButtonOnTap: () {
                    SystemNavigator.pop();
                  },
                );
                return false;
              }
            } else {
              if (_navigationStack.length > 1) {
                _navigationStack.removeLast();
                final previousIndex = _navigationStack.last;
                context.read<DashboardBloc>().add(
                  OnTapDashboardEvent(index: previousIndex),
                );
                if (previousIndex == 0) {
                  context.read<HomeBloc>().add(
                    SetReelsPausedEvent(paused: false),
                  );
                } else {
                  context.read<HomeBloc>().add(SetReelsPausedEvent(paused: true));
                }
                return false;
              } else {
                return true;
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.primaryColor,
            appBar:
                (state.currentIndex == 0 ||
                    state.currentIndex == 1 ||
                    state.currentIndex == 2 ||
                    state.currentIndex == 3)
                ? null
                : CommonAppBar(
                    title: _tabNames[state.currentIndex].getString(context),
                  ),
            body: IndexedStack(
              index: state.currentIndex,
              children: [
                const HomeView(),
                BlocProvider(
                  create: (context) => DiscoverBloc(),
                  child: const DiscoverView(),
                ),
                BlocProvider(
                  create: (context) => FavouriteBloc(),
                  child: const FavouriteView(),
                ),
                const SettingView(),
              ],
            ),
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                splashColor: AppColors.transparentColor,
                highlightColor: AppColors.transparentColor,
                hoverColor: AppColors.transparentColor,
              ),
              child: BottomNavigationBar(
                currentIndex: state.currentIndex,
                backgroundColor: AppColors.primaryColor,
                selectedItemColor: AppColors.accentColor,
                unselectedItemColor: AppColors.whiteColor,
                type: BottomNavigationBarType.fixed,
                onTap: (value) {
                  if (state.currentIndex != value) {
                    _navigationStack.remove(value);
                    _navigationStack.add(value);
                    context.read<DashboardBloc>().add(
                      OnTapDashboardEvent(index: value),
                    );
                    if (value == 0) {
                      context.read<HomeBloc>().add(
                        SetReelsPausedEvent(paused: false),
                      );
                    } else {
                      context.read<HomeBloc>().add(
                        SetReelsPausedEvent(paused: true),
                      );
                    }
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: AppStrings.txtHome.getString(context),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.explore),
                    label: AppStrings.txtDiscover.getString(context),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.favorite),
                    label: AppStrings.txtFavourite.getString(context),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: AppStrings.txtSetting.getString(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
