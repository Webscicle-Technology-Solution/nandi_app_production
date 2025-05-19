import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/features/subscription_payment/page/payment_page.dart';
import 'package:nandiott_flutter/features/subscription_payment/provider/subscription_provider.dart';
import 'package:nandiott_flutter/features/subscription_payment/provider/subscriptionplan_provider.dart';

class SubscriptionPlanModal extends ConsumerStatefulWidget {
  final String userId;
  final String movieId;

  const SubscriptionPlanModal({
    super.key,
    required this.userId,
    required this.movieId,
  });

  @override
  ConsumerState<SubscriptionPlanModal> createState() =>
      _SubscriptionPlanModalState();
}

class _SubscriptionPlanModalState extends ConsumerState<SubscriptionPlanModal> {
  List<FocusNode> _planFocusNodes = [];
  int focusedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.refresh(subscriptionProvider(
        SubscriptionDetailParameter(userId: widget.userId)));
  }

  void _handlePlanSelect(dynamic plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionPaymentRedirectPage(
          movieId: widget.movieId,
          planName: plan.name,
          redirectUrl: "https://nandi.webscicle.com/app/subscriptionreport",
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var node in _planFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plansState = ref.watch(subscriptionPlanProvider);
    final selectedSubscription = ref.watch(
      subscriptionProvider(
        SubscriptionDetailParameter(userId: widget.userId),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose Your Subscription Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          plansState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Text("❌ Error: $error", style: TextStyle(color: Colors.red)),
            data: (plans) {
              if (_planFocusNodes.isEmpty) {
                _planFocusNodes = List.generate(plans.length, (_) => FocusNode());
              }

              if (plans.isEmpty) {
                return const Text('No subscription plans available');
              }

              return Column(
                children: plans.asMap().entries.map((entry) {
                  final index = entry.key;
                  final plan = entry.value;

                  Gradient? backgroundGradient;
                  if (plan.name.toLowerCase() == 'free') {
                    backgroundGradient = const LinearGradient(
                      colors: [Color(0xFFA8E6CF), Color(0xFF56AB2F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  } else if (plan.name.toLowerCase() == 'silver') {
                    backgroundGradient = const LinearGradient(
                      colors: [Color(0xFFC0C0C0), Color(0xFFE0E0E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  } else if (plan.name.toLowerCase() == 'gold') {
                    backgroundGradient = const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                  }

                  return Focus(
                    focusNode: _planFocusNodes[index],
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        setState(() => focusedIndex = index);
                      }
                    },
                    onKey: (node, event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                          if (index + 1 < _planFocusNodes.length) {
                            FocusScope.of(context)
                                .requestFocus(_planFocusNodes[index + 1]);
                            return KeyEventResult.handled;
                          }
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.arrowUp) {
                          if (index - 1 >= 0) {
                            FocusScope.of(context)
                                .requestFocus(_planFocusNodes[index - 1]);
                            return KeyEventResult.handled;
                          }
                        } else if (event.logicalKey ==
                            LogicalKeyboardKey.select ||
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          _handlePlanSelect(plan);
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: GestureDetector(
                      onTap: () => _handlePlanSelect(plan),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          gradient: backgroundGradient,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: focusedIndex == index
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          tileColor: Colors.transparent,
                          leading: Radio<String>(
                            value: plan.name,
                            groupValue: selectedSubscription.when(
                              data: (sub) => sub?.subscriptionType.name,
                              loading: () => null,
                              error: (_, __) => null,
                            ),
                            onChanged: (value) => _handlePlanSelect(plan),
                            activeColor: Colors.black,
                          ),
                          title: Text(
                            plan.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            plan.description,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          trailing: Text(
                            plan.price == 0 ? "Free" : "₹${plan.price}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
