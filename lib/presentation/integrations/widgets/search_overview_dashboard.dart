import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../store/integrations_store.dart';

class SearchOverviewDashboard extends StatelessWidget {
  final IntegrationsStore store;

  const SearchOverviewDashboard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (!store.isConnected) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text('Google Search Console Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
                children: [
                  _MetricCard(
                    title: 'Impressions',
                    value: store.gscImpressions.toString(),
                    icon: Icons.visibility,
                    color: Colors.blue,
                  ),
                  _MetricCard(
                    title: 'Clicks',
                    value: store.gscClicks.toString(),
                    icon: Icons.ads_click,
                    color: Colors.green,
                  ),
                  _MetricCard(
                    title: 'Avg Position',
                    value: store.gscAveragePosition.toString(),
                    icon: Icons.bar_chart,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Google Analytics 4 Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
                children: [
                  _MetricCard(
                    title: 'Sessions',
                    value: store.ga4Sessions.toString(),
                    icon: Icons.people,
                    color: Colors.purple,
                  ),
                  _MetricCard(
                    title: 'Bounce Rate',
                    value: store.ga4BounceRate,
                    icon: Icons.call_missed_outgoing,
                    color: Colors.red,
                  ),
                  _MetricCard(
                    title: 'Key Conversions',
                    value: store.ga4KeyConversions.toString(),
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
