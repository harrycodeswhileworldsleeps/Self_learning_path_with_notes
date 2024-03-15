CLASS zcl_amdp_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.

    INTERFACES: if_amdp_marker_hdb. "marking this as an AMDP class as in , it can contain AMDP methods.

    TYPES: BEGIN OF ty_orders,
             vbeln TYPE vbak-vbeln,
             posnr TYPE vbap-posnr,
             bstnk TYPE vbak-bstnk,
             netwr TYPE vbap-netwr,
           END OF ty_orders.

    TYPES: lt_orders TYPE STANDARD TABLE OF ty_orders.

    METHODS: get_data_amdp
      IMPORTING
        VALUE(sales_docn) TYPE vbak-vbeln
      EXPORTING
        VALUE(it_orders)  TYPE lt_orders,

      get_data_abap
        IMPORTING
          sales_doc      TYPE vbak-vbeln
        EXPORTING
          lt_orders_abap TYPE lt_orders.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_amdp_test IMPLEMENTATION.


  METHOD get_data_amdp BY DATABASE PROCEDURE FOR HDB
                     LANGUAGE SQLSCRIPT
                     OPTIONS READ-ONLY
                     USING vbak vbap.
    declare lv_clnt nvarchar( 3 ) := session_context('CLIENT');

    it_temp = SELECT * FROM vbak;

    it_orders = SELECT a.vbeln, b.posnr, a.bstnk, b.netwr
                FROM :it_temp as a INNER JOIN vbap as b
                ON a.vbeln = b.vbeln
                WHERE a.vbeln = sales_docn
                AND a.mandt = lv_clnt
                AND b.mandt = lv_clnt;
  ENDMETHOD.

  METHOD get_data_abap.
  DATA: it_final TYPE STANDARD TABLE OF VBAK WITH KEY mandt vbeln.
  SELECT * FROM vbak INTO table it_final.
  SELECT a~vbeln ,
         b~posnr ,
         a~bstnk ,
         b~netwr
         FROM @it_final as a inner join vbap as b
         ON a~vbeln = b~vbeln
         WHERE a~vbeln = @sales_doc
         INTO CORRESPONDING FIELDS OF TABLE @lt_orders_abap.
  ENDMETHOD.


ENDCLASS.
