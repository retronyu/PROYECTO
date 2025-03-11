
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Employee BO View'


define view entity ZI_HR_Employee as select from zhr_employee
{
key employee_uuid       as EmployeeUUID,
      employee_id         as EmployeeID,
      first_name         as FirstName,
      last_name          as LastName,
      department         as Department,
      email             as Email,
      phone_number      as PhoneNumber,
      hire_date         as HireDate,
      @Semantics.user.createdBy: true
      created_by        as CreatedBy,
      @Semantics.user.lastChangedBy: true
      last_changed_by   as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
