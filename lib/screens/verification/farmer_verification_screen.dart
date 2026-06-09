import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/verification_service.dart';
import '../../models/verification/verification_models.dart';

class FarmerVerificationScreen extends StatefulWidget {
  const FarmerVerificationScreen({super.key});

  @override
  State<FarmerVerificationScreen> createState() => _FarmerVerificationScreenState();
}

class _FarmerVerificationScreenState extends State<FarmerVerificationScreen> {
  final VerificationService _verificationService = VerificationService();
  final _formKey = GlobalKey<FormState>();
  
  final _farmNameController = TextEditingController();
  final _farmLocationController = TextEditingController();
  final _experienceController = TextEditingController();
  
  List<VerificationDocument> _documents = [];
  bool _isSubmitting = false;
  FarmerVerification? _existingVerification;
  
  final List<Map<String, dynamic>> _documentTypes = [
    {'type': DocumentType.nationalId, 'name': 'National ID', 'icon': Icons.badge},
    {'type': DocumentType.farmLicense, 'name': 'Farm License', 'icon': Icons.description},
    {'type': DocumentType.landOwnership, 'name': 'Land Ownership', 'icon': Icons.landscape},
    {'type': DocumentType.certificate, 'name': 'Organic Certificate', 'icon': Icons.eco},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingVerification();
  }

  Future<void> _loadExistingVerification() async {
    final verification = await _verificationService.getVerificationStatus(
      _verificationService.currentUserId ?? ''
    );
    if (verification != null) {
      setState(() {
        _existingVerification = verification;
      });
    }
  }

  Future<void> _uploadDocument(DocumentType type, String name) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final url = await _verificationService.uploadDocument(file, name);
      
      if (url != null) {
        setState(() {
          _documents.add(VerificationDocument(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: type,
            documentName: name,
            fileUrl: url,
            uploadedAt: DateTime.now(),
            status: VerificationStatus.pending,
          ));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least one document')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    final success = await _verificationService.submitVerification(
      farmName: _farmNameController.text,
      farmLocation: _farmLocationController.text,
      yearsOfExperience: int.parse(_experienceController.text),
      documents: _documents,
    );
    
    setState(() => _isSubmitting = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification submitted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit verification')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_existingVerification != null) {
      return _buildStatusScreen();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Verified'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Get verified to build trust with buyers and access premium features',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Farm Details
              const Text('Farm Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _farmNameController,
                decoration: const InputDecoration(
                  labelText: 'Farm Name',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter farm name' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _farmLocationController,
                decoration: const InputDecoration(
                  labelText: 'Farm Location',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter farm location' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  prefixIcon: Icon(Icons.timeline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Enter years of experience' : null,
              ),
              const SizedBox(height: 24),
              
              // Documents
              const Text('Supporting Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Upload clear photos of your documents',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _documentTypes.length,
                itemBuilder: (context, index) {
                  final doc = _documentTypes[index];
                  final isUploaded = _documents.any((d) => d.type == doc['type']);
                  
                  return GestureDetector(
                    onTap: () => _uploadDocument(doc['type'], doc['name']),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: isUploaded ? Colors.green : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: isUploaded ? Colors.green.shade50 : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isUploaded ? Icons.check_circle : doc['icon'],
                            size: 40,
                            color: isUploaded ? Colors.green : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doc['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isUploaded ? Colors.green : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isUploaded)
                            const Text(
                              'Uploaded ✓',
                              style: TextStyle(fontSize: 10, color: Colors.green),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                      : const Text('Submit Verification', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusScreen() {
    final status = _existingVerification!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: status.statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status.statusIcon,
                  size: 50,
                  color: status.statusColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                status.statusText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: status.statusColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStatusMessage(status.status),
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (status.status == VerificationStatus.pending)
                const LinearProgressIndicator(),
              if (status.status == VerificationStatus.rejected && status.notes != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Reason for rejection:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(status.notes!),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getStatusMessage(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Your verification is being reviewed. This usually takes 1-2 business days.';
      case VerificationStatus.approved:
        return 'Congratulations! Your account is now verified. You can now access premium features.';
      case VerificationStatus.rejected:
        return 'Your verification was rejected. Please check the reason below and resubmit.';
      default:
        return '';
    }
  }
}
