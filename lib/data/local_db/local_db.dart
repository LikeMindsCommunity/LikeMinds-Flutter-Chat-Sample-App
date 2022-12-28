import 'package:group_chat_example/data/models/branding/branding.dart';

abstract class LocalDB {
  Future<BrandingEntity?> getSavedBranding();
  Future<void> saveBranding({required BrandingEntity branding});
}
