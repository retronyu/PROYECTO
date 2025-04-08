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

      METHODS is_create_granted
    RETURNING VALUE(create_granted) TYPE abap_bool.

  METHODS is_update_granted
    IMPORTING has_before_image TYPE abap_bool
              status            TYPE zstatus_eqp
    RETURNING VALUE(update_granted) TYPE abap_bool.

  METHODS is_delete_granted
    IMPORTING has_before_image TYPE abap_bool
              status            TYPE zstatus_eqp
    RETURNING VALUE(delete_granted) TYPE abap_bool.


ENDCLASS.

CLASS lhc_Inventory IMPLEMENTATION.

  METHOD get_instance_authorizations.
DATA: has_before_image      TYPE abap_bool,
        is_update_requested   TYPE abap_bool,
        is_delete_requested   TYPE abap_bool,
        update_granted        TYPE abap_bool,
        delete_granted        TYPE abap_bool.

  " Leer los estados actuales desde la base activa
  READ ENTITIES OF ZIEQP_Inventory IN LOCAL MODE
    ENTITY Inventory
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(equipment_list)
    FAILED failed.

  IF equipment_list IS INITIAL.
    RETURN.
  ENDIF.

  " Leer imágenes previas de base activa
  SELECT FROM zeqp_inventory
    FIELDS equipment_uuid, status
    FOR ALL ENTRIES IN @equipment_list
    WHERE equipment_uuid = @equipment_list-equipmentuuid
    INTO TABLE @DATA(before_images).

  is_update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on THEN abap_true ELSE abap_false ).
  is_delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on THEN abap_true ELSE abap_false ).

  LOOP AT equipment_list INTO DATA(equipment).

    READ TABLE before_images INTO DATA(before_image)
      WITH KEY equipment_uuid = equipment-EquipmentUUID BINARY SEARCH.

    has_before_image = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

    IF is_update_requested = abap_true.
      IF has_before_image = abap_true.
        update_granted = is_update_granted( has_before_image = abap_true status = before_image-status ).
      ELSE.
        update_granted = is_create_granted( ).
      ENDIF.
    ENDIF.

    IF is_delete_requested = abap_true.
      delete_granted = is_delete_granted( has_before_image = has_before_image status = before_image-status ).
    ENDIF.

    APPEND VALUE #(
      %tky     = equipment-%tky
      %update  = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
      %delete  = COND #( WHEN delete_granted = abap_true THEN if_abap_behv=>auth-allowed ELSE if_abap_behv=>auth-unauthorized )
    ) TO result.

  ENDLOOP.

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

  READ ENTITIES OF ZIEQP_Inventory IN LOCAL MODE
    ENTITY Inventory
    FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(equipment_list).

  result = VALUE #(
    FOR equipment IN equipment_list
      LET is_mark_allowed = COND #(
        WHEN equipment-Status = equip_status-mantenimiento
        THEN if_abap_behv=>fc-o-disabled
        ELSE if_abap_behv=>fc-o-enabled )
      IN
      (
        %tky = equipment-%tky
        %action-MarcarReparacion = is_mark_allowed
      )
  ).

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



  METHOD is_create_granted.
 create_granted = abap_true. " Simulación
  ENDMETHOD.

  METHOD is_delete_granted.
   delete_granted = abap_true. " Simulación

  ENDMETHOD.

  METHOD is_update_granted.
  update_granted = abap_true. " Simulación
  ENDMETHOD.

ENDCLASS.
