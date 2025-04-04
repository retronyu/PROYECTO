@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Equipment Inventory Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
 @Search.searchable: true
define  root view entity ZC_EQP_Inventory as projection on ZIEQP_Inventory
{
  key EquipmentUUID,
      @Search.defaultSearchElement: true
      EquipmentID,
      @Search.defaultSearchElement: true
      EquipmentName,
      EquipmentType,
      Status,
      StatusCriticality,
      Manufacturer,
      ModelNumber,
      SerialNumber,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      /* Associations */
      _Assignment : redirected to composition child ZC_EQP_Assignment,
      _Location   : redirected to composition child ZC_EQP_Location,
      _Maintenance : redirected to composition child ZC_EQP_Maintenance
}
