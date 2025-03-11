@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Equipment Location Projection View'
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_EQP_Location as projection on ZIEQP_Location {
key LocationUUID,
      EquipmentUUID,
      @Search.defaultSearchElement: true
      LocationID,
      LocationName,
      Building,
      Floor,
      Room,
      AssignedDate,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      /* Association */
      _Inventory : redirected to parent ZC_EQP_Inventory
}

