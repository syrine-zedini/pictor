import 'package:flutter/material.dart';
import '../login/dashboard_screen.dart';

class MesTicketsPage extends StatefulWidget {
  const MesTicketsPage({Key? key}) : super(key: key);

  @override
  State<MesTicketsPage> createState() => _MesTicketsPageState();
}

class _MesTicketsPageState extends State<MesTicketsPage> {
  int _rowsPerPage = 5; // For the "Items per page" dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // You might want to hide the default app bar title or use a custom one
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // For icons and text
        elevation: 0, // No shadow
      ),
      drawer: _buildDrawer(context), // The left-hand navigation drawer
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This column is typically within the Scaffold body for the main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumbs(),
                  const SizedBox(height: 20),
                  const Text(
                    'Mes Tickets',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildTicketTable(),
                  const SizedBox(height: 20),
                  _buildPaginationControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Image.asset(
              'assets/images/pictor_logo.jpg', // Replace with your logo path
              height: 80,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NAVIGATION',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/dashboard'); // Navigate to Dashboard page
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SUIVRE TICKETS',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Mes Tickets'),
            selected: true, // This page is currently selected
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () {
              // Already on Mes Tickets page, just close drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to Home
          },
          child: const Text(
            'Home',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        GestureDetector(
          onTap: () {
            // Navigate to Suivre Tickets
          },
          child: const Text(
            'Suivre Tickets',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        const Text(
          'Mes Tickets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(Icons.refresh, Colors.blue),
        const SizedBox(width: 10),
        _buildActionButton(Icons.add, Colors.green),
        const SizedBox(width: 10),
        _buildActionButton(Icons.visibility, Colors.orange),
        const SizedBox(width: 10),
        _buildActionButton(Icons.delete, Colors.red),
        const SizedBox(width: 10),
        _buildActionButton(Icons.edit, Colors.purple),
        const SizedBox(width: 10),
        _buildActionButton(Icons.rocket_launch, Colors.teal),
        const SizedBox(width: 10),
        _buildActionButton(Icons.folder, Colors.indigo),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildTicketTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          DataTable(
            columnSpacing: 30, // Adjust as needed
            horizontalMargin: 20, // Adjust as needed
            columns: const [
              DataColumn(
                label: Text(''), // For the checkbox
              ),
              DataColumn(
                label: Text('Num Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Sujet', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Client User', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text(''), // For the eye icon
              ),
            ],
            rows: [
              _buildTicketRow(
                context: context,
                numTicket: '#Ticket-1',
                sujet: 'IT support',
                priority: 'Critical',
                priorityColor: Colors.red,
                statut: 'Open',
                clientUser: 'Client User',
              ),
              _buildTicketRow(
                context: context,
                numTicket: '#Ticket-9',
                sujet: 'LAN Switch Port Malfunctioning',
                priority: 'Low',
                priorityColor: Colors.blue,
                statut: 'InProgress',
                clientUser: 'Client User',
              ),
              // Add more rows as needed
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildTicketRow({
    required BuildContext context,
    required String numTicket,
    required String sujet,
    required String priority,
    required Color priorityColor,
    required String statut,
    required String clientUser,
  }) {
    return DataRow(
      cells: [
        DataCell(Checkbox(value: false, onChanged: (bool? value) {})),
        DataCell(Text(numTicket)),
        DataCell(Text(sujet)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              priority,
              style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(Text(statut)),
        DataCell(Text(clientUser)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue),
            onPressed: () {
              // Handle view ticket action
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Items per page:'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: _rowsPerPage,
          items: const <int>[5, 10, 20].map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _rowsPerPage = newValue!;
            });
          },
        ),
        const SizedBox(width: 20),
        const Text('1-2 of 2'),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            // Handle previous page
          },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Handle next page
          },
        ),
      ],
    );
  }
}