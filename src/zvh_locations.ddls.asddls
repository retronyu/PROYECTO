@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Locations'
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZVH_LOCATIONS
  as select distinct from zeqp_location
{
// location_uuid as LocationUuid,
//equipment_uuid as EquipmentUuid,
key location_id as LocationID,
location_name as LocationName,
building as Building,
floor as Floor,
room as Room

  
    
}
