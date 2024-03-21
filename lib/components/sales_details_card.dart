import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shinda_app/components/custom_card.dart';
import 'package:shinda_app/constants/text_syles.dart';
import 'package:shinda_app/utilities/models/sales_model.dart';

class SalesDetailsCard extends StatelessWidget {
  const SalesDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final salesDetails = SalesDetails();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemBuilder: (context, index) => CustomCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            salesDetails.salesData[index].icon,
            const SizedBox(height: 16.0),
            Text(
              salesDetails.salesData[index].value,
              style: GoogleFonts.eczar(
                textStyle: const TextStyle(fontSize: 24.0),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4.0),
            Text(
              salesDetails.salesData[index].title,
              style: const TextStyle(color: neutral4),
            ),
          ],
        ),
      ),
      itemCount: salesDetails.salesData.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
    );
  }
}
