------------------------------------------------------------------------------
-- Licensed Materials - Property of IBM
--
-- (C) COPYRIGHT International Business Machines Corp. 2014
-- All Rights Reserved.
--
-- US Government Users Restricted Rights - Use, duplication or
-- disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
------------------------------------------------------------------------------

drop table if exists call_center;
create table call_center
(
    cc_call_center_sk         int,
    cc_call_center_id         varchar(250),
    cc_rec_start_date         varchar(250),
    cc_rec_end_date           varchar(250),
    cc_closed_date_sk         int,
    cc_open_date_sk           int,
    cc_name                   varchar(250),
    cc_class                  varchar(250),
    cc_employees              int,
    cc_sq_ft                  int,
    cc_hours                  varchar(250),
    cc_manager                varchar(250),
    cc_mkt_id                 int,
    cc_mkt_class              varchar(250),
    cc_mkt_desc               varchar(250),
    cc_market_manager         varchar(250),
    cc_division               int,
    cc_division_name          varchar(250),
    cc_company                int,
    cc_company_name           varchar(250),
    cc_street_number          varchar(250),
    cc_street_name            varchar(250),
    cc_street_type            varchar(250),
    cc_suite_number           varchar(250),
    cc_city                   varchar(250),
    cc_county                 varchar(250),
    cc_state                  varchar(250),
    cc_zip                    varchar(250),
    cc_country                varchar(250),
    cc_gmt_offset             double precision,
    cc_tax_percentage         double precision
);
COPY call_center FROM PROGRAM 'cat /tmp/tpcds_data/data/call_center.dat' DELIMITERS '|' CSV;
-- drop table if exists call_center;
-- create table call_center 
-- using parquet
-- as (select * from call_center )
-- ;
-- drop table if exists call_center ;

drop table if exists catalog_page;
create table catalog_page
(
    cp_catalog_page_sk        int,
    cp_catalog_page_id        varchar(250),
    cp_start_date_sk          int,
    cp_end_date_sk            int,
    cp_department             varchar(250),
    cp_catalog_number         int,
    cp_catalog_page_number    int,
    cp_description            varchar(250),
    cp_type                   varchar(250)
);
COPY catalog_page FROM PROGRAM 'cat /tmp/tpcds_data/data/catalog_page.dat' DELIMITERS '|' CSV;


drop table if exists catalog_returns ;
create table catalog_returns 
(
    cr_returned_date_sk       int,
    cr_returned_time_sk       int,
    cr_item_sk                int,
    cr_refunded_customer_sk   int,
    cr_refunded_cdemo_sk      int,
    cr_refunded_hdemo_sk      int,
    cr_refunded_addr_sk       int,
    cr_returning_customer_sk  int,
    cr_returning_cdemo_sk     int,
    cr_returning_hdemo_sk     int,
    cr_returning_addr_sk      int,
    cr_call_center_sk         int,
    cr_catalog_page_sk        int,
    cr_ship_mode_sk           int,
    cr_warehouse_sk           int,
    cr_reason_sk              int,
    cr_order_number           int,
    cr_return_quantity        int,
    cr_return_amount          double precision,
    cr_return_tax             double precision,
    cr_return_amt_inc_tax     double precision,
    cr_fee                    double precision,
    cr_return_ship_cost       double precision,
    cr_refunded_cash          double precision,
    cr_reversed_charge        double precision,
    cr_store_credit           double precision,
    cr_net_loss               double precision
);
COPY catalog_returns FROM PROGRAM 'cat /tmp/tpcds_data/data/catalog_returns.dat' DELIMITERS '|' CSV;


