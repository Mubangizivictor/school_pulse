import 'package:equatable/equatable.dart';

/// School-wide communication policy defaults - a singleton document, like
/// TimetableConfig. Channel ids match what's actually implemented
/// (`app`); unimplemented channels aren't persisted as enabled since
/// nothing sends through them yet.
class CommunicationDefaultsConfig extends Equatable {
  final List<String> defaultChannels;
  final String defaultLanguage;

  const CommunicationDefaultsConfig({
    this.defaultChannels = const ['app'],
    this.defaultLanguage = 'English',
  });

  CommunicationDefaultsConfig copyWith({
    List<String>? defaultChannels,
    String? defaultLanguage,
  }) {
    return CommunicationDefaultsConfig(
      defaultChannels: defaultChannels ?? this.defaultChannels,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
    );
  }

  @override
  List<Object?> get props => [defaultChannels, defaultLanguage];
}
