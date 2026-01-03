import 'dart:io';
import 'dart:typed_data';
import 'package:arunstore/adminservice/productapiservice.dart';
import 'package:arunstore/model/model/productmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  const ProductForm({super.key, this.product});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();

  XFile? _pickedImage;
  Uint8List? _webImage;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _mrpController;
  late TextEditingController _ratingController;
  late TextEditingController _categoryController;
  late TextEditingController _stockController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _titleController = TextEditingController(text: p?.title ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _mrpController = TextEditingController(text: p?.mrp.toString() ?? '');
    _ratingController = TextEditingController(text: p?.rating.toString() ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Reduce quality for smaller files
        maxWidth: 800, // Limit width
        maxHeight: 800, // Limit height
      );
      
      if (picked != null) {
        if (kIsWeb) {
          // For web, store bytes
          _webImage = await picked.readAsBytes();
          // Check file size (max 2MB)
          if (_webImage!.length > 2 * 1024 * 1024) {
            _showError('Image size too large. Max 2MB allowed.');
            return;
          }
          // Create XFile from bytes
          _pickedImage = XFile.fromData(
            _webImage!,
            name: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
            mimeType: 'image/jpeg',
          );
        } else {
          // For mobile, check file size
          final file = File(picked.path);
          final size = await file.length();
          if (size > 2 * 1024 * 1024) {
            _showError('Image size too large. Max 2MB allowed.');
            return;
          }
          _pickedImage = picked;
        }
        setState(() {});
      }
    } catch (e) {
     
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Validate all fields
      final price = double.tryParse(_priceController.text);
      final mrp = double.tryParse(_mrpController.text);
      final rating = double.tryParse(_ratingController.text);
      final stock = int.tryParse(_stockController.text);

      if (price == null || mrp == null || rating == null || stock == null) {
        throw Exception('Invalid numeric values');
      }

      if (price < 0 || mrp < 0 || rating < 0 || rating > 5 || stock < 0) {
        throw Exception('Invalid values. Check price, rating, and stock.');
      }

      final product = Product(
        id: widget.product?.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        mrp: mrp,
        rating: rating,
        category: _categoryController.text.trim(),
        stock: stock,
        images: widget.product?.images ?? [],
      );

      bool success;
      if (widget.product == null) {
        success = await _addProductWithRetry(product, _pickedImage);
      } else {
        success = await _updateProductWithRetry(product, _pickedImage);
      }

      if (success && mounted) {
        _showSuccess(widget.product == null 
            ? 'Product added successfully!' 
            : 'Product updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showError('Error saving product: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _addProductWithRetry(Product product, XFile? imageFile) async {
    try {
      await ApiService.addProduct(product, imageFile);
      return true;
    } catch (e) {
     
      if (imageFile != null) {
        try {
          _showError('Image upload failed, trying without image...');
          await ApiService.addProduct(product, null);
          return true;
        } catch (e2) {
       
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<bool> _updateProductWithRetry(Product product, XFile? imageFile) async {
    try {
      await ApiService.updateProduct(product, imageFile);
      return true;
    } catch (e) {

      if (imageFile != null) {
        try {
          _showError('Image upload failed, trying without image...');
          await ApiService.updateProduct(product, null);
          return true;
        } catch (e2) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.product == null ? 'Add Product' : 'Edit Product',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                _field(_titleController, 'Title'),
                _field(_descController, 'Description', maxLines: 3),
                _field(
                  _priceController, 
                  'Price', 
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                _field(
                  _mrpController, 
                  'MRP', 
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                _field(
                  _ratingController, 
                  'Rating (0-5)', 
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                _field(_categoryController, 'Category'),
                _field(
                  _stockController, 
                  'Stock', 
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 15),

                _buildImagePreview(),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image (Max 2MB)'),
                  onPressed: _pickImage,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                        ),
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    // Show picked image first
    if (kIsWeb && _webImage != null) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.memory(
          _webImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            );
          },
        ),
      );
    }

    if (!kIsWeb && _pickedImage != null) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.file(
          File(_pickedImage!.path),
          fit: BoxFit.cover,
        ),
      );
    }

    // Show existing product image with AVIF handling
    if (widget.product != null && widget.product!.images.isNotEmpty) {
      final imageUrl = widget.product!.images.first;
      final isAvif = imageUrl.toLowerCase().endsWith('.avif');
      
      if (isAvif) {
        // For AVIF, try to convert to JPG URL
        final jpgUrl = imageUrl.replaceAll('.avif', '.jpg');
        return Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.network(
            jpgUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 40, color: Colors.grey),
                      SizedBox(height: 5),
                      Text('AVIF Image', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
      
      // For non-AVIF images
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            );
          },
        ),
      );
    }

    return Container(
      height: 120,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: Colors.grey),
          SizedBox(height: 5),
          Text(
            'No image selected',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller, 
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          
          if (keyboardType?.toString().contains('number') == true) {
            final numValue = double.tryParse(value);
            if (numValue == null) {
              return 'Enter a valid number';
            }
            
            if (label.contains('Rating') && (numValue < 0 || numValue > 5)) {
              return 'Rating must be between 0 and 5';
            }
            
            if (label == 'Stock' && numValue < 0) {
              return 'Stock cannot be negative';
            }
            
            if ((label == 'Price' || label == 'MRP') && numValue < 0) {
              return 'Price cannot be negative';
            }
          }
          
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}