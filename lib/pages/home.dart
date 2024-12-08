import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_service/models/device.dart';
import 'package:sms_service/root_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = Provider.of<RootProvider>(context).devices;
    return Column(
      children: [
        ...devices.map(
          (device) => DeviceTile(device: device),
        ),
      ],
    );
  }
}

class DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DeviceTile({
    super.key,
    required this.device,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          child: Icon(Icons.phone_android),
        ),
        title: Text(device.name),
        subtitle: Text(device.phoneNumber),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${device.smsLimit} SMS'),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
