import 'package:flutter/material.dart';
import '../login/dashboard_screen.dart';
import '../login/mestickets.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController(text: 'client');
  final TextEditingController _emailController = TextEditingController(text: 'syrtnezeddinl097@gmail.com');
  final TextEditingController _firstNameController = TextEditingController(text: 'Client User');
  final TextEditingController _phoneController = TextEditingController(text: '1122334455');

  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
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
              child: _selectedIndex == 0 ? _buildMesInformationsTab() : _buildMotDePasseTab(),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF3366CC),
      title: Text('Mon Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      centerTitle: true,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildDrawerHeader(),
          _buildDrawerItem(icon: Icons.dashboard, title: 'Dashboard', onTap: () => _navigateTo(context, DashboardScreen())),
          Divider(height: 1, thickness: 0.5),
          _buildDrawerSectionTitle('SUIVRE TICKETS'),
          _buildDrawerItem(icon: Icons.receipt, title: 'Mes Tickets', onTap: () => _navigateTo(context, MesTicketsPage())),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 150,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))),
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

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
      child: Text(title, style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
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
          border: Border(bottom: BorderSide(color: _selectedIndex == index ? Colors.white : Colors.transparent, width: 2.0)),
        ),
        child: Text(title,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal)),
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
              SizedBox(height: 15),
              _buildDoubleTextField(
                firstController: _usernameController,
                firstLabel: 'Username*',
                secondController: _emailController,
                secondLabel: 'Email address*',
              ),
              SizedBox(height: 20),
              _buildTextField(_firstNameController, 'Nom Prénom*'),
              SizedBox(height: 30),
              _buildSectionTitle('Contact'),
              SizedBox(height: 15),
              _buildTextField(_phoneController, 'Numéro de Téléphone*', keyboardType: TextInputType.phone),
              SizedBox(height: 40),
              _buildSaveButton('Modifier information'),
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
              SizedBox(height: 20),
              _buildPasswordField('Ancien Mot de Passe*'),
              SizedBox(height: 20),
              _buildPasswordField('Nouveau Mot de Passe*'),
              SizedBox(height: 20),
              _buildPasswordField('Confirmer Mot de Passe*'),
              SizedBox(height: 40),
              _buildSaveButton('Changer Mot de Passe'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]));
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
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF3366CC), width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      ),
      style: TextStyle(color: Colors.blueGrey[800]),
    );
  }

  Widget _buildPasswordField(String label) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blueGrey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF3366CC), width: 2)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        suffixIcon: Icon(Icons.visibility_off, color: Colors.blueGrey.shade400),
      ),
      style: TextStyle(color: Colors.blueGrey[800]),
    );
  }

  Widget _buildSaveButton(String text) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton(
        onPressed: _showSuccessSnackbar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3366CC),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          shadowColor: Colors.blueGrey.withOpacity(0.3),
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(text, key: ValueKey(text), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedIndex == 0 ? 'Informations mises à jour avec succès!' : 'Mot de passe changé avec succès!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
        duration: Duration(seconds: 2),
        elevation: 6,
      ),
    );
  }
}
