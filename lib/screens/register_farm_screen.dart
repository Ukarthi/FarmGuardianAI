import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../widgets/custom_card.dart';

class RegisterFarmScreen extends StatefulWidget {
  const RegisterFarmScreen({Key? key}) : super(key: key);

  @override
  State<RegisterFarmScreen> createState() => _RegisterFarmScreenState();
}

class _RegisterFarmScreenState extends State<RegisterFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameController = TextEditingController();
  final _gpsController = TextEditingController(text: "37.7749° N, 122.4194° W");
  final _acreageController = TextEditingController(text: "120");
  bool _isLoading = false;

  final List<String> _selectedCrops = [];
  final List<String> _availableCrops = ['Lettuce', 'Apples', 'Grapes', 'Wheat'];

  @override
  void dispose() {
    _farmNameController.dispose();
    _gpsController.dispose();
    _acreageController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Save in state
          final state = FarmState();
          state.updateProfile(
            newFarmName: _farmNameController.text,
            newLocation: _gpsController.text,
            newAcreage: double.tryParse(_acreageController.text) ?? 120.0,
          );
          state.saveLog(
            'System',
            'Facility successfully registered: ${_farmNameController.text} with crops: ${_selectedCrops.join(", ")}',
            'info',
          );
          
          setState(() => _isLoading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agricultural facility registered successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );

          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Facility Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textBright,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Register Agricultural Area',
                    style: AppStyles.titleStyle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Link your IoT nodes and deploy autonomous drones by defining your farm parameters below.',
                    style: AppStyles.subtitleStyle,
                  ),
                  const SizedBox(height: 24),

                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Farm Name
                        TextFormField(
                          controller: _farmNameController,
                          style: AppStyles.bodyStyle,
                          decoration: InputDecoration(
                            labelText: 'Farm Name',
                            labelStyle: AppStyles.subtitleStyle,
                            prefixIcon: const Icon(Icons.agriculture, color: AppColors.primary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Farm name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Coordinates
                        TextFormField(
                          controller: _gpsController,
                          style: AppStyles.bodyStyle,
                          decoration: InputDecoration(
                            labelText: 'GPS Boundary Coordinates',
                            labelStyle: AppStyles.subtitleStyle,
                            prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'GPS coordinates are required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Acreage Size
                        TextFormField(
                          controller: _acreageController,
                          style: AppStyles.bodyStyle,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Total Acreage Size (Acres)',
                            labelStyle: AppStyles.subtitleStyle,
                            prefixIcon: const Icon(Icons.square_foot, color: AppColors.primary),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Acreage size is required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Crop Selections
                        Text(
                          'Cultivated Crops Checkbox',
                          style: AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _availableCrops.map((crop) {
                            final isSelected = _selectedCrops.contains(crop);
                            return FilterChip(
                              label: Text(crop),
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.background : AppColors.textMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              checkmarkColor: AppColors.background,
                              backgroundColor: AppColors.background,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCrops.add(crop);
                                  } else {
                                    _selectedCrops.remove(crop);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),

                        // Save Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                                  ),
                                )
                              : const Text('Initialize Facility'),
                        ),
                      ],
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
