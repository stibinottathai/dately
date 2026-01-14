import 'package:dately/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DiscoveryIllustration extends StatelessWidget {
  const DiscoveryIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDqmwqcSBayUUZR67TLSp50rYi-oax8O_HxeHle7jVq7AZ47Z5HPcFTR728DNaFVbNsa1gOdTx-qz7T2iCCHtA3Vs8TWncBryZ1iGrSf1-WNScgOt9lGvXwnP2pYO_8aQ9Nu_jztZBqVcCbNe1sEp3wpdPf3BIt6gYHV0067AOOvpSM7zo59DpAlirX-kAgm_QUGD250JKWzO2_Hpv-AvOq8s8jzT4zqlmKMy4TgxsiMFTO8sOwcn5QFrDDYGO7kswX3mPWT0zd3O0',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ConversationIllustration extends StatelessWidget {
  const ConversationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Circle Decoration
        Container(
          width: 256,
          height: 256,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        // Chat Bubble / Cup Container
        Container(
          width: 192,
          height: 192,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, // Allow overflow items
            children: [
              // Main Icon: Chat Bubble
              const Icon(Icons.chat_bubble, size: 80, color: AppColors.primary),
              // Floating Coffee Cup
              Positioned(
                top: -16,
                right: -16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.coffee,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              // Bottom Heart
              const Positioned(
                bottom: 32,
                child: Icon(Icons.favorite, size: 32, color: AppColors.primary),
              ),
            ],
          ),
        ),
        // Steam Icons
        const Positioned(
          top: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.air, size: 32, color: AppColors.primary),
              SizedBox(width: 8),
              Icon(Icons.air, size: 24, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class SafetyIllustration extends StatelessWidget {
  const SafetyIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse Effect
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        // Main Shield Icon
        const Icon(Icons.shield, size: 140, color: AppColors.primary),
        // Center Heart
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Icon(Icons.favorite, size: 50, color: Colors.white),
        ),
      ],
    );
  }
}
