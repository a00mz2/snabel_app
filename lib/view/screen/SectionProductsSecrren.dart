import 'package:customer/controller/SectionProductsController.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:customer/view/widget/SectionProductsWidget/SectionTabsWidget.dart';
import 'package:customer/view/widget/widgetApp/PaginationIndicator.dart';
import 'package:customer/view/widget/widgetApp/ProductGridWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class SectionProductsSecrren extends GetView<SectionProductsController> {
  const SectionProductsSecrren({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double itemWidth = 135;
    const double sidePadding = 16;
    const double spacing = 10;
    final int crossAxisCount =
        ((screenWidth - 2 * sidePadding + spacing) / (itemWidth + spacing))
            .floor();

    return Obx(
      () => ScaffoldWidget(
        onRefresh: () => controller.getProducts(),
        isSub: true,
        namePage: controller.categoryName.value,
        iconPage: controller.categoryImage.value.isEmpty
            ? null
            : AppNetworkImage(
                imageUrl: Applink.categoryImage(controller.categoryImage.value),
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                compact: true,
              ),
        statusCode: controller.statusCode,
        statusRequest: controller.statusRequest,
        heder: _buildHeader(),
        bottomNavigationBar: _buildPaginationIndicator(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: controller.listProducts.isEmpty
              ? _buildEmptyState()
              : _buildProductGrid(crossAxisCount, spacing),
        ),
      ),
    );
  }

  // بقية الميثودات تبقى كما هي دون تغيير
  Widget _buildProductGrid(int crossAxisCount, double spacing) {
    return AnimationLimiter(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        controller: controller.scrollController,
        itemCount: controller.listProducts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisExtent: 226,
          crossAxisSpacing: spacing,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final product = controller.listProducts[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: crossAxisCount,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ProductGridWidget(
                  productId: product['_id'],
                  inFavorites: product['isFavorite'] ?? false,
                  index: index,
                  image: Applink.productImage(
                    product['images'][product['mainImageIndex'] ?? 0]['name']
                        ?.toString(),
                  ),
                  available: true,
                  name: product['name'],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextBoxs(
            onChanged: (_) => controller.onSearchChanged(),
            controller: controller.textSearchController,
            hintText: "ابحث باسم المنتج ...",
            suffixIcon: IconButton(
              onPressed: () => controller.textSearchController.clear(),
              icon: const Icon(Icons.close),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 24),
        if (!controller.favoritesOnly) ...[
          const SectionTabsWidget(),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppIcons.box, width: 100),
          const SizedBox(height: 10),
          const Text("لا توجد منتجات في الوقت الحالي"),
        ],
      ),
    );
  }

  Widget _buildPaginationIndicator() {
    return SizedBox(
      width: Get.width,
      child: PaginationIndicator(
        index: controller.listProducts.length - 1,
        listlength: controller.listProducts.length,
        statusRequestPagination: controller.statusRequestPagination.value,
      ),
    );
  }
}
