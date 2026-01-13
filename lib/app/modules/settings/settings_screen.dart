import 'package:bs_flutter/app/bloc/theme/theme_bloc.dart';
import 'package:bs_flutter/app/bloc/theme/theme_event.dart';
import 'package:bs_flutter/app/bloc/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('settings'), centerTitle: false),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.maxFinite,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text('system', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text('light', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text('dark', style: TextStyle(fontSize: 12)),
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
                const SizedBox(height: 8),
                SwitchListTile(
                  // thumb icon
                  title: const Text('dynamic colors', style: TextStyle(fontSize: 14)),
                  value: state.dynamicColorEnabled,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(ToggleDynamicColor(value));
                  },
                ),
                // const SizedBox(height: 16),
                // const Text(
                //   'About',
                //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                // ),
                // const SizedBox(height: 16),
                // ListTile(
                //   leading: Icon(
                //     Icons.code,
                //     color: Theme.of(context).colorScheme.primary,
                //   ),
                //   title: const Text('Source Code'),
                //   onTap: () {
                //     launchUrl(
                //       Uri.parse(
                //         'https://github.com/ronellsalunke/',
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
