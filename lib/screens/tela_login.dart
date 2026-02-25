import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/grimorio_widgets.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  void _handleSubmit() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    
    String? error;
    if (_isRegistering) {
      error = await auth.register(_emailController.text, _passwordController.text);
    } else {
      error = await auth.login(_emailController.text, _passwordController.text);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        if (_isRegistering) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Portal criado! Verifique seu email caso necessário.")),
          );
          setState(() => _isRegistering = false);
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GrimorioBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'login_icon',
                  child: Icon(
                    _isRegistering ? Icons.person_add_alt_1 : Icons.shield_moon, 
                    size: 80, 
                    color: const Color(0xFFD4AF37)
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isRegistering ? "NOVO GUARDIÃO" : "GUARDIÃO DO GRIMÓRIO",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(_emailController, "IDENTIDADE (EMAIL)", Icons.person_outline),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, "CHAVE MÍSTICA (SENHA)", Icons.vpn_key_outlined, isPassword: true),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFFD4AF37))
                else
                  BotaoMagico(
                    texto: _isRegistering ? "FORJAR IDENTIDADE" : "RECLAMAR ACESSO",
                    onPressed: _handleSubmit,
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                    _isRegistering ? "JÁ SOU UM GUARDIÃO" : "NÃO TENHO ACESSO (CRIAR CONTA)", 
                    style: const TextStyle(color: Color(0xFFD4AF37))
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("VOLTAR PARA AS SOMBRAS", style: TextStyle(color: Colors.white38)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
