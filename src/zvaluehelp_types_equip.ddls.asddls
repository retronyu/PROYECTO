@EndUserText.label: 'Types Equipment dropdown'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZVALUEHELP_TYPES_EQUIP as select from zeqp_typ_catalog
{
    key equipment_type as EquipmentType,
    type_name as TypeName
  
}