drop table if exists catalog_sales;
create table catalog_sales 
(
    cs_sold_date_sk           int,
    cs_sold_time_sk           int,
    cs_ship_date_sk           int,
    cs_bill_customer_sk       int,
    cs_bill_cdemo_sk          int,
    cs_bill_hdemo_sk          int,
    cs_bill_addr_sk           int,
    cs_ship_customer_sk       int,
    cs_ship_cdemo_sk          int,
    cs_ship_hdemo_sk          int,
    cs_ship_addr_sk           int,
    cs_call_center_sk         int,
    cs_catalog_page_sk        int,
    cs_ship_mode_sk           int,
    cs_warehouse_sk           int,
    cs_item_sk                int,
    cs_promo_sk               int,
    cs_order_number           int,
    cs_quantity               int,
    cs_wholesale_cost         double precision,
    cs_list_price             double precision,
    cs_sales_price            double precision,
    cs_ext_discount_amt       double precision,
    cs_ext_sales_price        double precision,
    cs_ext_wholesale_cost     double precision,
    cs_ext_list_price         double precision,
    cs_ext_tax                double precision,
    cs_coupon_amt             double precision,
    cs_ext_ship_cost          double precision,
    cs_net_paid               double precision,
    cs_net_paid_inc_tax       double precision,
    cs_net_paid_inc_ship      double precision,
    cs_net_paid_inc_ship_tax  double precision,
    cs_net_profit             double precision
);
COPY catalog_sales FROM PROGRAM 'cat /tmp/tpcds_data/data/catalog_sales_part*.dat' DELIMITERS '|' CSV;


drop table if exists customer_address ;
create table customer_address 
(
    ca_address_sk             int not null,
    ca_address_id             varchar(250) not null,
    ca_street_number          varchar(250),
    ca_street_name            varchar(250),
    ca_street_type            varchar(250),
    ca_suite_number           varchar(250),
    ca_city                   varchar(250),
    ca_county                 varchar(250),
    ca_state                  varchar(250),
    ca_zip                    varchar(250),
    ca_country                varchar(250),
    ca_gmt_offset             double precision,
    ca_location_type          varchar(250),
    primary key(ca_address_sk)
);
COPY customer_address FROM PROGRAM 'cat /tmp/tpcds_data/data/customer_address.dat' DELIMITERS '|' CSV;


drop table if exists customer_demographics ;
create table customer_demographics 
(
    cd_demo_sk                int not null,
    cd_gender                 varchar(250),
    cd_marital_status         varchar(250),
    cd_education_status       varchar(250),
    cd_purchase_estimate      int,
    cd_credit_rating          varchar(250),
    cd_dep_count              int,
    cd_dep_employed_count     int,
    cd_dep_college_count      int,
    primary key(cd_demo_sk)
);
COPY customer_demographics FROM PROGRAM 'cat /tmp/tpcds_data/data/customer_demographics_part*.dat' DELIMITERS '|' CSV;

drop table if exists date_dim ;
create table date_dim 
(
    d_date_sk                 int not null,
    d_date_id                 varchar(250) not null,
    d_date                    varchar(250) not null,
    d_month_seq               int,
    d_week_seq                int,
    d_quarter_seq             int,
    d_year                    int,
    d_dow                     int,
    d_moy                     int,
    d_dom                     int,
    d_qoy                     int,
    d_fy_year                 int,
    d_fy_quarter_seq          int,
    d_fy_week_seq             int,
    d_day_name                varchar(250),
    d_quarter_name            varchar(250),
    d_holiday                 varchar(250),
    d_weekend                 varchar(250),
    d_following_holiday       varchar(250),
    d_first_dom               int,
    d_last_dom                int,
    d_same_day_ly             int,
    d_same_day_lq             int,
    d_current_day             varchar(250),
    d_current_week            varchar(250),
    d_current_month           varchar(250),
    d_current_quarter         varchar(250),
    d_current_year            varchar(250),
    primary key(d_date_sk)
);
COPY date_dim FROM PROGRAM 'cat /tmp/tpcds_data/data/date_dim.dat' DELIMITERS '|' CSV;


drop table if exists income_band ;
create table income_band 
(
    ib_income_band_sk         int,
    ib_lower_bound            int,
    ib_upper_bound            int
);
COPY income_band FROM PROGRAM 'cat /tmp/tpcds_data/data/income_band.dat' DELIMITERS '|' CSV;

drop table if exists household_demographics ;
create table household_demographics 
(
    hd_demo_sk                int not null,
    hd_income_band_sk         int,
    hd_buy_potential          varchar(250),
    hd_dep_count              int,
    hd_vehicle_count          int,
    primary key(hd_demo_sk)
);
COPY household_demographics FROM PROGRAM 'cat /tmp/tpcds_data/data/household_demographics.dat' DELIMITERS '|' CSV;


drop table if exists inventory ;
create table inventory 
(
    inv_date_sk               int,
    inv_item_sk               int,
    inv_warehouse_sk          int,
    inv_quantity_on_hand      bigint
);
COPY inventory FROM PROGRAM 'cat /tmp/tpcds_data/data/inventory_part*.dat' DELIMITERS '|' CSV;


