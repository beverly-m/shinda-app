import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinda_app/components/circular_progress_indicator.dart';
import 'package:shinda_app/components/product_card.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/responsive/responsive_layout.dart';
import 'package:shinda_app/services/workspace/workspace_exceptions.dart';
import 'package:shinda_app/services/workspace/workspace_service.dart';
import 'package:shinda_app/utilities/get_workspace.dart';
import 'package:shinda_app/utilities/providers/cart_provider.dart';
import 'package:shinda_app/views/mobile_views/cart_items_view.dart';

class NewSaleView extends StatefulWidget {
  const NewSaleView({super.key});

  @override
  State<NewSaleView> createState() => _NewSaleViewState();
}

class _NewSaleViewState extends State<NewSaleView> {
  bool _isLoading = false;
  List<Map<String, dynamic>>? _productsData;

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().getData();

    _getProductData();
  }

  void _getProductData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> products = await WorkspaceService()
          .getPOSProducts(workspaceId: currentWorkspace!);

      if (!mounted) return;
      setState(() {
        _productsData = products;
      });

      if (_productsData != null) {
        setState(() {});
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } on GenericWorkspaceException {
      log("Error occurred");
      _isLoading = false;
    } catch (e) {
      log(e.toString());
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        scrolledUnderElevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Badge(
              backgroundColor: primary,
              textColor: Colors.white,
              label: Consumer<CartProvider>(
                builder: (context, value, child) {
                  return Text(value.getCounter().toString());
                },
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CartItemsView(),
                  ));
                },
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const AppCircularProgressIndicator()

          // ***MOBILE & TABLET WITH PRODUCTS***
          : _productsData != null && _productsData!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive.isTablet(context) ? 3 : 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _productsData!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return AspectRatio(
                        aspectRatio: 1,
                        child: ProductCard(
                          productName: _productsData![index]["product"]['name'],
                          productPrice: _productsData![index]["product"]
                              ['price'],
                          quantityInStock: _productsData![index]
                              ['quantity_available'],
                          onPressed: () async {
                            await cart.saveData(data: _productsData![index]);
                          },
                        ),
                      );
                    },
                  ),
                )

              // ***MOBILE & TABLET NO PRODUCTS***
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 180,
                            color: Color.fromRGBO(219, 240, 239, 1),
                          ),
                          SizedBox(height: 48.0),
                          Text(
                            textAlign: TextAlign.center,
                            "Add new products in the inventory to get started",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
