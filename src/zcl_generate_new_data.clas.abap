CLASS zcl_generate_new_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS: c_max_records TYPE i VALUE 10.
    METHODS: insert_locations IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      insert_employees IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      insert_equipments IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      insert_assignments IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      insert_maintenances IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      generate_random_date RETURNING VALUE(rv_date) TYPE d,
      generate_random_timestampl RETURNING VALUE(rv_date) TYPE timestampl,
      ejecutar IMPORTING out TYPE REF TO if_oo_adt_classrun_out,
      clear_tables IMPORTING out TYPE REF TO if_oo_adt_classrun_out ,
      add_types IMPORTING out TYPE REF TO if_oo_adt_classrun_out .
    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_generate_new_data IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    ejecutar( out ).
  ENDMETHOD.

  METHOD ejecutar.
    out->write( 'Ejecutando carga de datos...' ).
    clear_tables( out ).
    insert_equipments( out ).
    insert_employees( out ).
    insert_locations( out ).
    insert_assignments( out ).
    insert_maintenances( out ).
    add_types( out ).
    out->write( 'Carga de datos completada con éxito.' ).
  ENDMETHOD.

  METHOD clear_tables.
    DELETE FROM zeqp_maintenance.
    DELETE FROM zeqp_assignment.
    DELETE FROM zeqp_inventory.
    DELETE FROM zhr_employee.
    DELETE FROM zeqp_location.
    DELETE FROM zeqp_typ_catalog.

    out->write( 'Tablas limpiadas correctamente.' ).
  ENDMETHOD.

  METHOD insert_locations.
    DATA: itab_locations TYPE TABLE OF zeqp_location,
          wa_location    TYPE zeqp_location,
          lv_index       TYPE i,
          lt_equipments  TYPE TABLE OF zeqp_inventory-equipment_uuid.


    " Obtener lista de equipos disponibles
    SELECT equipment_uuid FROM zeqp_inventory INTO TABLE @lt_equipments.

    DO 5 TIMES.
      lv_index = sy-index.
      wa_location-location_uuid = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( ).
      wa_location-location_id   = |LOC{ lv_index WIDTH = 3 PAD = '0' }|.
      wa_location-location_name = |Ubicación { lv_index }|.
      wa_location-building      = |Edificio { lv_index }|.
      wa_location-floor         = lv_index MOD 5 + 1.
      wa_location-room          = |R{ lv_index WIDTH = 2 PAD = '0' }|.
      wa_location-assigned_date = generate_random_date( ).
      wa_location-equipment_uuid = lt_equipments[ lv_index MOD lines( lt_equipments ) + 1 ].
      APPEND wa_location TO itab_locations.
    ENDDO.

    INSERT zeqp_location FROM TABLE @itab_locations.
    COMMIT WORK.
    out->write( 'Carga exitosa de ubicaciones.' ).
  ENDMETHOD.

  METHOD insert_employees.
    DATA: itab_employees TYPE TABLE OF zrh_employee,
          wa_employee    TYPE zrh_employee,
          lv_index       TYPE i.

    DO 5 TIMES.
      lv_index = sy-index.
      wa_employee-employee_uuid = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( ).
      wa_employee-employee_id   = |EMP{ lv_index WIDTH = 3 PAD = '0' }|.
      wa_employee-first_name    = |Empleado { lv_index }|.
      wa_employee-last_name     = |Apellido { lv_index }|.
      wa_employee-department    = |Departamento { lv_index MOD 3 + 1 }|.
      wa_employee-email         = |empleado{ lv_index }@empresa.com|.
      wa_employee-phone_number  = |600{ lv_index WIDTH = 3 PAD = '0' }|.
      wa_employee-hire_date     = generate_random_date( ).
      APPEND wa_employee TO itab_employees.
    ENDDO.

    INSERT zrh_employee FROM TABLE @itab_employees.
    COMMIT WORK.
    out->write( 'Carga exitosa de empleados.' ).
  ENDMETHOD.

  METHOD insert_equipments.
    DATA: itab_equipments TYPE TABLE OF zeqp_inventory,
          wa_equipment    TYPE zeqp_inventory,
          lv_index        TYPE i.

    DO 5 TIMES.
      lv_index = sy-index.
      DATA(lv_num) = lv_index MOD 3 .
      DATA zstatus TYPE string.

      CASE lv_num.
        WHEN 0 .
          zstatus ='ACT'.
        WHEN 1 .
          zstatus ='MNT'.
        WHEN OTHERS .
          zstatus ='INA'.
      ENDCASE.

      wa_equipment-equipment_uuid = cl_system_uuid=>if_system_uuid_static~create_uuid_x16( ).
      wa_equipment-equipment_id   = |EQP{ lv_index WIDTH = 3 PAD = '0' }|.
      wa_equipment-equipment_name = |Equipo { lv_index }|.
      wa_equipment-equipment_type = |Tipo { lv_index MOD 3 + 1 }|.
      wa_equipment-status = zstatus .
      wa_equipment-manufacturer   = |Fabricante { lv_index }|.
      wa_equipment-model_number   = |Modelo { lv_index }|.
      wa_equipment-serial_number  = |SN-{ lv_index WIDTH = 5 PAD = '0' }|.
      wa_equipment-created_at     = generate_random_timestampl( ).
      APPEND wa_equipment TO itab_equipments.
    ENDDO.

    INSERT zeqp_inventory FROM TABLE @itab_equipments.
    COMMIT WORK.
    out->write( 'Carga exitosa de equipos.' ).
  ENDMETHOD.

  METHOD generate_random_date.
    DATA: lv_days_offset TYPE i.
    lv_days_offset = ( sy-index * 3 ) MOD 365.
    rv_date = sy-datum - lv_days_offset.
  ENDMETHOD.

  METHOD generate_random_timestampl.
    DATA: lv_days_offset TYPE i,
          lv_timestamp   TYPE timestampl,
          lt_changed_at  TYPE TABLE OF zrap_abook_gp-local_last_changed_at.

    SELECT local_last_changed_at FROM zrap_abook_gp INTO TABLE @lt_changed_at.

    DATA(lv_random_index) = cl_abap_random_int=>create( min = 1 max = lines( lt_changed_at ) )->get_next( ).

    DATA(lv_random_value) =  lt_changed_at[ lv_random_index ].



    rv_date = lv_random_value.
  ENDMETHOD.



  METHOD insert_assignments.
    DATA: itab_assignments TYPE TABLE OF zeqp_assignment,
          wa_assignment    TYPE zeqp_assignment,
          lv_index         TYPE i,
          lt_equipments    TYPE TABLE OF zeqp_inventory-equipment_uuid,
          lt_employees     TYPE TABLE OF zrh_employee-employee_id.

    " Obtener listas de equipos y empleados
    SELECT equipment_uuid FROM zeqp_inventory INTO TABLE @lt_equipments.
    SELECT employee_id FROM zrh_employee INTO TABLE @lt_employees.

    DO 5 TIMES.
      lv_index = sy-index.
      wa_assignment-assignment_uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).

      " Obtener un equipo aleatorio
      DATA(lv_equipment_uuid) = lt_equipments[ lv_index - 1 MOD lines( lt_equipments ) + 1 ].
      wa_assignment-equipment_uuid = lv_equipment_uuid.

      " Obtener un empleado aleatorio
      DATA(lv_employee_id) = lt_employees[ lv_index MOD lines( lt_employees   )  ].
      wa_assignment-employee_id = lv_employee_id.

      wa_assignment-assignment_date = generate_random_date( ).
      wa_assignment-return_date     = wa_assignment-assignment_date + 180.
      wa_assignment-location        = |Ubicación { lv_index }|.
      wa_assignment-purpose         = |Asignación { lv_index }|.
      APPEND wa_assignment TO itab_assignments.
    ENDDO.

    INSERT zeqp_assignment FROM TABLE @itab_assignments.
    out->write( 'Carga exitosa de asignaciones.' ).
  ENDMETHOD.
  METHOD insert_maintenances.
    DATA: itab_maintenances TYPE TABLE OF zeqp_maintenance,
          wa_maintenance    TYPE zeqp_maintenance,
          lv_index          TYPE i,
          lt_equipments_mnt TYPE TABLE OF zeqp_inventory-equipment_uuid.

    " Obtener lista de equipos disponibles
    SELECT equipment_uuid FROM zeqp_inventory INTO TABLE @lt_equipments_mnt.

    DO 5 TIMES.
      lv_index = sy-index.
      wa_maintenance-maintenance_uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).

      " Obtener un equipo aleatorio
      DATA(lv_equipment_uuid_mnt) = lt_equipments_mnt[ lv_index - 1 MOD lines( lt_equipments_mnt ) + 1 ].
      wa_maintenance-equipment_uuid = lv_equipment_uuid_mnt.

      wa_maintenance-maintenance_id   = |MTN{ lv_index WIDTH = 3 PAD = '0' }|.
      wa_maintenance-maintenance_date = generate_random_date( ).
      wa_maintenance-maintenance_type = |Tipo { lv_index MOD 3 + 1 }|.
      wa_maintenance-technician_name  = |Técnico { lv_index }|.
      wa_maintenance-details          = |Mantenimiento { lv_index }|.
      APPEND wa_maintenance TO itab_maintenances.
    ENDDO.

    INSERT zeqp_maintenance FROM TABLE @itab_maintenances.
    out->write( 'Carga exitosa de mantenimientos.' ).
  ENDMETHOD.
  METHOD add_types.
    DATA: lt_types     TYPE STANDARD TABLE OF zeqp_typ_catalog,
          wa_type      TYPE zeqp_typ_catalog,
          lv_timestamp TYPE timestampl.
    GET TIME STAMP FIELD lv_timestamp.

    " Llenar tipos de equipo
    wa_type-client = sy-mandt.
    wa_type-created_by = sy-uname.
    wa_type-created_at = lv_timestamp.

    wa_type-equipment_type = 'LAPTOP'.
    wa_type-type_name      = 'Laptop'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'MONITOR'.
    wa_type-type_name      = 'Monitor'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'MOUSE'.
    wa_type-type_name      = 'Mouse'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'KEYBOARD'.
    wa_type-type_name      = 'Keyboard'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'PRINTER'.
    wa_type-type_name      = 'Printer'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'SCANNER'.
    wa_type-type_name      = 'Scanner'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'PROJECTOR'.
    wa_type-type_name      = 'Projector'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'HEADSET'.
    wa_type-type_name      = 'Headset'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'WEBCAM'.
    wa_type-type_name      = 'Webcam'.
    APPEND wa_type TO lt_types.

    wa_type-equipment_type = 'TABLET'.
    wa_type-type_name      = 'Tablet'.
    APPEND wa_type TO lt_types.

    " Insertar registros
    INSERT zeqp_typ_catalog FROM TABLE @lt_types.

    IF sy-subrc EQ 0.

      COMMIT WORK.
      out->write( 'Carga exitosa de Tipos de equipos.' ).

    ENDIF.

  ENDMETHOD.



ENDCLASS.
