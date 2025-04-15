CLASS lhc_Assignment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    METHODS validateAssignmentLocaMatch FOR VALIDATE ON SAVE
      IMPORTING keys FOR Assignment~validateAssignmentLocaMatch.

ENDCLASS.

CLASS lhc_Assignment IMPLEMENTATION.





  METHOD validateAssignmentLocaMatch.

  READ ENTITIES OF ZIEQP_Inventory
  ENTITY Assignment
  FIELDS ( EquipmentUUID Location )
  WITH CORRESPONDING #( KEYS )
  RESULT DATA(assignments).

   SELECT equipment_uuid , location_id
    FROM zeqp_location
    FOR ALL ENTRIES IN @assignments
    WHERE equipment_uuid = @assignments-EquipmentUUID
    INTO TABLE @DATA(current_locations).

  loop at assignments into data(assignment).

  READ TABLE current_locations INTO DATA(current_location)
      WITH KEY Equipment_UUID = assignment-EquipmentUUID.

   IF sy-subrc = 0 AND assignment-Location <> current_location-location_id.

      APPEND VALUE #(
        %tky        = assignment-%tky
        %msg        = NEW zcm_message(
                        severity = if_abap_behv_message=>severity-error
                        textid   = zcm_message=>location_mismatch )
        %element-Location = if_abap_behv=>mk-on
      ) TO reported-assignment.
   ENDIF.



  ENDLOOP.


  ENDMETHOD.

ENDCLASS.
