CLASS lhc_Inventory DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
  CONSTANTS:
      BEGIN OF equip_status,
      MANTENIMIENTO TYPE c LENGTH 15 value 'MNT',
        DISPONIBLE TYPE c LENGTH 15 value 'DSP',
        INACTIVO TYPE c LENGTH 15 value 'INC',
        END OF equip_status .

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Inventory RESULT result.



    METHODS validartype FOR VALIDATE ON SAVE
      IMPORTING keys FOR Inventory~validartype.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Inventory RESULT result.

    METHODS MarcarReparacion FOR MODIFY
      IMPORTING keys FOR ACTION Inventory~MarcarReparacion RESULT result.

    METHODS setInitialID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Inventory~setInitialID.
    METHODS calculateid FOR MODIFY
      IMPORTING keys FOR ACTION Inventory~calculateid.


ENDCLASS.

CLASS lhc_Inventory IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD validartype.

   READ ENTITIES OF ZIEQP_Inventory
   ENTITY Inventory
   FIELDS ( EquipmentType ) WITH CORRESPONDING #( keys )
   RESULT data(inventoris).

   loop at inventoris into data(invent_type).

   select count( * ) from zeqp_typ_catalog
   where equipment_type = @invent_type-EquipmentType
   into @data(type_count).

   if type_count eq 0.

   APPEND VALUE #( %tky          = invent_type-%tky
                      %state_area   = 'VALIDATE_TYPE' )
        TO reported-inventory.

      APPEND VALUE #( %tky          = invent_type-%tky
                      %state_area   = 'VALIDATE_TYPE'
                      %msg          = NEW zcm_message(
                                          severity = if_abap_behv_message=>severity-error
                                          textid = zcm_message=>type_check )
                      %element-EquipmentType = if_abap_behv=>mk-on )
        TO reported-inventory.
   ENDIF.

   ENDLOOP.





  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD MarcarReparacion.

  MODIFY ENTITIES OF ZIEQP_Inventory
  ENTITY Inventory
   UPDATE
   FIELDS ( Status )
   WITH VALUE #( for key in keys
   ( %tky = key-%tky
   Status = equip_status-mantenimiento  )    )
   FAILED failed
   REPORTED reported.

   READ ENTITIES OF ZIEQP_Inventory
   ENTITY Inventory
   ALL FIELDS WITH CORRESPONDING #( keys )
   RESULT data(inventoris).


   result =  VALUE #( for inventori in inventoris
   ( %tky = inventori-%tky
     %param = inventori
    )   ).

  ENDMETHOD.

  METHOD setInitialID.



  READ ENTITIES OF ZIEQP_Inventory IN LOCAL MODE
      ENTITY Inventory
        FIELDS ( Status  EquipmentID ) WITH CORRESPONDING #( keys )
      RESULT DATA(inven_status).

    " Remove all travel instance data with defined status

    CHECK inven_status IS NOT INITIAL.

      SELECT MAX( equipment_id ) FROM zeqp_inventory INTO @DATA(max_id).
IF max_id IS INITIAL.
  max_id = 'EQP000'.
ENDIF.

" Extraer número (suponiendo formato EQP###)
DATA(numeric_part) = max_id+3(3). " 3 caracteres a partir de la posición 3
DATA(next_number) = CONV i( numeric_part ) + 1.

" Reconstruir el nuevo ID con ceros a la izquierda
DATA(new_id) = |EQP{ next_number WIDTH = 3 PAD = '0'  }|.


    " Set default travel status
    MODIFY ENTITIES OF ZIEQP_Inventory IN LOCAL MODE
   ENTITY Inventory
      UPDATE
        FIELDS ( EquipmentID Status )
        WITH VALUE #( FOR key in keys
                      ( %tky = key-%tky
                        EquipmentID = new_id
                        Status = equip_status-disponible

                        ) )

    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).





  ENDMETHOD.

  METHOD calculateid.


*   SELECT MAX( equipment_id ) FROM zeqp_inventory INTO @DATA(max_id).
*IF max_id IS INITIAL.
*  max_id = 'EQP000'.
*ENDIF.
*
*" Extraer número (suponiendo formato EQP###)
*DATA(numeric_part) = max_id+3(3). " 3 caracteres a partir de la posición 3
*DATA(next_number) = CONV i( numeric_part ) + 1.
*
*" Reconstruir el nuevo ID con ceros a la izquierda
*DATA(new_id) = |EQP{ next_number WIDTH = 3 PAD = '0'  }|.
*
*
*    " Set default travel status
*    MODIFY ENTITIES OF ZIEQP_Inventory IN LOCAL MODE
*   ENTITY Inventory
*      UPDATE
*        FIELDS ( EquipmentID Status )
*        WITH VALUE #( FOR key in keys
*                      ( %tky = key-%tky
*                        EquipmentID = new_id
*                        Status = equip_status-disponible
*
*                        ) )
*
*    REPORTED DATA(update_reported).
*
*    reported = CORRESPONDING #( DEEP update_reported ).
*


  ENDMETHOD.



ENDCLASS.
