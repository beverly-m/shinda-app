import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
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
  String? _currentWorkspace;

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().getData();

    _getProductData();
  }

  void _getProductData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkspace = await getCurrentWorkspaceId();

      final List<Map<String, dynamic>> products =
          await WorkspaceService().getProducts(workspaceId: currentWorkspace!);

      setState(() {
        _productsData = products;
        _currentWorkspace = currentWorkspace;
      });

      if (_productsData != null) {
        setState(() {});
      }

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
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  color: primary,
                ),
              ),
            )
          : Padding(
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
                    child: Card(
                      elevation: 0.0,
                      surfaceTintColor: Colors.white,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: surface3),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          // width: 200.0,
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  // height: 122.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: surface1,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.black12,
                                    size: 32.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                _productsData![index]["product"]['name'],
                                style: body1.copyWith(
                                    overflow: TextOverflow.ellipsis),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                "RWF ${_productsData![index]["product"]['price'].toStringAsFixed(2)}",
                                style: priceText2,
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "${_productsData![index]['quantity_available'].toString()} in stock",
                                    style: labelText,
                                  ),
                                  const Expanded(child: SizedBox()),
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      side: const BorderSide(color: primary),
                                    ),
                                    onPressed: () async {
                                      await cart.saveData(
                                          data: _productsData![index]);
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      size: 24.0,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
