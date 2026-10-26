Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: photos.isNotEmpty
                      ? PageView.builder(
                          controller: viewModel.singlePropertyPageController,
                          onPageChanged: (int page) {
                            viewModel.setSinglePropertyPageIndex(page);
                          },
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final imageUrl = viewModel.resolvePropertyImageUrl(
                              photos[index].url,
                              fallback:
                                  'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
                            );
                            return GestureDetector(
                              onTap: () => _openFullScreenImageViewer(
                                context,
                                photos,
                                index,
                                viewModel,
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: AppColors.slate100,
                                  child: SvgPicture.asset(
                                    AppIcons.gallerySvg,
                                    width: 60,
                                    height: 60,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.gray500,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.slate100,
                          child: SvgPicture.asset(
                            AppIcons.gallerySvg,
                            width: 60,
                            height: 60,
                            colorFilter: const ColorFilter.mode(
                              AppColors.gray500,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                ),

                // Back Button (Top Left)
                Positioned(
                  left: 20,
                  top: MediaQuery.of(context).padding.top + 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        AppIcons.arrowBackSvg,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),

                // Top Right Action Buttons (Heart and Share)
                Positioned(
                  right: 20,
                  top: MediaQuery.of(context).padding.top + 10,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final newStatus =
                              await viewModel.toggleSinglePropertyLike(
                            activeProperty,
                            favViewModel,
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newStatus
                                    ? 'Added to Favourite Ads'
                                    : 'Removed from Favourite Ads',
                              ),
                              duration: const Duration(seconds: 2),
                              action: newStatus
                                  ? SnackBarAction(
                                      label: 'View',
                                      textColor: AppColors.accentYellow,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.favouriteAds,
                                        );
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            AppIcons.favSvg,
                            colorFilter: ColorFilter.mode(
                              isLiked
                                  ? AppColors.primaryRed
                                  : AppColors.white,
                              BlendMode.srcIn,
                            ),
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Share Button
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          AppIcons.shareSvg,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Blue Tag Overlay (Bottom Left): "Posted X hours ago"
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.vibrantBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      postTimeAgo,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppConstants.fontSizeSM,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Photo Counter Overlay (Bottom Right): "1/6"
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _openFullScreenImageViewer(
                      context,
                      photos,
                      currentPage,
                      viewModel,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentPage + 1}/$totalPhotos',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: AppConstants.fontSizeXS11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
