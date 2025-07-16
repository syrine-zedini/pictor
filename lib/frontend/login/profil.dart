import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/dashboard_screen.dart';
import '../login/mestickets.dart';
import '../../backendApi/client/api-user.dart';
import '../../backendApi/client/usermodel.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Password change controllers
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userInfo = prefs.getString('userInfo');

      if (token != null && userInfo != null) {
        // Parse user info from stored string
        final userData = Map<String, dynamic>.fromEntries(userInfo
            .replaceAll('{', '')
            .replaceAll('}', '')
            .split(',')
            .map((e) {
          final parts = e.trim().split(':');
          if (parts.length == 2) {
            return MapEntry(parts[0].trim(), parts[1].trim());
          }
          return MapEntry('', '');
        }).where((e) => e.key.isNotEmpty));

        final user = User.fromJson(userData);

        setState(() {
          _currentUser = user;
          _usernameController.text = user.userName;
          _emailController.text = user.email;
          _firstNameController.text = user.nomPrenom;
          _phoneController.text = user.phoneNumber ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No user data found';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    try {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
        _successMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final updatedData = {
          'userId': _currentUser!.userId,
          'nomPrenom': _firstNameController.text,
          'phone': _phoneController.text,
        };

        final updatedUser = await ApiService.updateMyProfile(
            _currentUser!.userId, updatedData, token);

        setState(() {
          _currentUser = updatedUser;
          _successMessage = 'Profile updated successfully!';
          _isSaving = false;
        });

        // Update stored user info
        await prefs.setString('userInfo', updatedUser.toJson().toString());
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: $e';
        _isSaving = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'New passwords do not match';
      });
      return;
    }

    try {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
        _successMessage = null;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        // First check if old password is correct
        final isOldPasswordCorrect = await ApiService.checkPassword({
          'userId': _currentUser!.userId,
          'password': _oldPasswordController.text,
        });

        if (!isOldPasswordCorrect) {
          setState(() {
            _errorMessage = 'Current password is incorrect';
            _isSaving = false;
          });
          return;
        }

        // Update password
        await ApiService.resetPassword({
          'email': _currentUser!.email,
          'code': '123456', // This should be handled properly in a real app
          'newPassword': _newPasswordController.text,
        });

        setState(() {
          _successMessage = 'Password changed successfully!';
          _isSaving = false;
        });

        // Clear password fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to change password: $e';
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildTabSelector(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.vertical,
                            child: child,
                          ),
                        ),
                        child: _selectedIndex == 0
                            ? _buildMesInformationsTab()
                            : _buildMotDePasseTab(),
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
            'Error Loading Profile',
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
            onPressed: _loadUserData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF3366CC),
      title: Text('Mon Profil',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      centerTitle: true,
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(),
          _buildDrawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: () => _navigateTo(context, DashboardScreen())),
          Divider(height: 1, thickness: 0.5),
          _buildDrawerSectionTitle('SUIVRE TICKETS'),
          _buildDrawerItem(
              icon: Icons.receipt,
              title: 'Mes Tickets',
              onTap: () => _navigateTo(context, MesTicketsPage())),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
      child: Center(
        child: Hero(
          tag: 'logo',
          child: Material(
            color: Colors.transparent,
            child: Image.asset('assets/images/pictor_logo.jpg', height: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      hoverColor: Colors.blueGrey.withOpacity(0.1),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title,
          style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut));
          return FadeTransition(opacity: animation.drive(tween), child: child);
        },
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Color(0xFF3366CC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton(0, 'Mes Informations'),
          SizedBox(width: 30),
          _buildTabButton(1, 'Mot de Passe'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.white.withOpacity(0.2),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: _selectedIndex == index
                      ? Colors.white
                      : Colors.transparent,
                  width: 2.0)),
        ),
        child: Text(title,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: _selectedIndex == index
                    ? FontWeight.bold
                    : FontWeight.normal)),
      ),
    );
  }

  Widget _buildMesInformationsTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informations utilisateur'),
              if (_errorMessage != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 15),
              _buildDoubleTextField(
                firstController: _usernameController,
                firstLabel: 'Username*',
                secondController: _emailController,
                secondLabel: 'Email address*',
              ),
              const SizedBox(height: 20),
              _buildTextField(_firstNameController, 'Nom Prénom*'),
              const SizedBox(height: 30),
              _buildSectionTitle('Contact'),
              const SizedBox(height: 15),
              _buildTextField(_phoneController, 'Numéro de Téléphone*',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 40),
              _buildSaveButton('Modifier information', _updateProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotDePasseTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Changer votre mot de passe'),
              if (_errorMessage != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildPasswordField(
                  'Ancien Mot de Passe*', _oldPasswordController),
              const SizedBox(height: 20),
              _buildPasswordField(
                  'Nouveau Mot de Passe*', _newPasswordController),
              const SizedBox(height: 20),
              _buildPasswordField(
                  'Confirmer Mot de Passe*', _confirmPasswordController),
              const SizedBox(height: 40),
              _buildSaveButton('Changer Mot de Passe', _changePassword),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800]));
  }

  Widget _buildDoubleTextField({
    required TextEditingController firstController,
    required String firstLabel,
    required TextEditingController secondController,
    required String secondLabel,
  }) {
    return Row(
      children: [
        Expanded(child: _buildTextField(firstController, firstLabel)),
        SizedBox(width: 20),
        Expanded(child: _buildTextField(secondController, secondLabel)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF3366CC), width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      ),
      style: TextStyle(color: Colors.blueGrey[800]),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueGrey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF3366CC), width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        suffixIcon: Icon(Icons.visibility_off, color: Colors.blueGrey.shade400),
      ),
      style: TextStyle(color: Colors.blueGrey[800]),
    );
  }

  Widget _buildSaveButton(String text, VoidCallback? onPressed) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: _isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3366CC),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          shadowColor: Colors.blueGrey.withOpacity(0.3),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Text(text,
                    key: ValueKey(text),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
      ),
    );
  }
}
