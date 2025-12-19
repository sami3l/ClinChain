import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'grossiste');
  final _passwordController = TextEditingController(text: 'password');
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 50,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'ClinChain',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gestion des lots de médicaments',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),

                // Login Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connexion',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Username field
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Nom d\'utilisateur',
                              hintText: 'Entrez votre identifiant',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Nom d\'utilisateur requis'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              hintText: 'Entrez votre mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(auth),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Mot de passe requis'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          // Error message
                          if (auth.error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.errorRed.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppTheme.errorRed, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auth.error!,
                                      style: const TextStyle(
                                        color: AppTheme.errorRed,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Login button
                          ElevatedButton(
                            onPressed:
                                _submitting ? null : () => _handleLogin(auth),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // Mock users info
                          // Container(
                          //   padding: const EdgeInsets.all(12),
                          //   decoration: BoxDecoration(
                          //     color: AppTheme.primaryBlue.withOpacity(0.05),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Row(
                          //         children: [
                          //           Icon(Icons.info_outline,
                          //               size: 16,
                          //               color: AppTheme.primaryBlue
                          //                   .withOpacity(0.7)),
                          //           const SizedBox(width: 6),
                          //           Text(
                          //             'Mode de démonstration',
                          //             style: TextStyle(
                          //               fontSize: 12,
                          //               fontWeight: FontWeight.w600,
                          //               color: AppTheme.primaryBlue
                          //                   .withOpacity(0.7),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //       const SizedBox(height: 8),
                          //       _buildUserChip('grossiste', 'Grossiste'),
                          //       _buildUserChip('hopitale', 'Hôpital'),
                          //       _buildUserChip('pharmacien', 'Pharmacien'),
                          //       _buildUserChip('infirmier', 'Infirmier'),
                          //       const SizedBox(height: 8),
                          //       Text(
                          //         'Mot de passe: password',
                          //         style: TextStyle(
                          //           fontSize: 11,
                          //           color: AppTheme.textSecondary,
                          //           fontStyle: FontStyle.italic,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserChip(String username, String role) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _usernameController.text = username;
          });
        },
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$username ($role)',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider auth) async {
    if (!_form.currentState!.validate()) return;

    setState(() => _submitting = true);

    final ok = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    }
  }
}
