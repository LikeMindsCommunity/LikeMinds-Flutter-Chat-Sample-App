// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../utils/ui_utils.dart';

part 'branding_advanced.g.dart';

class BrandingAdvanced {
  final Color? headerColor;
  final Color? buttonIconsColor;
  final Color? textLinksColor;

  BrandingAdvanced(
      {this.buttonIconsColor, this.headerColor, this.textLinksColor});

  factory BrandingAdvanced.fromEntity(BrandingAdvancedEntity entity) {
    return BrandingAdvanced(
        buttonIconsColor: entity.buttonIconsColor?.toColor(),
        headerColor: entity.headerColor?.toColor(),
        textLinksColor: entity.textLinksColor?.toColor());
  }

  BrandingAdvancedEntity toEntity() {
    return BrandingAdvancedEntity(
        headerColor: headerColor?.value.toString(),
        buttonIconsColor: buttonIconsColor?.value.toString(),
        textLinksColor: textLinksColor?.value.toString());
  }
}

@HiveType(typeId: 3)
@JsonSerializable()
class BrandingAdvancedEntity extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'header_colour')
  final String? headerColor;

  @HiveField(1)
  @JsonKey(name: 'button_icons_colour')
  final String? buttonIconsColor;

  @HiveField(2)
  @JsonKey(name: 'text_links_colour')
  final String? textLinksColor;
  BrandingAdvancedEntity({
    this.headerColor,
    this.buttonIconsColor,
    this.textLinksColor,
  });
  Map<String, dynamic> toJson() => _$BrandingAdvancedEntityToJson(this);
  factory BrandingAdvancedEntity.fromJson(Map<String, dynamic> data) =>
      _$BrandingAdvancedEntityFromJson(data);
}
