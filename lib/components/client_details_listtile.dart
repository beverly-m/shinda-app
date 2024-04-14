import 'package:flutter/material.dart';
import 'package:shinda_app/components/buttons.dart' show OutlinedAppButton;
import 'package:shinda_app/constants/text_syles.dart' show surface1;

class ClientDetailsListTile extends StatelessWidget {
  const ClientDetailsListTile({
    super.key,
    required this.clientName,
    required this.phoneNumber,
    this.address,
    required this.onPressed,
  });
  final String clientName;
  final String phoneNumber;
  final String? address;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      leading: Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: surface1,
        ),
        child: const Icon(
          Icons.person_outline,
          color: Colors.black12,
          size: 24.0,
        ),
      ),
      title: Text(clientName),
      subtitle: Text.rich(
        TextSpan(
          text: phoneNumber,
          children: [
            address != null ? TextSpan(text: ' | $address') : const TextSpan()
          ],
        ),
      ),
      trailing: OutlinedAppButton(
        onPressed: onPressed,
        labelText: "Mark As Paid",
      ),
    );
  }
}
