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

ENDCLASS.

CLASS lhc_Inventory IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD validartype.
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
  ENDMETHOD.

ENDCLASS.
