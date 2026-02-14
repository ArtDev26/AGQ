import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MedicionBrixPreCosechaPage extends StatefulWidget {
  const MedicionBrixPreCosechaPage({super.key});

  @override
  State<MedicionBrixPreCosechaPage> createState() =>
      _MedicionBrixPreCosechaPageState();
}

/* =========================
   Modelo: 1 registro por racimo
========================= */
class RacimoRegistro {
  final int planta; // 1..N
  final int nroRacimo; // correlativo dentro de la planta
  final String variedad;
  final String lote;
  final String tamano;
  final String color;
  final double brix;
  final DateTime fecha;

  RacimoRegistro({
    required this.planta,
    required this.nroRacimo,
    required this.variedad,
    required this.lote,
    required this.tamano,
    required this.color,
    required this.brix,
    required this.fecha,
  });

  RacimoRegistro copyWith({
    int? planta,
    int? nroRacimo,
    String? variedad,
    String? lote,
    String? tamano,
    String? color,
    double? brix,
    DateTime? fecha,
  }) {
    return RacimoRegistro(
      planta: planta ?? this.planta,
      nroRacimo: nroRacimo ?? this.nroRacimo,
      variedad: variedad ?? this.variedad,
      lote: lote ?? this.lote,
      tamano: tamano ?? this.tamano,
      color: color ?? this.color,
      brix: brix ?? this.brix,
      fecha: fecha ?? this.fecha,
    );
  }
}

