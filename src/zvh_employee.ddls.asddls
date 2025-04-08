@EndUserText.label: 'Value Help - Empleados'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZVH_EMPLOYEE
  as select from zrh_employee
  {
key employee_id    as EmployeeID,
      first_name     as FirstName,
      last_name      as LastName,
      department     as Department
}
