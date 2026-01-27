import 'package:bs_flutter/app/bloc/theme/theme_bloc.dart';
import 'package:bs_flutter/app/bloc/theme/theme_event.dart';
import 'package:bs_flutter/app/bloc/theme/theme_state.dart';
import 'package:bs_flutter/app/res/app_icons.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('settings'), centerTitle: false),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                verticalSpace(16),
                Container(
                  decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: SegmentedButton<ThemeMode>(
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('system', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        icon: Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('light', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('dark', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: {state.themeMode},
                    onSelectionChanged: (Set<ThemeMode> selection) {
                      if (selection.isNotEmpty) {
                        context.read<ThemeBloc>().add(ChangeThemeMode(selection.first));
                      }
                    },
                  ),
                ),
                verticalSpace(12),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: const Text('dynamic colors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  tileColor: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  value: state.dynamicColorEnabled,
                  thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const Icon(Icons.check, size: 16);
                    }
                    return const Icon(Icons.close, size: 16);
                  }),
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(ToggleDynamicColor(value));
                  },
                ),
                verticalSpace(24),
                Text(
                  'about',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                verticalSpace(16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: SvgPicture.asset(AppIcons.githubIcon, height: 24, width: 24, color: colorScheme.primary),
                  title: const Text('source code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: colorScheme.surfaceContainer,
                  onTap: () => launchUrl(Uri.parse('https://github.com/ronellsalunke/bill_splitter_flutter')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
