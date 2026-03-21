import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/overview/store/overview_store.dart';

class TopReferencedDomainsWidget extends StatelessWidget {
  final List<ReferencedDomain> domains;
  final bool isLoading;

  const TopReferencedDomainsWidget({
    Key? key,
    required this.domains,
    this.isLoading = false,
  }) : super(key: key);

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ChatGPT':
        return Color(0xFF10A37F);
      case 'Gemini':
        return Color(0xFF4285F4);
      case 'AI Overview':
        return Color(0xFFEA4335);
      default:
        return Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Referenced Domains',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline,
                    size: 18.0, color: Color(0xFF999999)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Top 30 most cited domains across all AI platforms in the last 30 days'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 12.0),
          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (domains.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No domain reference data available',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: domains.length,
              separatorBuilder: (context, index) => Divider(
                height: 1.0,
                color: Color(0xFFE8E8E8),
              ),
              itemBuilder: (context, index) {
                final domain = domains[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              domain.domain,
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(domain.category)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                domain.category,
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w500,
                                  color: _getCategoryColor(domain.category),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${domain.mentions} mentions',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
