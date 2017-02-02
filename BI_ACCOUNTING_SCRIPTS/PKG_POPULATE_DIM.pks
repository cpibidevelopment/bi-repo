CREATE OR REPLACE PACKAGE BIADMIN.PKG_POPULATE_DIM
IS
   /************************************************************
    Date Created: August 14, 2015
    Developer: Edward
    Description: This package constains procedures that will populate
    the dimension table before transformation.            
   **************************************************************/
    v_time_def_range NUMBER DEFAULT 1000;         
    PROCEDURE main(p_exclude_time NUMBER DEFAULT NULL);
    PROCEDURE gen_assured_dim;
    PROCEDURE gen_agent_dim;
    PROCEDURE gen_policy_dim;
    PROCEDURE gen_vehicle_dtl_dim;
    PROCEDURE gen_motor_car_dtl_dim;
    PROCEDURE gen_clm_statgrp_dim;
    PROCEDURE gen_clm_fire_item_dim;
    PROCEDURE gen_branch_dim;
END; 
/

