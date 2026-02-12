import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _hidePass = true;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: aquí luego conectas tu AuthBloc / API
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Login OK (pendiente API)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _HeaderLogoBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 210), // espacio del header

                      Card(
                        elevation: 10,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Accede para registrar evaluaciones de control de calidad.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _usuarioCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Usuario',
                                    hintText: 'Ej: jlopez',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Ingrese su usuario'
                                      : null,
                                ),
                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _hidePass,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _hidePass = !_hidePass,
                                      ),
                                      icon: Icon(
                                        _hidePass
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Ingrese su contraseña'
                                      : null,
                                  onFieldSubmitted: (_) => _submit(),
                                ),

                                const SizedBox(height: 16),

                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1B5E20),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Ingresar'),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'AGQ • Evaluar. Medir. Mejorar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderLogoBackground extends StatelessWidget {
  const _HeaderLogoBackground();

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 300;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo degradado verde
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B3D2E),
                  Color(0xFF1B5E20),
                  Color(0xFF43A047),
                ],
              ),
            ),
          ),

          // Logo como fondo (translúcido)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Curva blanca inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