drop table if exists item ;
create table item 
(
    i_item_sk                 int not null,
    i_item_id                 varchar(250) not null,
    i_rec_start_date          varchar(250),
    i_rec_end_date            varchar(250),
    i_item_desc               varchar(250),
    i_current_price           double precision,
    i_wholesale_cost          double precision,
    i_brand_id                int,
    i_brand                   varchar(250),
    i_class_id                int,
    i_class                   varchar(250),
    i_category_id             int,
    i_category                varchar(250),
    i_manufact_id             int,
    i_manufact                varchar(250),
    i_size                    varchar(250),
    i_formulation             varchar(250),
    i_color                   varchar(250),
    i_units                   varchar(250),
    i_container               varchar(250),
    i_manager_id              int,
    i_product_name            varchar(250),
    primary key(i_item_sk)
);
COPY item FROM PROGRAM 'cat /tmp/tpcds_data/data/item.dat' DELIMITERS '|' CSV;


drop table if exists promotion ;
create table promotion 
(
    p_promo_sk                int not null,
    p_promo_id                varchar(250) not null,
    p_start_date_sk           int,
    p_end_date_sk             int,
    p_item_sk                 int,
    p_cost                    double precision,
    p_response_target         int,
    p_promo_name              varchar(250),
    p_channel_dmail           varchar(250),
    p_channel_email           varchar(250),
    p_channel_catalog         varchar(250),
    p_channel_tv              varchar(250),
    p_channel_radio           varchar(250),
    p_channel_press           varchar(250),
    p_channel_event           varchar(250),
    p_channel_demo            varchar(250),
    p_channel_details         varchar(250),
    p_purpose                 varchar(250),
    p_discount_active         varchar(250),
    primary key(p_promo_sk)
);
COPY promotion FROM PROGRAM 'cat /tmp/tpcds_data/data/promotion.dat' DELIMITERS '|' CSV;


drop table if exists reason ;
create table reason 
(
    r_reason_sk               int,
    r_reason_id               varchar(250),
    r_reason_desc             varchar(250)
);
COPY reason FROM PROGRAM 'cat /tmp/tpcds_data/data/reason.dat' DELIMITERS '|' CSV;

drop table if exists ship_mode ;
create table ship_mode 
(
    sm_ship_mode_sk           int,
    sm_ship_mode_id           varchar(250),
    sm_type                   varchar(250),
    sm_code                   varchar(250),
    sm_carrier                varchar(250),
    sm_contract               varchar(250)
);
COPY ship_mode FROM PROGRAM 'cat /tmp/tpcds_data/data/ship_mode.dat' DELIMITERS '|' CSV;


drop table if exists store ;
create table store 
(
    s_store_sk                int not null,
    s_store_id                varchar(250) not null,
    s_rec_start_date          varchar(250),
    s_rec_end_date            varchar(250),
    s_closed_date_sk          int references date_dim(d_date_sk),
    s_store_name              varchar(250),
    s_number_employees        int,
    s_floor_space             int,
    s_hours                   varchar(250),
    s_manager                 varchar(250),
    s_market_id               int,
    s_geography_class         varchar(250),
    s_market_desc             varchar(250),
    s_market_manager          varchar(250),
    s_division_id             int,
    s_division_name           varchar(250),
    s_company_id              int,
    s_company_name            varchar(250),
    s_street_number           varchar(250),
    s_street_name             varchar(250),
    s_street_type             varchar(250),
    s_suite_number            varchar(250),
    s_city                    varchar(250),
    s_county                  varchar(250),
    s_state                   varchar(250),
    s_zip                     varchar(250),
    s_country                 varchar(250),
    s_gmt_offset              double precision,
    s_tax_precentage          double precision,
    primary key(s_store_sk)

);
COPY store FROM PROGRAM 'cat /tmp/tpcds_data/data/store.dat' DELIMITERS '|' CSV;

