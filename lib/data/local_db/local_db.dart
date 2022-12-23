import '../models/branding/branding.dart';

abstract class LocalDB {
  Future<BrandingEntity?> getSavedBranding();
  Future<void> saveBranding({required BrandingEntity branding});
}
