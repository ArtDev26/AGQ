import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/config/api_config.dart';

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

  // ✅ Recordar usuario + contraseña
  bool _rememberCreds = false;

  // SharedPreferences keys
  static const _kRememberCreds = 'remember_creds';
  static const _kRememberedUsername = 'remembered_username';

  // Secure storage keys
  static const _kRememberedPassword = 'remembered_password';
  static const _secure = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // ✅ Carga Base URL guardada (persistente)
    ApiConfig.load();
    _loadRememberedCreds();
  }

  Future<void> _loadRememberedCreds() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRememberCreds) ?? false;
    final username = prefs.getString(_kRememberedUsername) ?? '';

    String password = '';
    if (remember) {
      password = (await _secure.read(key: _kRememberedPassword)) ?? '';
    }

    if (!mounted) return;

    setState(() => _rememberCreds = remember);

    if (remember) {
      if (username.isNotEmpty) _usuarioCtrl.text = username;
      if (password.isNotEmpty) _passCtrl.text = password;
    }
  }

  Future<void> _persistRememberedCredsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberCreds, _rememberCreds);

    if (_rememberCreds) {
      await prefs.setString(_kRememberedUsername, _usuarioCtrl.text.trim());
      await _secure.write(key: _kRememberedPassword, value: _passCtrl.text);
    } else {
      await prefs.remove(_kRememberedUsername);
      await _secure.delete(key: _kRememberedPassword);
    }
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        username: _usuarioCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      ),
    );
  }

  void _openApiDialog(BuildContext context) {
    final ctrl = TextEditingController(text: ApiConfig.currentBaseUrl);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Configuración'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Base URL:'),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Actual: ${ApiConfig.currentBaseUrl}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // (Opcional) reset default
                await ApiConfig.resetToDefault();
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'API restaurada: ${ApiConfig.currentBaseUrl}',
                    ),
                  ),
                );

                Navigator.of(ctx).pop();
              },
              child: const Text('Restaurar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final v = ctrl.text.trim();

                if (v.isEmpty || !v.startsWith('http')) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('URL inválida')));
                  return;
                }

                // ✅ GUARDA PERSISTENTE + ACTUALIZA MEMORIA
                await ApiConfig.save(v);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('API guardada: ${ApiConfig.currentBaseUrl}'),
                  ),
                );

                Navigator.of(ctx).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          // Guarda usuario + contraseña si está activado el check
          await _persistRememberedCredsIfNeeded();
          if (!context.mounted) return;
          context.go('/home');
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Stack(
                children: [
                  _HeaderAGQ(onSettings: () => _openApiDialog(context)),
                  Positioned.fill(
                    top: 220,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: _LoginCard(
                            formKey: _formKey,
                            usuarioCtrl: _usuarioCtrl,
                            passCtrl: _passCtrl,
                            hidePass: _hidePass,
                            onTogglePass: () =>
                                setState(() => _hidePass = !_hidePass),
                            onSubmit: _submit,
                            rememberCreds: _rememberCreds,
                            onRememberChanged: (v) =>
                                setState(() => _rememberCreds = v ?? false),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.usuarioCtrl,
    required this.passCtrl,
    required this.hidePass,
    required this.onTogglePass,
    required this.onSubmit,
    required this.rememberCreds,
    required this.onRememberChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usuarioCtrl;
  final TextEditingController passCtrl;
  final bool hidePass;
  final VoidCallback onTogglePass;
  final VoidCallback onSubmit;

  final bool rememberCreds;
  final ValueChanged<bool?> onRememberChanged;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthBloc>().state is AuthLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Colors.black26,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Accede para registrar evaluaciones de control de calidad.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: usuarioCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese usuario' : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: passCtrl,
              obscureText: hidePass,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: onTogglePass,
                  icon: Icon(
                    hidePass ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingrese contraseña' : null,
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: rememberCreds,
                      onChanged: onRememberChanged,
                      visualDensity: VisualDensity.compact,
                    ),
                    const Text('Recordar contraseña'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'INGRESAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'AGG • Evaluar. Medir. Mejorar.',
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAGQ extends StatelessWidget {
  const _HeaderAGQ({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.20),
                      ),
                    ),
                    Container(
                      width: 135,
                      height: 135,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/agrokasa_logo_blanco.png",
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "AGROGEST",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 18, right: 14),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onSettings,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 90,
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
