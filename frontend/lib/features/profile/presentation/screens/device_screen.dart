import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view_builder.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class DeviceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.devices,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildDeviceView(context, state);
          } else if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
                child: Text(AppLocalizations.of(context)!.failedToLoadProfile));
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String deviceId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.confirmDeletion,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.confirmDeletionQuestion),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      BlocProvider.of<ProfileBloc>(context)
                          .add(DeleteDeviceEvent(deviceId: deviceId));
                      Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceView(BuildContext context, ProfileAuthenticated state) {
    if (state.devices.isNotEmpty) {
      return FullWidthListViewBuilder(
        itemCount: state.devices.length,
        itemBuilder: (context, index) {
          final device = state.devices[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: ListTile(
              title: Text(
                AppLocalizations.of(context)!.deviceInfo(
                  device.parsedDeviceInfo.isMobile?.toString() ?? "null",
                  device.parsedDeviceInfo.os ?? "null",
                  device.parsedDeviceInfo.browser ?? "null",
                  device.parsedDeviceInfo.model ?? "null",
                ),
              ),
              subtitle: Text(
                "${AppLocalizations.of(context)!.lastActivityDate} ${device.lastActivityDate != null ? DateFormat.yMMMMEEEEd(state.profile.locale).add_Hm().format(device.lastActivityDate!) : AppLocalizations.of(context)!.unknown}",
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(context, device.tokenId),
              ),
            ),
          );
        },
      );
    } else {
      return Center(child: Text(AppLocalizations.of(context)!.noDevices));
    }
  }
}