class _MedicionBrixPreCosechaPageState
    extends State<MedicionBrixPreCosechaPage> {
  final _formKey = GlobalKey<FormState>();

  // Dropdowns (mock; luego conectas API)
  final List<String> _variedades = const [
    'ALLISON',
    'RED GLOBE',
    'SWEET GLOBE',
  ];
  final List<String> _lotes = const ['G-6(1,2)', 'A-7(1)', 'B-2(3)'];

  String? _variedad;
  String? _lote;

  // Plantas
  int _plantas = 1;
  int _plantaSel = 1;

  // Racimos por planta
  final Map<int, int> _racimosPorPlanta = {1: 0};

  // Registro por racimo (key = "planta-racimo")
  final Map<String, RacimoRegistro> _registroPorRacimo = {};

  // Racimo seleccionado
  int? _racimoSel;

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

  // =========================
  // Helpers
  // =========================
  String _key(int planta, int racimo) => '$planta-$racimo';

  int get _racimosDePlantaSel => _racimosPorPlanta[_plantaSel] ?? 0;

  // =========================
  // Auto-guardado
  // =========================
  void _autoGuardarSiCompleto() {
    if (_racimoSel == null) return;
    if ((_variedad ?? '').isEmpty || (_lote ?? '').isEmpty) return;
    if (_tamanoSel == null || _colorSel == null) return;

    final brix = double.tryParse(_brixCtrl.text.trim());
    if (brix == null) return;

    final k = _key(_plantaSel, _racimoSel!);

    setState(() {
      _registroPorRacimo[k] = RacimoRegistro(
        planta: _plantaSel,
        nroRacimo: _racimoSel!,
        variedad: _variedad!,
        lote: _lote!,
        tamano: _tamanoSel!,
        color: _colorSel!,
        brix: brix,
        fecha: DateTime.now(),
      );
    });
  }

  void _selectPlanta(int p) {
    setState(() {
      _plantaSel = p;
      _racimosPorPlanta.putIfAbsent(p, () => 0);

      _racimoSel = null;
      _tamanoSel = null;
      _colorSel = null;
      _brixCtrl.clear();
    });
  }

  // + Plantas
  void _incPlantas() {
    setState(() {
      _plantas++;
      _racimosPorPlanta.putIfAbsent(_plantas, () => 0);
    });
  }

  // + Racimos (por planta seleccionada)
  void _addRacimoToPlantaSel() {
    setState(() {
      final actual = _racimosPorPlanta[_plantaSel] ?? 0;
      _racimosPorPlanta[_plantaSel] = actual + 1;
    });
  }

  void _openRegistroRacimo(int racimo) {
    setState(() {
      _racimoSel = racimo;

      final k = _key(_plantaSel, racimo);
      final reg = _registroPorRacimo[k];

      if (reg != null) {
        _tamanoSel = reg.tamano;
        _colorSel = reg.color;
        _brixCtrl.text = reg.brix.toStringAsFixed(2);
      } else {
        _tamanoSel = null;
        _colorSel = null;
        _brixCtrl.clear();
      }
    });
  }

  Future<void> _confirmEliminar({
    required String titulo,
    required String mensaje,
    required VoidCallback onOk,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) onOk();
  }

  // Long press: eliminar racimo específico (reindexa)
  void _eliminarRacimo(int r) {
    _confirmEliminar(
      titulo: 'Eliminar Racimo',
      mensaje:
          '¿Eliminar ${r.toString().padLeft(2, '0')} de Planta ${_plantaSel.toString().padLeft(2, '0')}?',
      onOk: () {
        setState(() {
          final total = _racimosPorPlanta[_plantaSel] ?? 0;
          if (r < 1 || r > total) return;

          _registroPorRacimo.remove(_key(_plantaSel, r));

          for (int i = r + 1; i <= total; i++) {
            final oldK = _key(_plantaSel, i);
            final newK = _key(_plantaSel, i - 1);
            final reg = _registroPorRacimo.remove(oldK);
            if (reg != null) {
              _registroPorRacimo[newK] = reg.copyWith(
                nroRacimo: reg.nroRacimo - 1,
              );
            }
          }

          _racimosPorPlanta[_plantaSel] = total - 1;

          if (_racimoSel == r) {
            _racimoSel = null;
            _tamanoSel = null;
            _colorSel = null;
            _brixCtrl.clear();
          } else if (_racimoSel != null && _racimoSel! > r) {
            _racimoSel = _racimoSel! - 1;
          }
        });
      },
    );
  }

  // Long press: eliminar planta específica (reindexa plantas y registros)
  void _eliminarPlanta(int p) {
    if (_plantas <= 1) return;

    _confirmEliminar(
      titulo: 'Eliminar Planta',
      mensaje:
          '¿Eliminar ${p.toString().padLeft(2, '0')}? Se eliminarán sus racimos y registros.',
      onOk: () {
        setState(() {
          if (p < 1 || p > _plantas) return;

          _racimosPorPlanta.remove(p);
          _registroPorRacimo.removeWhere((k, v) => k.startsWith('$p-'));

          for (int pl = p + 1; pl <= _plantas; pl++) {
            final cnt = _racimosPorPlanta.remove(pl) ?? 0;
            _racimosPorPlanta[pl - 1] = cnt;

            for (int r = 1; r <= cnt; r++) {
              final oldK = '$pl-$r';
              final newK = '${pl - 1}-$r';
              final reg = _registroPorRacimo.remove(oldK);
              if (reg != null) {
                _registroPorRacimo[newK] = reg.copyWith(planta: reg.planta - 1);
              }
            }
          }

          _plantas--;

          if (_plantaSel > _plantas) _plantaSel = _plantas;

          _racimoSel = null;
          _tamanoSel = null;
          _colorSel = null;
          _brixCtrl.clear();

          _racimosPorPlanta.putIfAbsent(_plantaSel, () => 0);
        });
      },
    );
  }

  void _limpiarTodo() {
    setState(() {
      _variedad = null;
      _lote = null;

      _plantas = 1;
      _plantaSel = 1;

      _racimosPorPlanta
        ..clear()
        ..[1] = 0;

      _registroPorRacimo.clear();

      _racimoSel = null;
      _tamanoSel = null;
      _colorSel = null;
      _brixCtrl.clear();
    });
  }

  int _totalRegistros() => _registroPorRacimo.length;

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEDICIÓN BRIX PRE - COSECHA'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            tooltip: 'Limpiar',
            onPressed: _limpiarTodo,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
          const _SectionTitle(
            icon: Icons.location_on_outlined,
            title: 'Ubicación del Lote',
          ),
          const SizedBox(height: 10),

          const _FieldLabel(text: 'Variedad del Cultivo', required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _variedad,
            items: _variedades
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) {
              setState(() => _variedad = v);
              _autoGuardarSiCompleto();
            },
            decoration: _inputDecoration(prefix: Icons.local_florist_outlined),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Seleccione variedad' : null,
          ),

          const SizedBox(height: 14),

          const _FieldLabel(text: 'Lote / SubLote', required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _lote,
            items: _lotes
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) {
              setState(() => _lote = v);
              _autoGuardarSiCompleto();
            },
            decoration: _inputDecoration(prefix: Icons.map_outlined),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Seleccione lote/sub-lote' : null,
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),

          // ✅ EXACTO COMO TU IMAGEN: 2 tarjetas arriba (Plantas / Racimos)
          Row(
            children: [
              Expanded(
                child: _HeaderCounterCard(
                  title: 'Plantas',
                  value: _plantas,
                  onPlus: _incPlantas,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderCounterCard(
                  title: 'Racimos',
                  value: _racimosDePlantaSel,
                  onPlus: _addRacimoToPlantaSel,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ CUADROS ABAJO (Plantas / Racimos) con scroll
          LayoutBuilder(
            builder: (context, c) {
              final double boxH = c.maxWidth < 420 ? 220 : 180;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ScrollBox(
                      height: boxH,
                      title: 'Plantas',
                      child: _plantasGrid(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScrollBox(
                      height: boxH,
                      title: 'Racimos',
                      child: _racimosGrid(),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),
          _InfoPill(text: 'Total registros guardados: ${_totalRegistros()}'),
        ],
      ),
    );
  }

  // ✅ Botones SOLO 01, 02...
  Widget _plantasGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_plantas, (i) {
        final p = i + 1;
        final sel = p == _plantaSel;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: sel
                ? const Color(0xFF2E7D32)
                : const Color(0xFF43A047),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _selectPlanta(p),
          onLongPress: () => _eliminarPlanta(p),
          child: Text(p.toString().padLeft(2, '0')),
        );
      }),
    );
  }

  // ✅ Botones SOLO 01, 02...
  Widget _racimosGrid() {
    final n = _racimosDePlantaSel;

    if (n == 0) {
      return const Text(
        'Sin racimos.\nAgrega con +',
        style: TextStyle(color: Colors.black54),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(n, (i) {
        final r = i + 1;
        final k = _key(_plantaSel, r);
        final hasReg = _registroPorRacimo.containsKey(k);
        final selected = _racimoSel == r;

        final bg = selected ? const Color(0xFF0D47A1) : const Color(0xFF1E88E5);

        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _openRegistroRacimo(r),
          onLongPress: () => _eliminarRacimo(r),
          icon: Icon(
            hasReg ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: Colors.white,
          ),
          label: Text(r.toString().padLeft(2, '0')),
        );
      }),
    );
  }

  Widget _rightPanel() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.fact_check_outlined,
            title: 'Registro',
          ),
          const SizedBox(height: 12),

          _InfoPill(
            text: _racimoSel == null
                ? 'Planta ${_plantaSel.toString().padLeft(2, '0')} • Seleccione un Racimo'
                : 'Planta ${_plantaSel.toString().padLeft(2, '0')} • Racimo ${_racimoSel!.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 12),

          // ✅ Tamaño en 1 fila (sin ícono)
          const _FieldLabel(text: 'Tamaño', required: true),
          const SizedBox(height: 8),
          _ChoiceChips(
            options: _tamanios,
            value: _tamanoSel,
            maxPerRow: 3,
            onChanged: (v) {
              setState(() => _tamanoSel = v);
              _autoGuardarSiCompleto();
            },
          ),

          const SizedBox(height: 16),

          // ✅ Color en 2 filas (sin ícono)
          const _FieldLabel(text: 'Color', required: true),
          const SizedBox(height: 8),
          _ChoiceChips(
            options: _colores,
            value: _colorSel,
            maxPerRow: 3,
            onChanged: (v) {
              setState(() => _colorSel = v);
              _autoGuardarSiCompleto();
            },
          ),

          const SizedBox(height: 16),

          // Brix (auto-guardado al escribir)
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
            onChanged: (_) => _autoGuardarSiCompleto(),
            decoration: _inputDecoration(
              prefix: Icons.science_outlined,
              hint: 'Ej: 18.25',
              helper:
                  'Auto-guardado: se guarda al completar Tamaño/Color/Brix.',
            ),
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 8),

          _ResumenPorPlanta(
            plantaSel: _plantaSel,
            racimosCount: _racimosDePlantaSel,
            registros: _registroPorRacimo,
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
   Widgets UI
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Colors.white.withOpacity(0.85),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

/* =========================
   Header cards (Plantas / Racimos) como screenshot
========================= */
class _HeaderCounterCard extends StatelessWidget {
  const _HeaderCounterCard({
    required this.title,
    required this.value,
    required this.onPlus,
  });

  final String title;
  final int value;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Colors.white.withOpacity(0.92),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(width: 10),
          IconButton(
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: onPlus,
            icon: const Icon(
              Icons.add_circle,
              size: 22,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   ScrollBox para Plantas/Racimos
========================= */
class _ScrollBox extends StatelessWidget {
  const _ScrollBox({
    required this.height,
    required this.title,
    required this.child,
  });

  final double height;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Colors.white.withOpacity(0.85),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Expanded(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

/* =========================
   Chips en filas (sin icono)
========================= */
class _ChoiceChips extends StatelessWidget {
  const _ChoiceChips({
    required this.options,
    required this.value,
    required this.onChanged,
    this.maxPerRow,
  });

  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final int? maxPerRow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final spacing = 10.0;

        double? chipW;
        if (maxPerRow != null && maxPerRow! > 0) {
          chipW = (c.maxWidth - spacing * (maxPerRow! - 1)) / maxPerRow!;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children: options.map((opt) {
            final selected = opt == value;

            final chip = InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(opt),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? const Color(0xFF1B5E20) : Colors.black12,
                  ),
                  color: selected
                      ? const Color(0xFF1B5E20).withOpacity(0.10)
                      : Colors.white.withOpacity(0.85),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFF1B5E20) : Colors.black87,
                  ),
                ),
              ),
            );

            if (chipW != null) {
              return SizedBox(width: chipW, child: chip);
            }
            return chip;
          }).toList(),
        );
      },
    );
  }
}

/* =========================
   Resumen simple por planta seleccionada
========================= */
class _ResumenPorPlanta extends StatelessWidget {
  const _ResumenPorPlanta({
    required this.plantaSel,
    required this.racimosCount,
    required this.registros,
  });

  final int plantaSel;
  final int racimosCount;
  final Map<String, RacimoRegistro> registros;

  String _key(int planta, int racimo) => '$planta-$racimo';

  @override
  Widget build(BuildContext context) {
    int guardados = 0;
    for (int r = 1; r <= racimosCount; r++) {
      if (registros.containsKey(_key(plantaSel, r))) guardados++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen Planta ${plantaSel.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text('Racimos creados: $racimosCount'),
        Text('Racimos con registro guardado: $guardados'),
        if (racimosCount > 0) Text('Pendientes: ${racimosCount - guardados}'),
        const SizedBox(height: 6),
        const Text(
          'Tip: Mantén presionado Planta/Racimo para eliminar.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
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
