import 'dart:math';

import 'package:flutter/material.dart';

import '../../../app/widgets/widgets.dart';
import '../../../core/helpers/form_factor.dart';
import '../../calculator_cubit/calculator_cubit.dart';
import 'sheet_tiles.dart';

/// Widget that on larger screens will hold the contents of the drawer, in
/// the form of a collapsible side panel.
class SidePanel extends StatefulWidget {
  const SidePanel({Key? key}) : super(key: key);

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  final _closePanelButton = Opacity(
    opacity: 0.8,
    child: IconButton(
      onPressed: () => calcCubit.toggleShowSidePanel(),
      icon: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: const Icon(Icons.exit_to_app),
      ),
    ),
  );

  final _addSheetButton = Opacity(
    opacity: 0.8,
    child: IconButton(
      icon: const Icon(Icons.add),
      onPressed: () => calcCubit.addSheet(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final bool _isHandset = isHandset(context);

    final Widget _panelBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: (_isHandset)
              ? MainAxisAlignment.end
              : MainAxisAlignment.spaceBetween,
          children: [
            if (!_isHandset) _closePanelButton,
            _addSheetButton,
          ],
        ),
        const SheetTiles(),
        ListTile(
          title: const Center(child: Text('About')),
          onTap: () => showDialog(
            context: context,
            builder: (context) => const CustomAboutDialog(),
          ),
        ),
      ],
    );

    if (_isHandset) return _panelBody;

    return Container(
      color: Theme.of(context).cardColor,
      width: 150,
      child: _panelBody,
    );
  }
}
