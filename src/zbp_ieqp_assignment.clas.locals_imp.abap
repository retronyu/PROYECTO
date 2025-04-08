CLASS lhc_Assignment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateUniqueAssignment FOR VALIDATE ON SAVE
      IMPORTING keys FOR Assignment~validateUniqueAssignment.
    METHODS resolveUUIDFromID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Assignment~resolveUUIDFromID.

ENDCLASS.

CLASS lhc_Assignment IMPLEMENTATION.

  METHOD validateUniqueAssignment.

READ ENTITIES OF ZIEQP_Inventory
  ENTITY Assignment
  FIELDS ( EquipmentUUID AssignmentUUID ReturnDate )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_assignment).


  loop at lt_assignment into DATA(ls_new).


  " verifica si hay otra asignacion activa (returndate vacio)

  SELECT count(*) from zeqp_assignment
    where equipment_uuid = @ls_new-EquipmentUUID
    AND assignment_uuid <> @ls_new-AssignmentUUID
        AND return_date IS INITIAL
      INTO @DATA(count_active).

      if count_active > 0.
    APPEND VALUE #( %tky = ls_new-%tky ) TO failed-assignment.

      APPEND VALUE #(
          %tky          = ls_new-%tky
          %state_area   = 'ASSIGNMENT_VALIDATION'
          %msg          = NEW zcm_message(
                            severity = if_abap_behv_message=>severity-error
                            textid   = zcm_message=>duplicate_assignment )
          %element-EquipmentUUID = if_abap_behv=>mk-on
        ) TO reported-assignment.
    ENDIF.

  ENDLOOP.

  ENDMETHOD.


  METHOD resolveUUIDFromID.
 DATA lt_modified TYPE TABLE FOR UPDATE ZIEQP_Assignment.


  READ ENTITIES OF ZIEQP_Inventory
    ENTITY Assignment
    FIELDS ( EquipmentID_Aux )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_assignments).




    LOOP AT lt_assignments INTO DATA(ls_assignment).

    SELECT SINGLE equipment_uuid
      FROM zeqp_inventory
      WHERE equipment_id = @ls_assignment-EquipmentID_Aux
      INTO @DATA(lv_uuid).

      IF sy-subrc = 0.
      APPEND VALUE #( %tky = ls_assignment-%tky
                      EquipmentUUID = lv_uuid ) TO lt_modified.

     ENDIF.


    ENDLOOP.

    MODIFY ENTITIES OF ZIEQP_Inventory IN LOCAL MODE
   ENTITY Assignment
      UPDATE
        FIELDS ( EquipmentUUID )
        WITH lt_modified

    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).







  ENDMETHOD.

ENDCLASS.
