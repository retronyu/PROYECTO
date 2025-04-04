@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Equipment Inventory'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIEQP_Inventory as select from zeqp_inventory
composition [0..*] of ZIEQP_Assignment as _Assignment
  composition [0..*] of ZIEQP_Location as _Location
  composition [0..*] of ZIEQP_Maintenance as _Maintenance
{
   key equipment_uuid        as EquipmentUUID,
      equipment_id          as EquipmentID,
      equipment_name        as EquipmentName,
      equipment_type        as EquipmentType,
      status               as Status,
      case status
        when 'DSP' then 3 -- Disponible = Positivo (Verde)
        when 'MNT' then 2 -- Mantenimiento = Crítico/Advertencia (Naranja/Amarillo)
        when 'INC' then 1 -- Inactivo = Negativo (Rojo)
        else 0          -- Cualquier otro caso = Neutral (Sin color)
      end as StatusCriticality,
      manufacturer         as Manufacturer,
      model_number        as ModelNumber,
      serial_number       as SerialNumber,
      @Semantics.user.createdBy: true
      created_by           as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at           as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by      as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at      as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* compositions */
      _Assignment,
      _Location,
      _Maintenance
}
