
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Equipment Location BO View'


define view entity ZIEQP_Location as select from zeqp_location
association to parent ZIEQP_Inventory as _Inventory
    on $projection.EquipmentUUID= _Inventory.EquipmentUUID
{
 key location_uuid        as LocationUUID,
      equipment_uuid       as EquipmentUUID,
      location_id          as LocationID,
      location_name        as LocationName,
      building            as Building,
      floor               as Floor,
      room                as Room,
      assigned_date       as AssignedDate,
      @Semantics.user.createdBy: true
      created_by          as CreatedBy,
      @Semantics.user.lastChangedBy: true
      last_changed_by     as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* association */
      _Inventory
}
