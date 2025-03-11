@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Equipment Assignment BO View'


define view entity ZIEQP_Assignment
  as select from zeqp_assignment
  association to parent ZIEQP_Inventory as _Inventory on $projection.EquipmentUUID = _Inventory.EquipmentUUID
association [0..1] to ZI_HR_Employee as _Employee on $projection.EmployeeID = _Employee.EmployeeID
{
  key assignment_uuid       as AssignmentUUID,
      equipment_uuid        as EquipmentUUID,
      employee_id           as EmployeeID,
      assignment_date       as AssignmentDate,
      return_date           as ReturnDate,
      location              as Location,
      purpose               as Purpose,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* associations */
      _Inventory,
      _Employee
}