drop table if exists store_returns ;
create table store_returns 
(
    sr_returned_date_sk       int,
    sr_return_time_sk         int,
    sr_item_sk                int,
    sr_customer_sk            int,
    sr_cdemo_sk               int,
    sr_hdemo_sk               int,
    sr_addr_sk                int,
    sr_store_sk               int,
    sr_reason_sk              int,
    sr_ticket_number          int,
    sr_return_quantity        int,
    sr_return_amt             double precision,
    sr_return_tax             double precision,
    sr_return_amt_inc_tax     double precision,
    sr_fee                    double precision,
    sr_return_ship_cost       double precision,
    sr_refunded_cash          double precision,
    sr_reversed_charge        double precision,
    sr_store_credit           double precision,
    sr_net_loss               double precision
);
COPY store_returns FROM PROGRAM 'cat /tmp/tpcds_data/data/store_returns_part*.dat' DELIMITERS '|' CSV;


drop table if exists time_dim ;
create table time_dim 
(
    t_time_sk                 int not null,
    t_time_id                 varchar(250) not null,
    t_time                    int not null,
    t_hour                    int,
    t_minute                  int,
    t_second                  int,
    t_am_pm                   varchar(250),
    t_shift                   varchar(250),
    t_sub_shift               varchar(250),
    t_meal_time               varchar(250),
    primary key(t_time_sk)
);
COPY time_dim FROM PROGRAM 'cat /tmp/tpcds_data/data/time_dim.dat' DELIMITERS '|' CSV;

drop table if exists warehouse ;
create table warehouse 
(
    w_warehouse_sk            int,
    w_warehouse_id            varchar(250),
    w_warehouse_name          varchar(250),
    w_warehouse_sq_ft         int,
    w_street_number           varchar(250),
    w_street_name             varchar(250),
    w_street_type             varchar(250),
    w_suite_number            varchar(250),
    w_city                    varchar(250),
    w_county                  varchar(250),
    w_state                   varchar(250),
    w_zip                     varchar(250),
    w_country                 varchar(250),
    w_gmt_offset              double precision
);
COPY warehouse FROM PROGRAM 'cat /tmp/tpcds_data/data/warehouse.dat' DELIMITERS '|' CSV;


drop table if exists web_page ;
create table web_page 
(
    wp_web_page_sk            int,
    wp_web_page_id            varchar(250),
    wp_rec_start_date         varchar(250),
    wp_rec_end_date           varchar(250),
    wp_creation_date_sk       int,
    wp_access_date_sk         int,
    wp_autogen_flag           varchar(250),
    wp_customer_sk            int,
    wp_url                    varchar(250),
    wp_type                   varchar(250),
    wp_char_count             int,
    wp_link_count             int,
    wp_image_count            int,
    wp_max_ad_count           int
);
COPY web_page FROM PROGRAM 'cat /tmp/tpcds_data/data/web_page.dat' DELIMITERS '|' CSV;


drop table if exists web_returns ;
create table web_returns 
(
    wr_returned_date_sk       int,
    wr_returned_time_sk       int,
    wr_item_sk                int,
    wr_refunded_customer_sk   int,
    wr_refunded_cdemo_sk      int,
    wr_refunded_hdemo_sk      int,
    wr_refunded_addr_sk       int,
    wr_returning_customer_sk  int,
    wr_returning_cdemo_sk     int,
    wr_returning_hdemo_sk     int,
    wr_returning_addr_sk      int,
    wr_web_page_sk            int,
    wr_reason_sk              int,
    wr_order_number           int,
    wr_return_quantity        int,
    wr_return_amt             double precision,
    wr_return_tax             double precision,
    wr_return_amt_inc_tax     double precision,
    wr_fee                    double precision,
    wr_return_ship_cost       double precision,
    wr_refunded_cash          double precision,
    wr_reversed_charge        double precision,
    wr_account_credit         double precision,
    wr_net_loss               double precision
);
COPY web_returns FROM PROGRAM 'cat /tmp/tpcds_data/data/web_returns.dat' DELIMITERS '|' CSV;

