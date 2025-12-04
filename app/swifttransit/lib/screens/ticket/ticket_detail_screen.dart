import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../core/constants.dart';
import '../../core/colors.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({
    Key? key,
    required this.tickets,
    this.initialIndex = 0,
  }) : super(key: key);

  final List<Map<String, dynamic>> tickets;
  final int initialIndex;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentTicket => widget.tickets[_currentIndex];

  bool _canCancel(Map<String, dynamic> ticket) {
    return ticket['paid_status'] == true &&
        ticket['checked'] != true &&
        ticket['cancelled_at'] == null;
  }

  Future<void> _handleCancel(BuildContext context) async {
    if (!_canCancel(_currentTicket) || _isCancelling) return;
    setState(() => _isCancelling = true);
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final success = await provider.cancelTicket(_currentTicket['id'] as int);
    setState(() => _isCancelling = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket cancelled. Refund initiated.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to cancel ticket.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticket Details (${_currentIndex + 1}/${widget.tickets.length})',
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: widget.tickets.length,
              itemBuilder: (context, index) {
                final ticket = widget.tickets[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _TicketCard(ticket: ticket),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final ticketId = _currentTicket['id'];
                      final downloadUrl =
                          '${AppConstants.baseUrl}/ticket/download?id=$ticketId';
                      final success = await Provider.of<DashboardProvider>(
                        context,
                        listen: false,
                      ).downloadTicket(downloadUrl);

                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open download link.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download_rounded),
                    label: Text(
                      'Download PDF',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _canCancel(_currentTicket) ? () => _handleCancel(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Cancel & Refund',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final Map<String, dynamic> ticket;

  @override
  Widget build(BuildContext context) {
    final ticketId = ticket['id'];
    final busName = ticket['bus_name'] ?? 'Swift Bus';
    final route = '${ticket['start_destination']} → ${ticket['end_destination']}';
    final fare = ticket['fare'];
    final date = ticket['created_at'];
    final qrData = ticket['qr_code'] ?? 'TICKET-$ticketId';
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$qrData';
    final status = ticket['cancelled_at'] != null
        ? 'Cancelled'
        : ticket['paid_status'] == true
            ? (ticket['checked'] == true ? 'Completed' : 'Upcoming')
            : 'Unpaid';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        busName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ticket #$ticketId • $status',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _infoRow('Route', route),
                const Divider(height: 30),
                _infoRow('Date', date ?? 'N/A'),
                const Divider(height: 30),
                _infoRow('Fare', '৳$fare'),
                const Divider(height: 30),
                _infoRow('Payment', ticket['payment_method'] ?? 'gateway'),
                const Divider(height: 30),
                const SizedBox(height: 10),
                Text(
                  'Scan to Verify',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Image.network(
                  qrUrl,
                  width: 150,
                  height: 150,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
