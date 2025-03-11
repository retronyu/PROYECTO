
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Equipment Maintenance BO View'

define view entity ZIEQP_Maintenance as select from zeqp_maintenance
 association to parent ZIEQP_Inventory as _Inventory
    on $projection.EquipmentUUID = _Inventory.EquipmentUUID
{
key maintenance_uuid     as MaintenanceUUID,
      equipment_uuid      as EquipmentUUID,
      maintenance_id      as MaintenanceID,
      maintenance_date    as MaintenanceDate,
      maintenance_type    as MaintenanceType,
      technician_name     as TechnicianName,
      details            as Details,
      @Semantics.user.createdBy: true
      created_by         as CreatedBy,
      @Semantics.user.lastChangedBy: true
      last_changed_by    as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* association */
      _Inventory
}
