import '../../../domain/entity/seo/seo_check_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnPageSeoCheckerWidget extends StatelessWidget {
  final List<SeoCheckItem> items;
  final bool isLoading;

  const OnPageSeoCheckerWidget({
    Key? key,
    required this.items,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final passCount = items.where((i) => i.status == SeoStatus.pass).length;
    final warnCount = items.where((i) => i.status == SeoStatus.warn).length;
    final failCount = items.where((i) => i.status == SeoStatus.fail).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          _buildSummaryRow(passCount, warnCount, failCount),
          const SizedBox(height: 16.0),

          // Checklist
          _buildSectionHeader('SEO Checklist'),
          const SizedBox(height: 12.0),
          ...items.map((item) => _buildCheckItem(item)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(int pass, int warn, int fail) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryBadge(pass, 'Passed', const Color(0xFF22C55E)),
          _buildDivider(),
          _buildSummaryBadge(warn, 'Warnings', const Color(0xFFF59E0B)),
          _buildDivider(),
          _buildSummaryBadge(fail, 'Failed', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFE8E8E8),
    );
  }

  Widget _buildSummaryBadge(int count, String label, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.oswald(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12.0,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 14.0,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCheckItem(SeoCheckItem item) {
    final config = _statusConfig(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: config.borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2.0),
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: config.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, size: 14.0, color: config.iconColor),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.detail,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.0,
                    color: const Color(0xFF666666),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: config.bgColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              config.label,
              style: GoogleFonts.montserrat(
                fontSize: 10.0,
                fontWeight: FontWeight.w700,
                color: config.iconColor,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _statusConfig(SeoStatus status) {
    switch (status) {
      case SeoStatus.pass:
        return _StatusConfig(
          icon: Icons.check,
          iconColor: const Color(0xFF22C55E),
          bgColor: const Color(0xFFDCFCE7),
          borderColor: const Color(0xFFBBF7D0),
          label: 'Pass',
        );
      case SeoStatus.warn:
        return _StatusConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFFDE68A),
          label: 'Warn',
        );
      case SeoStatus.fail:
        return _StatusConfig(
          icon: Icons.close,
          iconColor: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEE2E2),
          borderColor: const Color(0xFFFCA5A5),
          label: 'Fail',
        );
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String label;
  _StatusConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.label,
  });
}
