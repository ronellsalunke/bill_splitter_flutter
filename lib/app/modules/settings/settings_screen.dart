import 'package:bs_flutter/app/bloc/theme/theme_cubit.dart';
import 'package:bs_flutter/app/bloc/theme/theme_state.dart';
import 'package:bs_flutter/app/res/app_icons.dart';
import 'package:bs_flutter/extensions/context_extensions.dart';
import 'package:bs_flutter/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_segmented_list/material_segmented_list.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${info.version}+${info.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('settings'), centerTitle: false),
      body: BlocBuilder<ThemeCubit, ThemeState>(
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
                SegmentedListSection(
                  children: [
                    SegmentedListTile(
                      leading: Icon(Icons.palette_rounded, color: context.colorScheme.primary),
                      title: const Text('app theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: Text(
                        state.themeMode.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.colorScheme.primary),
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<ThemeCubit>().cycleThemeMode();
                      },
                    ),
                    SegmentedListTile(
                      leading: Icon(Icons.format_paint_rounded, color: context.colorScheme.primary),
                      title: const Text('dynamic color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      trailing: Switch(
                        value: state.dynamicColorEnabled,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          context.read<ThemeCubit>().setDynamicColorEnabled(value);
                        },
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Icon(Icons.check, size: 16);
                          }
                          return const Icon(Icons.close, size: 16);
                        }),
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<ThemeCubit>().setDynamicColorEnabled(!state.dynamicColorEnabled);
                      },
                    ),
                  ],
                ),
                verticalSpace(24),
                Text(
                  'about',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
                verticalSpace(16),
                SegmentedListSection(
                  children: [
                    SegmentedListTile(
                      leading: Icon(Icons.info_rounded, color: context.colorScheme.primary),
                      title: Text(
                        _appVersion.isEmpty ? 'loading...' : _appVersion,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SegmentedListTile(
                      leading: SvgPicture.asset(
                        AppIcons.githubIcon,
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
                      ),
                      title: const Text('github', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        launchUrl(Uri.parse('https://github.com/ronellsalunke/bill_splitter_flutter'));
                      },
                    ),
                    SegmentedListTile(
                      leading: Icon(Icons.code, color: context.colorScheme.primary),
                      title: const Text('licenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.pushNamed('licenses');
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
