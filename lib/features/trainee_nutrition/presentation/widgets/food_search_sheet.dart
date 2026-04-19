import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/trainee_app/domain/entities/ingredient_library_item.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';

/// Bottom sheet: search `GET /ingredients`, optional custom name, calories, date → `POST /trainees/me/extra-meals`.
class FoodSearchSheet extends StatefulWidget {
  final VoidCallback? onLogged;

  const FoodSearchSheet({super.key, this.onLogged});

  @override
  State<FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends State<FoodSearchSheet> {
  final _searchCtrl = TextEditingController();
  final _customNameCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();

  final _repo = di.sl<TraineeAppRepository>();

  bool _useCatalog = true;
  List<IngredientLibraryItem> _results = [];
  bool _searchLoading = false;
  bool _catalogLoading = true;
  IngredientLibraryItem? _selected;
  DateTime _date = DateTime.now();
  bool _submitting = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _catalogLoading = true;
      _searchLoading = false;
    });
    try {
      final list = await _repo.getIngredientsCatalog();
      if (!mounted) return;
      setState(() {
        _results = list;
        _catalogLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _catalogLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _customNameCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(q));
  }

  Future<void> _runSearch(String q) async {
    final query = q.trim();
    setState(() => _searchLoading = true);
    try {
      final list = query.isEmpty
          ? await _repo.getIngredientsCatalog()
          : await _repo.searchIngredients(query);
      if (!mounted) return;
      setState(() {
        _results = list;
        _searchLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _searchLoading = false);
    }
  }

  String _dateIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final cal = double.tryParse(_caloriesCtrl.text.trim().replaceAll(',', '.'));
    if (cal == null || cal <= 0) {
      _toast('Enter a valid calorie amount.', false);
      return;
    }

    int? ingredientId;
    String? freeName;

    if (_useCatalog) {
      final s = _selected;
      if (s == null || s.id <= 0) {
        _toast('Select a food from the list.', false);
        return;
      }
      ingredientId = s.id;
    } else {
      freeName = _customNameCtrl.text.trim();
      if (freeName.isEmpty) {
        _toast('Enter a name for this food.', false);
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      await _repo.logExtraMeal(
        ingredientId: ingredientId,
        name: freeName,
        calories: cal,
        dateIso: _dateIso(_date),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      widget.onLogged?.call();
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Extra meal logged'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString().replaceFirst('Exception: ', ''), false);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toast(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectIngredient(IngredientLibraryItem item) {
    setState(() {
      _selected = item;
      if (item.calories != null) {
        _caloriesCtrl.text = item.calories!.round().toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Log extra food',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('From catalog'),
                      icon: Icon(Icons.search, size: 18),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Custom'),
                      icon: Icon(Icons.edit_note, size: 18),
                    ),
                  ],
                  selected: {_useCatalog},
                  onSelectionChanged: (s) {
                    setState(() {
                      _useCatalog = s.first;
                      if (_useCatalog) {
                        _customNameCtrl.clear();
                      } else {
                        _selected = null;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_useCatalog) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search ingredients…',
                      prefixIcon: const Icon(Icons.search, size: 22),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (_selected != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InputChip(
                        label: Text(_selected!.name),
                        onDeleted: () => setState(() => _selected = null),
                      ),
                    ),
                  ),
                Expanded(
                  child: _catalogLoading && _results.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : Stack(
                          children: [
                            ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                              itemCount: _results.isEmpty ? 1 : _results.length,
                              itemBuilder: (context, i) {
                                if (_results.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      'No ingredients match. Try another search or use Custom.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  );
                                }
                                final item = _results[i];
                                final sel = _selected?.id == item.id;
                                return ListTile(
                                  selected: sel,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: sel ? AppColors.primary : Colors.transparent,
                                    ),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: item.calories != null
                                      ? Text('${item.calories!.round()} kcal /100g (typ.)')
                                      : null,
                                  onTap: () => _selectIngredient(item),
                                );
                              },
                            ),
                            if (_searchLoading)
                              const LinearProgressIndicator(minHeight: 2),
                          ],
                        ),
                ),
              ] else ...[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      TextField(
                        controller: _customNameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Food name',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _caloriesCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Calories (kcal)',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text(_dateIso(_date)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Log meal', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
