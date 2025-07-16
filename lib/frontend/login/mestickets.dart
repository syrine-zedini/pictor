import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/dashboard_screen.dart';
import '../../backendApi/client/api-ticket.dart';
import '../../backendApi/client/ticketmodel.dart';

class MesTicketsPage extends StatefulWidget {
  const MesTicketsPage({Key? key}) : super(key: key);

  @override
  State<MesTicketsPage> createState() => _MesTicketsPageState();
}

class _MesTicketsPageState extends State<MesTicketsPage> {
  int _rowsPerPage = 5;
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        // Load tickets from API
        final tickets =
            await Apiservice.listTicketsByUser(_currentUserId ?? '', token);
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No authentication token found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tickets: $e';
      });
    }
  }

  Future<void> _createNewTicket() async {
    // Show dialog to create new ticket
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CreateTicketDialog(),
    );

    if (result != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null) {
          final command = CreateTicketCommand(
            sujet: result['subject']!,
            description: result['description']!,
            priority: result['priority']!,
            demandeurId: _currentUserId ?? '',
          );

          await Apiservice.createTicket(command, token);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket created successfully!')),
          );

          // Reload tickets
          _loadTickets();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create ticket: $e')),
        );
      }
    }
  }

  Future<void> _viewTicketDetails(Ticket ticket) async {
    // Show ticket details dialog
    showDialog(
      context: context,
      builder: (context) => _TicketDetailsDialog(ticket: ticket),
    );
  }

  Future<void> _closeTicket(Ticket ticket) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        await Apiservice.closeTicket(
            ticket.ticketId, _currentUserId ?? '', token);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket closed successfully!')),
        );

        // Reload tickets
        _loadTickets();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to close ticket: $e')),
      );
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'inprogress':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? _buildErrorWidget()
                          : _buildTicketTable(),
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

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Tickets',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTickets,
            child: const Text('Retry'),
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
              Navigator.pushNamed(
                  context, '/dashboard'); // Navigate to Dashboard page
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
        _buildActionButton(Icons.refresh, Colors.blue, 'Refresh', _loadTickets),
        const SizedBox(width: 10),
        _buildActionButton(
            Icons.add, Colors.green, 'Create Ticket', _createNewTicket),
        const SizedBox(width: 10),
        _buildActionButton(Icons.visibility, Colors.orange, 'View Details', () {
          if (_tickets.isNotEmpty) {
            _viewTicketDetails(_tickets.first);
          }
        }),
        const SizedBox(width: 10),
        _buildActionButton(Icons.close, Colors.red, 'Close Ticket', () {
          if (_tickets.isNotEmpty) {
            _closeTicket(_tickets.first);
          }
        }),
        const SizedBox(width: 10),
        _buildActionButton(Icons.edit, Colors.purple, 'Edit', () {
          // TODO: Implement edit functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit functionality coming soon!')),
          );
        }),
        const SizedBox(width: 10),
        _buildActionButton(Icons.rocket_launch, Colors.teal, 'Export', () {
          // TODO: Implement export functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export functionality coming soon!')),
          );
        }),
        const SizedBox(width: 10),
        _buildActionButton(Icons.folder, Colors.indigo, 'Archive', () {
          // TODO: Implement archive functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archive functionality coming soon!')),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color),
        ),
      ),
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
                label: Text('Num Ticket',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Sujet',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Priority',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Statut',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Client User',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text(''), // For the eye icon
              ),
            ],
            rows: _tickets.map((ticket) {
              return DataRow(
                cells: [
                  DataCell(Checkbox(value: false, onChanged: (bool? value) {})),
                  DataCell(Text(ticket.ticketId)),
                  DataCell(Text(ticket.sujet)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _getPriorityColor(ticket.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticket.priority,
                        style: TextStyle(
                            color: _getPriorityColor(ticket.priority),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(ticket.statut).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticket.statut,
                        style: TextStyle(
                            color: _getStatusColor(ticket.statut),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataCell(Text(ticket.demandeurId)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye_outlined,
                          color: Colors.blue),
                      onPressed: () {
                        _viewTicketDetails(ticket);
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _CreateTicketDialog() {
    final _formKey = GlobalKey<FormState>();
    final _subjectController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priorityController = TextEditingController();

    return AlertDialog(
      title: const Text('Create New Ticket'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Subject cannot be empty';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description cannot be empty';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priorityController,
              decoration: const InputDecoration(
                  labelText: 'Priority (e.g., Critical, High, Normal, Low)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Priority cannot be empty';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'subject': _subjectController.text,
                'description': _descriptionController.text,
                'priority': _priorityController.text,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _TicketDetailsDialog({required Ticket ticket}) {
    return AlertDialog(
      title: Text('Ticket Details: ${ticket.ticketId}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject: ${ticket.sujet}'),
            const SizedBox(height: 8),
            Text('Description: ${ticket.description}'),
            const SizedBox(height: 8),
            Text('Priority: ${ticket.priority}'),
            const SizedBox(height: 8),
            Text('Status: ${ticket.statut}'),
            const SizedBox(height: 8),
            Text('Created By: ${ticket.demandeurId}'),
            const SizedBox(height: 8),
            Text('Created At: ${ticket.dateCreation}'),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (ticket.statut.toLowerCase() == 'open')
          ElevatedButton(
            onPressed: () => _closeTicket(ticket),
            child: const Text('Close Ticket'),
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
