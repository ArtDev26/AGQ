import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MedicionBrixPreCosechaPage extends StatefulWidget {
  const MedicionBrixPreCosechaPage({super.key});

  @override
  State<MedicionBrixPreCosechaPage> createState() =>
      _MedicionBrixPreCosechaPageState();
}

class _MedicionBrixPreCosechaPageState
    extends State<MedicionBrixPreCosechaPage> {
  final _formKey = GlobalKey<FormState>();

  // Dropdowns (por ahora “mock”; luego lo conectas a tu API)
  final List<String> _variedades = const [
    'ALLISON',
    'RED GLOBE',
    'SWEET GLOBE',
  ];
  final List<String> _lotes = const ['G-6(1,2)', 'A-7(1)', 'B-2(3)'];

  String? _variedad;
  String? _lote;

  // Contadores
  int _plantas = 0;
  int _racimos = 0;

  // Selecciones
  final List<String> _tamanios = const ['Pequeño', 'Mediano', 'Grande'];
  final List<String> _colores = const [
    'Verde',
    'Amarillo',
    'Ámbar',
    'Rojo',
    'Rosado',
    'Pinta',
  ];
  String? _tamanoSel;
  String? _colorSel;

  // Brix
  final TextEditingController _brixCtrl = TextEditingController();

  @override
  void dispose() {
    _brixCtrl.dispose();
    super.dispose();
  }

  void _incPlantas() => setState(() => _plantas++);
  void _decPlantas() =>
      setState(() => _plantas = _plantas > 0 ? _plantas - 1 : 0);

  void _incRacimos() => setState(() => _racimos++);
  void _decRacimos() =>
      setState(() => _racimos = _racimos > 0 ? _racimos - 1 : 0);

  void _guardar() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_tamanoSel == null || _colorSel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione Tamaño y Color.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guardado (demo).')));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEDICIÓN BRIX PRE - COSECHA'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F3FA), Color(0xFFEEF6F0)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: _leftPanel()),
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: _rightPanel()),
                          ],
                        )
                      : ListView(
                          children: [
                            _leftPanel(),
                            const SizedBox(height: 16),
                            _rightPanel(),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftPanel() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.location_on_outlined,
            title: 'Ubicación del Lote',
          ),
          const SizedBox(height: 10),

          // Variedad
          _FieldLabel(text: 'Variedad del Cultivo', required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _variedad,
            items: _variedades
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _variedad = v),
            decoration: _inputDecoration(prefix: Icons.local_florist_outlined),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Seleccione variedad' : null,
          ),

          const SizedBox(height: 14),

          // Lote/Sublote
          _FieldLabel(text: 'Lote / SubLote', required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _lote,
            items: _lotes
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _lote = v),
            decoration: _inputDecoration(prefix: Icons.map_outlined),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Seleccione lote/sub-lote' : null,
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),

          // Contadores Plantas / Racimos (como en tu imagen)
          Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              _CounterRow(
                label: 'Plantas',
                value: _plantas,
                onMinus: _decPlantas,
                onPlus: _incPlantas,
              ),
              _CounterRow(
                label: 'Racimos',
                value: _racimos,
                onMinus: _decRacimos,
                onPlus: _incRacimos,
              ),
            ],
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _rightPanel() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.fact_check_outlined, title: 'Registro'),
          const SizedBox(height: 12),

          // Tamaño (lista)
          const _FieldLabel(text: 'Tamaño', required: true),
          const SizedBox(height: 8),
          _ChoiceList(
            options: _tamanios,
            value: _tamanoSel,
            onChanged: (v) => setState(() => _tamanoSel = v),
          ),

          const SizedBox(height: 16),

          // Color (lista)
          const _FieldLabel(text: 'Color', required: true),
          const SizedBox(height: 8),
          _ChoiceList(
            options: _colores,
            value: _colorSel,
            onChanged: (v) => setState(() => _colorSel = v),
          ),

          const SizedBox(height: 16),

          // Brix (numérico 2 decimales)
          const _FieldLabel(text: 'Grado Brix', required: true),
          const SizedBox(height: 8),
          TextFormField(
            controller: _brixCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d{0,3}([.,]\d{0,2})?$'),
              ),
              _CommaToDotFormatter(),
            ],
            decoration: _inputDecoration(
              prefix: Icons.science_outlined,
              hint: 'Ej: 18.25',
              helper: 'Numérico (decimal con 2 dígitos)',
            ),
            validator: (v) {
              final txt = (v ?? '').trim();
              if (txt.isEmpty) return 'Ingrese grado Brix';
              final n = double.tryParse(txt);
              if (n == null) return 'Formato inválido';
              if (n < 0 || n > 60) return 'Rango inválido';
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData prefix,
    String? hint,
    String? helper,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefix),
      hintText: hint,
      helperText: helper,
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: const Color(0xFF1B5E20).withOpacity(0.55),
          width: 1.4,
        ),
      ),
    );
  }
}

/* =========================
   Widgets pequeños (UI)
========================= */

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Colors.black12,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1B5E20)),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900),
          ),
        ],
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Colors.white.withOpacity(0.85),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 12),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle, color: Color(0xFF1B5E20)),
          ),
        ],
      ),
    );
  }
}

class _ChoiceList extends StatelessWidget {
  const _ChoiceList({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final selected = opt == value;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(opt),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF1B5E20) : Colors.black12,
              ),
              color: selected
                  ? const Color(0xFF1B5E20).withOpacity(0.10)
                  : Colors.white.withOpacity(0.85),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? const Color(0xFF1B5E20) : Colors.black38,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    opt,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/* =========================
   Input formatter: coma -> punto
========================= */
class _CommaToDotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
