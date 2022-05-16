import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../cubit/purchases_cubit.dart';
import 'purchase_successful_page.dart';

class PurchasesPage extends StatelessWidget {
  static const id = 'purchases_page';

  const PurchasesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: BlocConsumer<PurchasesCubit, PurchasesState>(
            listenWhen: (previous, current) =>
                previous.proPurchased != current.proPurchased,
            listener: (context, state) {
              if (state.proPurchased) {
                Navigator.pushNamed(context, PurchaseSuccessfulPage.id);
              }

              if (state.purchaseError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.purchaseError!)),
                );
              }
            },
            builder: (context, state) {
              final proProduct = state.products.singleWhere(
                (element) => element.id == kProUnlockId,
              );

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(width: double.infinity),
                      const MarkdownBody(data: '# **Go Pro!**'),
                      PositionedDirectional(
                        end: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 50),
                  const MarkdownBody(data: '''
### The free version of Unit Bargain Hunter for Android allows creating up to 5 sheets.

### Unlock unlimited sheets so you can track all your products and save even more money. 💵 🎉
'''),
                  const SizedBox(height: 50),
                  InkWell(
                    onTap: () => purchasesCubit.purchasePro(),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.table_chart_outlined,
                          size: 80,
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              proProduct.price + ' ' + proProduct.currencyCode,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
