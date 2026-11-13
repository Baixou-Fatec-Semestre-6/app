import 'package:flutter/material.dart';

import '../config/env_config.dart';
import '../theme/app_theme.dart';

class DemoCodeBanner extends StatelessWidget {
  const DemoCodeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!EnvConfig.showDemoAuthCode) return const SizedBox.shrink();

    return Semantics(
      label: 'Código de demonstração ${EnvConfig.demoAuthCode}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.brandTint15,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.brandBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.science_outlined,
              size: 20,
              color: AppTheme.brandHover,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text.rich(
                TextSpan(
                  text: 'Ambiente de demonstração: use ',
                  children: [
                    TextSpan(
                      text: EnvConfig.demoAuthCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppTheme.brandHover,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textBody),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
