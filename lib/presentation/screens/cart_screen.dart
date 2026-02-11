// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/cart_provider.dart';
// import '../../data/models/order_model.dart';
// import '../../data/services/api_service.dart';

// class CartScreen extends StatefulWidget {
//   const CartScreen({Key? key}) : super(key: key);

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   final ApiService _apiService = ApiService();

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _phoneController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   Future<void> _placeOrder() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);

//     if (_addressController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter delivery address')),
//       );
//       return;
//     }

//     if (_phoneController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter phone number')),
//       );
//       return;
//     }

//     // Show confirmation dialog
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Order'),
//         content: Text(
//           'Place order for \$${cartProvider.total.toStringAsFixed(2)}?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     try {
//       // Show loading
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );

//       final orderRequest = OrderRequestModel(
//         userId: authProvider.currentUser!.userId,
//         deliveryAddress: _addressController.text,
//         phone: _phoneController.text,
//         notes: _notesController.text.isEmpty ? null : _notesController.text,
//       );

//       final response = await _apiService.placeOrder(orderRequest);

//       // Close loading dialog
//       if (mounted) Navigator.pop(context);

//       // Show success and navigate to orders
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Order placed successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.of(context).pushReplacementNamed('/orders');
//       }
//     } catch (e) {
//       // Close loading dialog
//       if (mounted) Navigator.pop(context);

//       // Show error
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to place order: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cartProvider = Provider.of<CartProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Shopping Cart'),
//       ),
//       body: cartProvider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : cartProvider.items.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.shopping_cart_outlined,
//                         size: 100,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Your cart is empty',
//                         style: TextStyle(
//                           fontSize: 20,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                         child: const Text('Start Shopping'),
//                       ),
//                     ],
//                   ),
//                 )
//               : Column(
//                   children: [
//                     // Cart Items List
//                     Expanded(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: cartProvider.items.length,
//                         itemBuilder: (context, index) {
//                           final item = cartProvider.items[index];
//                           final food = item.food;

//                           if (food == null) return const SizedBox.shrink();

//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             child: Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Row(
//                                 children: [
//                                   // Food Image
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(8),
//                                     child: food.imageUrl != null
//                                         ? CachedNetworkImage(
//                                             imageUrl: food.imageUrl!,
//                                             width: 80,
//                                             height: 80,
//                                             fit: BoxFit.cover,
//                                             placeholder: (context, url) =>
//                                                 Container(
//                                               width: 80,
//                                               height: 80,
//                                               color: Colors.grey[200],
//                                             ),
//                                             errorWidget:
//                                                 (context, url, error) =>
//                                                     Container(
//                                               width: 80,
//                                               height: 80,
//                                               color: Colors.grey[200],
//                                               child: const Icon(Icons.fastfood),
//                                             ),
//                                           )
//                                         : Container(
//                                             width: 80,
//                                             height: 80,
//                                             color: Colors.grey[200],
//                                             child: const Icon(Icons.fastfood),
//                                           ),
//                                   ),
//                                   const SizedBox(width: 12),

//                                   // Food Details
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           food.foodName,
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           '\$${food.price.toStringAsFixed(2)}',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: Theme.of(context).primaryColor,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                   // Quantity Controls
//                                   Column(
//                                     children: [
//                                       Row(
//                                         children: [
//                                           IconButton(
//                                             icon: const Icon(Icons.remove_circle_outline),
//                                             onPressed: () async {
//                                               if (item.quantity > 1) {
//                                                 await cartProvider.updateQuantity(
//                                                   item.cartItemId,
//                                                   item.quantity - 1,
//                                                 );
//                                               } else {
//                                                 await _confirmRemove(
//                                                     cartProvider, item);
//                                               }
//                                             },
//                                           ),
//                                           Text(
//                                             '${item.quantity}',
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.add_circle_outline),
//                                             onPressed: () async {
//                                               await cartProvider.updateQuantity(
//                                                 item.cartItemId,
//                                                 item.quantity + 1,
//                                               );
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                       Text(
//                                         '\$${(food.price * item.quantity).toStringAsFixed(2)}',
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),

//                     // Checkout Section
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.3),
//                             spreadRadius: 2,
//                             blurRadius: 5,
//                             offset: const Offset(0, -3),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           // Delivery Info
//                           TextField(
//                             controller: _addressController,
//                             decoration: const InputDecoration(
//                               labelText: 'Delivery Address',
//                               prefixIcon: Icon(Icons.location_on),
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           TextField(
//                             controller: _phoneController,
//                             keyboardType: TextInputType.phone,
//                             decoration: const InputDecoration(
//                               labelText: 'Phone Number',
//                               prefixIcon: Icon(Icons.phone),
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           TextField(
//                             controller: _notesController,
//                             decoration: const InputDecoration(
//                               labelText: 'Notes (Optional)',
//                               prefixIcon: Icon(Icons.note),
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // Total
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Total:',
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 '\$${cartProvider.total.toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: Theme.of(context).primaryColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),

//                           // Place Order Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: _placeOrder,
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(vertical: 16),
//                               ),
//                               child: const Text(
//                                 'Place Order',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }

//   Future<void> _confirmRemove(CartProvider cartProvider, item) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Remove Item'),
//         content: const Text('Remove this item from cart?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Remove'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       await cartProvider.removeItem(
//         authProvider.currentUser!.userId,
//         item.cartItemId,
//       );
//     }
//   }
// }