import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/models/store_product.dart';
import 'package:memo_granja/services/local_backup_service.dart';
import 'package:memo_granja/services/purchase_service.dart';

class AdultZoneScreen extends StatefulWidget {
  const AdultZoneScreen({
    this.backupService,
    this.purchaseService,
    super.key,
  });

  final LocalBackupService? backupService;
  final PurchaseService? purchaseService;

  @override
  State<AdultZoneScreen> createState() => _AdultZoneScreenState();
}

class _AdultZoneScreenState extends State<AdultZoneScreen> {
  static const _answer = 7;
  Timer? _holdTimer;
  bool _holding = false;
  bool _challengeVisible = false;
  bool _verified = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold(TapDownDetails details) {
    _holdTimer?.cancel();
    setState(() => _holding = true);
    _holdTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _holding = false;
        _challengeVisible = true;
      });
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (mounted && _holding) setState(() => _holding = false);
  }

  void _answerChallenge(int answer) {
    if (answer != _answer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inténtalo de nuevo.')),
      );
      return;
    }
    setState(() => _verified = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zona de adultos')),
      body: SafeArea(
        child: _verified
            ? _AdultTools(
                backupService: widget.backupService,
                purchaseService: widget.purchaseService,
              )
            : _GateContent(
                challengeVisible: _challengeVisible,
                holding: _holding,
                onAnswer: _answerChallenge,
                onCancelHold: _cancelHold,
                onStartHold: _startHold,
              ),
      ),
    );
  }
}

class _GateContent extends StatelessWidget {
  const _GateContent({
    required this.challengeVisible,
    required this.holding,
    required this.onAnswer,
    required this.onCancelHold,
    required this.onStartHold,
  });

  final bool challengeVisible;
  final bool holding;
  final ValueChanged<int> onAnswer;
  final VoidCallback onCancelHold;
  final GestureTapDownCallback onStartHold;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Esta zona es para personas adultas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            if (!challengeVisible) ...[
              Semantics(
                button: true,
                label: 'Mantén pulsado tres segundos para continuar',
                child: GestureDetector(
                  onTapDown: onStartHold,
                  onTapUp: (_) => onCancelHold(),
                  onTapCancel: onCancelHold,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: SizedBox(
                      width: 280,
                      height: 88,
                      child: Center(
                        child: Text(
                          holding
                              ? 'Mantén pulsado…'
                              : 'Mantén pulsado 3 segundos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Resuelve esta cuenta para continuar: 3 + 4',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              for (final answer in const [6, 7, 8])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: 220,
                    height: 64,
                    child: FilledButton.tonal(
                      onPressed: () => onAnswer(answer),
                      child: Text(
                        '$answer',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdultTools extends StatefulWidget {
  const _AdultTools({this.backupService, this.purchaseService});

  final LocalBackupService? backupService;
  final PurchaseService? purchaseService;

  @override
  State<_AdultTools> createState() => _AdultToolsState();
}

class _AdultToolsState extends State<_AdultTools> {
  late final PurchaseService _purchaseService;
  late final LocalBackupService _backupService;
  bool _backupBusy = false;

  @override
  void initState() {
    super.initState();
    _purchaseService = widget.purchaseService ?? PurchaseService.instance;
    _backupService = widget.backupService ?? LocalBackupService();
    unawaited(_purchaseService.initialize());
  }

  Future<void> _exportBackup() async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      final result = await _backupService.exportBackup();
      if (!mounted) return;
      _showMessage('Respaldo creado: ${result.completedLevels} niveles.');
    } on BackupExportCanceled {
      // Cancelar el selector no es un error que deba interrumpir la zona adulta.
    } on Object {
      if (!mounted) return;
      _showMessage('No se pudo crear el respaldo.');
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _importBackup() async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      final result = await _backupService.importBackup();
      if (!mounted || result == null) return;
      _showMessage('Respaldo restaurado: ${result.completedLevels} niveles.');
    } on FormatException {
      if (!mounted) return;
      _showMessage('El archivo no es un respaldo válido de Memo Granja.');
    } on Object {
      if (!mounted) return;
      _showMessage('No se pudo restaurar el respaldo.');
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        _PurchasePanel(service: _purchaseService),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Respaldo local',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guarda o restaura el progreso del dispositivo. El respaldo no incluye compras ni cuentas.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _backupBusy ? null : _exportBackup,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('EXPORTAR'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _backupBusy ? null : _importBackup,
                      icon: const Icon(Icons.file_open),
                      label: const Text('RESTAURAR'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PurchasePanel extends StatefulWidget {
  const _PurchasePanel({required this.service});

  final PurchaseService service;

  @override
  State<_PurchasePanel> createState() => _PurchasePanelState();
}

class _PurchasePanelState extends State<_PurchasePanel> {
  Future<void> _restore() => widget.service.restore();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.service,
      builder: (context, child) {
        final service = widget.service;
        final busy = service.state == PurchaseState.loading ||
            service.state == PurchaseState.pending;
        if (service.hasAccess) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.verified, color: AppColors.primary),
              title: const Text('Acceso completo activo'),
              subtitle: Text(
                service.hasLifetime
                    ? 'Compra única de por vida'
                    : 'Paquete(s) desbloqueado(s)',
              ),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acceso completo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Una sola compra, sin suscripción ni cuenta de Memo Granja. La tienda vincula la compra a su cuenta.',
                ),
                const SizedBox(height: 12),
                if (service.state == PurchaseState.unavailable ||
                    service.state == PurchaseState.error)
                  const Text('La tienda no está disponible ahora.'),
                for (final product in service.products)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: FilledButton(
                      onPressed: busy
                          ? null
                          : () => widget.service.buy(product.definition),
                      child: Text(
                          '${_label(product.definition)} · ${product.price}'),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: busy ? null : _restore,
                  child: const Text('RESTAURAR COMPRA'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _label(StoreProduct definition) {
    return definition.kind == StoreProductKind.lifetime
        ? 'Desbloquear todo para siempre'
        : 'Desbloquear paquete';
  }
}
