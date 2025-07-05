import 'package:flutter/material.dart';
import '../login/profil.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedItem = 'Dashboard'; // Élément sélectionné par défaut

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBreadcrumbs(),
                        const SizedBox(height: 24.0),

                        const SizedBox(height: 16.0),
                        _buildTicketOverviewCards(),
                        const SizedBox(height: 32.0),
                        Text(
                          'Tickets - Vue d\'ensemble',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        _buildTicketOverviewChart(),
                      ],
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

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Image.asset(
              'assets/images/pictor_logo.jpg',
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'NAVIGATION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          _buildSidebarItem(Icons.dashboard, 'Dashboard'),
          const SizedBox(height: 24.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'SUIVRE TICKTES',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          _buildSidebarItem(Icons.receipt_long, 'Mes Tickets'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title) {
    final bool isSelected = _selectedItem == title;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedItem = title;
          });

          if (title == 'Mes Tickets') {
            Navigator.pushNamed(context, '/mes_tickets');
          } else if (title == 'Dashboard') {
            Navigator.pushNamed(context, '/dashboard');
          }
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile_icon.jpg'),
                radius: 20,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Client',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8.0),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilPage()),
                    );
                  }
                },

                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Mon Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        Text('Home', style: TextStyle(color: Colors.grey[600])),
        Icon(Icons.chevron_right, color: Colors.grey[600]),
        Text('Navigation', style: TextStyle(color: Colors.grey[600])),
        Icon(Icons.chevron_right, color: Colors.grey[600]),
        Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTicketOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 24.0,
      mainAxisSpacing: 24.0,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildTicketCard(Icons.grid_on, 'All Tickets', 2, Colors.blue),
        _buildTicketCard(Icons.hourglass_empty, 'Tickets en cours de traitement', 1, Colors.orange),
        _buildTicketCard(Icons.check_circle_outline, 'Tickets ouverts', 1, Colors.green),
        _buildTicketCard(Icons.cancel_outlined, 'Tickets fermés', 0, Colors.red),
      ],
    );
  }

  Widget _buildTicketCard(IconData icon, String title, int count, Color color) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketOverviewChart() {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 16.0),
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _PieChartPainter([
                    _PieChartSection(0.4, Colors.orange),
                    _PieChartSection(0.3, Colors.green),
                    _PieChartSection(0.2, Colors.blue),
                    _PieChartSection(0.1, Colors.grey),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: [
        _buildLegendItem('Closed Tickets', Colors.blue),
        _buildLegendItem('Open Tickets', Colors.green),
        _buildLegendItem('Pending Tickets', Colors.orange),
        _buildLegendItem('Assigned To Me', Colors.red),
        _buildLegendItem('Not Assigned', Colors.grey),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<_PieChartSection> sections;

  _PieChartPainter(this.sections);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -3.14159 / 2;

    for (var section in sections) {
      final sweepAngle = 2 * 3.14159 * section.percentage;
      final paint = Paint()..color = section.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChartSection {
  final double percentage;
  final Color color;

  _PieChartSection(this.percentage, this.color);
}
