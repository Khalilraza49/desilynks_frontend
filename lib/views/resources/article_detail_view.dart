import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:desilynks/core/constants/app_colors.dart';
import 'package:desilynks/core/constants/app_icons.dart';
import 'package:desilynks/models/resource_hub_model.dart';
import 'package:desilynks/services/permissions/app_toast.dart';
import 'package:desilynks/viewmodels/resources/resource_hub_viewmodel.dart';

class ArticleDetailView extends StatelessWidget {
  final String articleId;
  final ResourceHubArticle? initialArticle;

  const ArticleDetailView({
    super.key,
    required this.articleId,
    this.initialArticle,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _launchUrl(String? href) async {
    if (href == null || href.trim().isEmpty) return;
    try {
      final uri = Uri.parse(href.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppToast.showError('Could not open: $href');
      }
    } catch (_) {
      AppToast.showError('Invalid URL format');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ResourceHubViewModel>();
      if (vm.currentDetailArticle?.id != articleId && !vm.isLoadingDetail) {
        vm.fetchArticleDetail(articleId);
      }
    });

    return Consumer<ResourceHubViewModel>(
      builder: (context, vm, child) {
        final article = vm.currentDetailArticle ?? initialArticle;
        final isSaved = article?.isSaved ?? false;

        return Scaffold(
          backgroundColor: AppColors.backgroundOffWhite,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                AppIcons.arrowBackSvg,
                colorFilter: const ColorFilter.mode(
                  AppColors.slate900,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              article?.category.label ?? 'Resource Article',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            centerTitle: false,
            titleSpacing: 0,
            actions: [
              if (article != null)
                IconButton(
                  icon: SvgPicture.asset(
                    isSaved ? AppIcons.bookmark_filled : AppIcons.bookmark,
                    colorFilter: ColorFilter.mode(
                      isSaved ? AppColors.primaryBlue : AppColors.slate700,
                      BlendMode.srcIn,
                    ),
                    width: 22,
                    height: 22,
                  ),
                  tooltip: isSaved ? 'Remove from saved' : 'Save article',
                  onPressed: () => vm.toggleSaveArticle(article),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (vm.isLoadingDetail && article?.content == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                );
              }

              if (vm.detailErrorMessage != null && article == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.resourceSvg,
                          width: 48,
                          height: 48,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to load article',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vm.detailErrorMessage ?? 'Something went wrong.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.slate500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => vm.fetchArticleDetail(articleId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (article == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.resourceSvg,
                          width: 48,
                          height: 48,
                          colorFilter: const ColorFilter.mode(
                            AppColors.slate400,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Article not found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This article may have been removed or deleted.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Chip and Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: article.category.bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  article.category.iconSvg,
                                  width: 14,
                                  height: 14,
                                  colorFilter: ColorFilter.mode(
                                    article.category.tagColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  article.category.label.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: article.category.tagColor,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (article.isUpdated)
                            Text(
                              'Updated ${_formatDate(article.updatedAt)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.slate400,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else
                            Text(
                              _formatDate(article.createdAt),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.slate400,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Author & Metadata
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                AppIcons.personSvg,
                                width: 14,
                                height: 14,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primaryBlue,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'By ${article.authorName}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.slate200, height: 1),
                      const SizedBox(height: 20),

                      // Markdown Content
                      if (article.content != null && article.content!.isNotEmpty)
                        MarkdownBody(
                          data: article.content!,
                          selectable: true,
                          extensionSet: md.ExtensionSet.gitHubFlavored,
                          onTapLink: (text, href, title) => _launchUrl(href),
                          sizedImageBuilder: (config) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  config.uri.toString(),
                                  width: config.width,
                                  height: config.height,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 160,
                                    width: double.infinity,
                                    color: AppColors.slate100,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            AppIcons.resourceSvg,
                                            width: 32,
                                            height: 32,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.slate400,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            config.alt ?? 'Image unavailable',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.slate400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.slate800,
                              height: 1.65,
                            ),
                            h1: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              height: 1.4,
                            ),
                            h2: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              height: 1.4,
                            ),
                            h3: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              height: 1.4,
                            ),
                            blockquote: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.slate700,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: const Border(
                                left: BorderSide(
                                  color: AppColors.primaryBlue,
                                  width: 4,
                                ),
                              ),
                            ),
                            blockquotePadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            code: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: AppColors.primaryBlue,
                              backgroundColor: Color(0xFFF1F5F9),
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            codeblockPadding: const EdgeInsets.all(14),
                            horizontalRuleDecoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppColors.slate200,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            tableBody: const TextStyle(
                              fontSize: 13,
                              color: AppColors.slate800,
                            ),
                            tableHead: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                            ),
                            tableBorder: TableBorder.all(
                              color: AppColors.slate200,
                              width: 1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tableCellsPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            listBullet: const TextStyle(
                              fontSize: 14.5,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else if (vm.isLoadingDetail)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No content available for this guide.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.slate400,
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
