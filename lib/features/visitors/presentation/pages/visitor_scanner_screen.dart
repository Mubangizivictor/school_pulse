import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../bloc/visitors_state.dart';
import '../../domain/entities/pre_approved_visitor.dart';

class VisitorScannerScreen extends StatefulWidget {
  const VisitorScannerScreen({super.key});

  @override
  State<VisitorScannerScreen> createState() => _VisitorScannerScreenState();
}

class _VisitorScannerScreenState extends State<VisitorScannerScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final data = jsonDecode(code);
      
      // Check if it's a Pre-approved Visitor QR
      if (data['type'] == 'pre_approved') {
        final String preApprovedId = data['id'];
        final String name = data['name'];
        final String phone = data['phone'];
        final String purpose = data['purpose'];
        final String host = data['host'];

        if (!mounted) return;

        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pre-approved Visitor'),
            content: Text('Name: $name\nHost: $host\nPurpose: $purpose\n\nProceed to check-in?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Check In'),
              ),
            ],
          ),
        );

        if (confirm == true && mounted) {
           // Check Blacklist before proceeding
           final state = context.read<VisitorsBloc>().state;
           bool isBlacklisted = false;
           if (state is VisitorsLoaded) {
             isBlacklisted = state.blacklist.any((b) => 
               (b.phone.isNotEmpty && b.phone == phone) || 
               (b.fullName.isNotEmpty && b.fullName.toLowerCase() == name.toLowerCase()));
           }

           if (isBlacklisted) {
             if (!mounted) return;
             final proceed = await showDialog<bool>(
               context: context,
               builder: (context) => AlertDialog(
                 title: const Text('Security Alert: Blacklisted'),
                 content: Text('Warning: $name is on the security blacklist.\n\nReason: ...\n\nDo you still wish to proceed to check-in?'),
                 actions: [
                   TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abstain')),
                   TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Proceed with Caution')),
                 ],
               ),
             );
             if (!mounted) return;
             if (proceed != true) {
               setState(() => _isProcessing = false);
               return;
             }
           }

           final preApproved = PreApprovedVisitor(
             id: preApprovedId,
             fullName: name,
             phone: phone,
             purpose: purpose,
             host: host,
             schoolId: '', // Will be filled in check-in screen
             expectedDate: DateTime.now(),
             isUsed: false,
           );
           context.push('/staff/gatekeeper/visitors/new', extra: preApproved);
        } else {
           setState(() => _isProcessing = false);
        }
        return;
      }

      // Existing Check-out logic
      final String visitorId = data['id'];
      final String name = data['name'];

      // Show confirmation dialog
      if (!mounted) return;
      
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Check-out'),
          content: Text('Do you want to check out $name?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Check Out'),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        final now = DateTime.now();
        final arrival = DateTime.parse(data['arrival']);
        final duration = _calculateDuration(arrival, now);
        
        context.read<VisitorsBloc>().add(CheckOutVisitorEvent(
          visitorId: visitorId,
          departureTime: now,
          duration: duration,
        ));
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visitor $name checked out successfully')),
        );
        context.pop();
      } else {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code')),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Visitor QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          const Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Text(
              'Align the visitor\'s QR code within the frame to automatically check them out.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
