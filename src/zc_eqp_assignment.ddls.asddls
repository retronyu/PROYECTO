@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Equipment Assignment Projection View'
@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_EQP_Assignment as projection on ZIEQP_Assignment {
 key AssignmentUUID,
      EquipmentUUID,
      @Search.defaultSearchElement: true
      EmployeeID,
      AssignmentDate,
      ReturnDate,
      Location,
      Purpose,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      /* Associations */
      _Inventory : redirected to parent ZC_EQP_Inventory,
      _Employee
}