drop table if exists web_sales ;
create table web_sales 
(
    ws_sold_date_sk           int,
    ws_sold_time_sk           int,
    ws_ship_date_sk           int,
    ws_item_sk                int,
    ws_bill_customer_sk       int,
    ws_bill_cdemo_sk          int,
    ws_bill_hdemo_sk          int,
    ws_bill_addr_sk           int,
    ws_ship_customer_sk       int,
    ws_ship_cdemo_sk          int,
    ws_ship_hdemo_sk          int,
    ws_ship_addr_sk           int,
    ws_web_page_sk            int,
    ws_web_site_sk            int,
    ws_ship_mode_sk           int,
    ws_warehouse_sk           int,
    ws_promo_sk               int,
    ws_order_number           int,
    ws_quantity               int,
    ws_wholesale_cost         double precision,
    ws_list_price             double precision,
    ws_sales_price            double precision,
    ws_ext_discount_amt       double precision,
    ws_ext_sales_price        double precision,
    ws_ext_wholesale_cost     double precision,
    ws_ext_list_price         double precision,
    ws_ext_tax                double precision,
    ws_coupon_amt             double precision,
    ws_ext_ship_cost          double precision,
    ws_net_paid               double precision,
    ws_net_paid_inc_tax       double precision,
    ws_net_paid_inc_ship      double precision,
    ws_net_paid_inc_ship_tax  double precision,
    ws_net_profit             double precision
);
COPY web_sales FROM PROGRAM 'cat /tmp/tpcds_data/data/web_sales_part_*.dat' DELIMITERS '|' CSV;

drop table if exists web_site ;
create table web_site 
(
    web_site_sk               int,
    web_site_id               varchar(250),
    web_rec_start_date        varchar(250),
    web_rec_end_date          varchar(250),
    web_name                  varchar(250),
    web_open_date_sk          int,
    web_close_date_sk         int,
    web_class                 varchar(250),
    web_manager               varchar(250),
    web_mkt_id                int,
    web_mkt_class             varchar(250),
    web_mkt_desc              varchar(250),
    web_market_manager        varchar(250),
    web_company_id            int,
    web_company_name          varchar(250),
    web_street_number         varchar(250),
    web_street_name           varchar(250),
    web_street_type           varchar(250),
    web_suite_number          varchar(250),
    web_city                  varchar(250),
    web_county                varchar(250),
    web_state                 varchar(250),
    web_zip                   varchar(250),
    web_country               varchar(250),
    web_gmt_offset            double precision,
    web_tax_percentage        double precision
);
COPY web_site FROM PROGRAM 'cat /tmp/tpcds_data/data/web_site.dat' DELIMITERS '|' CSV;

drop table if exists customer ;
create table customer 
(
    c_customer_sk             int not null,
    c_customer_id             varchar(250) not null,
    c_current_cdemo_sk        int references customer_demographics(cd_demo_sk),
    c_current_hdemo_sk        int references household_demographics(hd_demo_sk),
    c_current_addr_sk         int references customer_address(ca_address_sk),
    c_first_shipto_date_sk    int references date_dim(d_date_sk),
    c_first_sales_date_sk     int references date_dim(d_date_sk),
    c_salutation              varchar(250),
    c_first_name              varchar(250),
    c_last_name               varchar(250),
    c_preferred_cust_flag     varchar(250),
    c_birth_day               int,
    c_birth_month             int,
    c_birth_year              int,
    c_birth_country           varchar(250),
    c_login                   varchar(250),
    c_email_address           varchar(250),
    c_last_review_date        varchar(250),
    primary key(c_customer_sk)
);
COPY customer FROM PROGRAM 'cat /tmp/tpcds_data/data/customer.dat' DELIMITERS '|' CSV;


drop table if exists store_sales ;
create table store_sales 
(
    ss_sold_date_sk           int references date_dim(d_date_sk),
    ss_sold_time_sk           int references time_dim(t_time_sk),
    ss_item_sk                int not null references item(i_item_sk),
    ss_customer_sk            int references customer(c_customer_sk),
    ss_cdemo_sk               int references customer_demographics(cd_demo_sk),
    ss_hdemo_sk               int references household_demographics(hd_demo_sk),
    ss_addr_sk                int references customer_address(ca_address_sk),
    ss_store_sk               int references store(s_store_sk),
    ss_promo_sk               int references promotion(p_promo_sk),
    ss_ticket_number          int not null,
    ss_quantity               int,
    ss_wholesale_cost         double precision,
    ss_list_price             double precision,
    ss_sales_price            double precision,
    ss_ext_discount_amt       double precision,
    ss_ext_sales_price        double precision,
    ss_ext_wholesale_cost     double precision,
    ss_ext_list_price         double precision,
    ss_ext_tax                double precision,
    ss_coupon_amt             double precision,
    ss_net_paid               double precision,
    ss_net_paid_inc_tax       double precision,
    ss_net_profit             double precision,
    primary key(ss_item_sk, ss_ticket_number)
);
COPY store_sales FROM PROGRAM 'cat /tmp/tpcds_data/data/store_sales_*.dat' DELIMITERS '|' CSV;