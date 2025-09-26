import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dinner_provider.dart';

class SpecialDinnerPage extends StatefulWidget {
  const SpecialDinnerPage({super.key});

  @override
  State<SpecialDinnerPage> createState() => _SpecialDinnerPageState();
}

class _SpecialDinnerPageState extends State<SpecialDinnerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.3,
      upperBound: 1.0,
    )..repeat(reverse: true); // smooth blinking
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _confirmRedeem(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Redemption"),
        content: const Text("Do you want to redeem your special dinner token?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DinnerProvider>().redeemDinner();
            },
            child: const Text("Redeem"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DinnerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Digital Mess Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Card content (horizontal layout)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: const AssetImage("assets/profile.png"),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "John Doe",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text("Roll No: 123456",
                              style: TextStyle(fontSize: 16)),
                          const Text("Mess: A", style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          if (!provider.token.hasEaten)
                            ElevatedButton(
                              onPressed: () => _confirmRedeem(context),
                              child: const Text("Redeem Special Dinner"),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Red blinking rectangle badge at top-right corner
              if (!provider.token.hasEaten)
                Positioned(
                  top: 8,
                  right: 8,
                  child: FadeTransition(
                    opacity: _blinkController,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      // Temporary reset button for testing
      floatingActionButton: FloatingActionButton(
        tooltip: "Reset Token",
        child: const Icon(Icons.refresh),
        onPressed: () {
          context.read<DinnerProvider>().resetDinner();
        },
      ),
    );
  }
}
