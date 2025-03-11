
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Equipment Maintenance Projection View'
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_EQP_Maintenance as projection on ZIEQP_Maintenance {
 key MaintenanceUUID,
      EquipmentUUID,
      @Search.defaultSearchElement: true
      MaintenanceID,
      MaintenanceDate,
      MaintenanceType,
      TechnicianName,
      Details,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      /* Association */
      _Inventory : redirected to parent ZC_EQP_Inventory
}
