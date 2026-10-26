import 'package:desilynks/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:desilynks/models/user_model.dart';
import 'package:desilynks/app/routes.dart';
import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_constants.dart';
import 'package:desilynks/core/constants/app_strings.dart';
import 'package:desilynks/viewmodels/notifications/notifications_viewmodel.dart';
import 'package:desilynks/widgets/user_avatar.dart';

class HomeHeader extends StatelessWidget {
  final UserModel? user;
  final String welcomeName;
  final String locationText;
  final VoidCallback onMenuPressed;

  const HomeHeader({
    super.key,
    required this.user,
    required this.welcomeName,
    required this.locationText,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          photoUrl: user?.profilePhotoUrl,
          size: AppConstants.borderRadius24 * 2,
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${AppStrings.goodMorningPrefix}$welcomeName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSize,
                        color: AppColors.slate500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.padding4),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: AppConstants.fontSize),
                  ),
                ],
              ),
              Text(
                locationText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeXL,
                  color: AppColors.slate800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        // Notification bell with live unread count badge
        Consumer<NotificationsViewModel>(
          builder: (context, notifVm, _) {
            final count = notifVm.unreadCount;
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      AppIcons.notificationSvg,
                      width: AppConstants.iconSize,
                      height: AppConstants.iconSize,
                      colorFilter: const ColorFilter.mode(
                        AppColors.slate700,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        // Hamburger menu
        Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              AppIcons.menuSvg,
              width: AppConstants.iconSize,
              height: AppConstants.iconSize,
              colorFilter: const ColorFilter.mode(
                AppColors.slate700,
                BlendMode.srcIn,
              ),
            ),
            onPressed: onMenuPressed,
          ),
        ),
      ],
    );
  }
}
