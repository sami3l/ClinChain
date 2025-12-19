import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/lot_provider.dart';
import '../widgets/app_snackbar.dart';

class CreateLotScreen extends StatefulWidget {
  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  final _form = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  String _name = '';
  int _qty = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un nouveau lot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medication,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nouveau lot',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Remplissez les informations du médicament',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Medicine name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du médicament',
                  hintText: 'Ex: Paracetamol 500mg',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Le nom du médicament est requis';
                  }
                  if (v.trim().length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
                onSaved: (v) => _name = v!.trim(),
              ),
              const SizedBox(height: 20),

              // Quantity field
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(
                  labelText: 'Quantité',
                  hintText: 'Ex: 1000',
                  prefixIcon: Icon(Icons.inventory_2),
                  suffixText: 'unités',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'La quantité est requise';
                  }
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) {
                    return 'Entrez un nombre positif';
                  }
                  if (n > 1000000) {
                    return 'La quantité ne peut pas dépasser 1 000 000';
                  }
                  return null;
                },
                onSaved: (v) => _qty = int.parse(v!),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _submitting ? null : _handleSubmit,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline),
                          SizedBox(width: 8),
                          Text('Créer le lot'),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              // Cancel button
              OutlinedButton(
                onPressed:
                    _submitting ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_form.currentState!.validate()) return;

    _form.currentState!.save();
    setState(() => _submitting = true);

    try {
      final lotProvider = Provider.of<LotProvider>(context, listen: false);
      await lotProvider.createLot(_name, _qty);

      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          'Lot créé avec succès: $_name ($_qty unités)',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Erreur lors de la création du lot',
        );
        setState(() => _submitting = false);
      }
    }
  }
}
