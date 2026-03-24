import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/widgets/rounded_button_widget.dart';
import '../store/integrations_store.dart';

class ConnectionCard extends StatelessWidget {
  final IntegrationsStore store;

  const ConnectionCard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Google Connection',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (!store.isConnected) ...[
                  if (store.isConnecting)
                    const Center(child: CircularProgressIndicator())
                  else
                    RoundedButtonWidget(
                      buttonText: 'Connect Google',
                      buttonColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: () => store.connectGoogle(),
                    ),
                  const SizedBox(height: 8),
                  RoundedButtonWidget(
                    buttonText: 'Simulate Error',
                    buttonColor: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => store.simulateError(),
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Connected to Google',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => store.disconnect(),
                        child: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Website Property',
                      border: OutlineInputBorder(),
                    ),
                    value: store.selectedGscProperty,
                    items: store.gscProperties
                        .map((prop) => DropdownMenuItem(value: prop, child: Text(prop)))
                        .toList(),
                    onChanged: (val) => store.selectedGscProperty = val,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Data Stream',
                      border: OutlineInputBorder(),
                    ),
                    value: store.selectedGa4Stream,
                    items: store.ga4Streams
                        .map((stream) => DropdownMenuItem(value: stream, child: Text(stream)))
                        .toList(),
                    onChanged: (val) => store.selectedGa4Stream = val,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
