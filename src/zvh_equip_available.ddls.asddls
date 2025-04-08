@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help - Equipos Disponibles'
define view entity ZVH_EQUIP_AVAILABLE
  as select from zeqp_inventory
{
    key equipment_uuid  as EquipmentUUID,
        equipment_id    as EquipmentID,
        equipment_name  as EquipmentName,
        model_number    as ModelNumber
}
where status = 'DSP'
