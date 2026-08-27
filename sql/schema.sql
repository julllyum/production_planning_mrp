DROP SCHEMA IF EXISTS SupplyChain CASCADE;
CREATE SCHEMA SupplyChain;

CREATE TABLE SupplyChain.Customer (
    customer_id INT PRIMARY KEY,
    customer_priority INT,
    customer_name VARCHAR(50),
    customer_group_id INT
);

CREATE TABLE SupplyChain.Resource (
    resource_id INT PRIMARY KEY,
    resource_desc VARCHAR(30),
    wearout_factor INT,
    start_maintenance_date DATE,
    end_maintenance_date DATE,
    status INT
);

CREATE TABLE SupplyChain.Product (
    product_id CHAR(12) PRIMARY KEY,
    product_desc VARCHAR(50),
    product_usage_type CHAR(1),
    product_min_weight NUMERIC(18,2),
    product_max_weight NUMERIC(18,2),
    product_group CHAR(10),
    product_type CHAR(10)
);

CREATE TABLE SupplyChain.Standard_Operation (
    product_id CHAR(12) REFERENCES SupplyChain.Product(product_id),
    resource_id INT REFERENCES SupplyChain.Resource(resource_id),
    alternate_prefix INT,
    standard_op_no INT,
    operation_type CHAR(1),
    standard_time INT,
    yield_percent NUMERIC(5,2),
    PRIMARY KEY (product_id, resource_id, standard_op_no)
);

CREATE TABLE SupplyChain.Product_Link (
    product_link_id INT PRIMARY KEY,
    owner_product CHAR(12) REFERENCES SupplyChain.Product(product_id),
    component_product CHAR(12) REFERENCES SupplyChain.Product(product_id),
    product_link_ty_id CHAR(1),
    product_preference INT
);

CREATE TABLE SupplyChain.Sales_Order (
    sales_order_id INT PRIMARY KEY,
    customer_id INT REFERENCES SupplyChain.Customer(customer_id),
    product_id CHAR(12) REFERENCES SupplyChain.Product(product_id),
    so_quantity NUMERIC(18,2),
    so_tolerance NUMERIC(10,0),
    shipped_quantity NUMERIC(18,2),
    so_status INT,
    orig_due_date DATE,
    due_date DATE,
    release_date DATE,
    ship_to_location VARCHAR(50),
    original_from_date DATE,
    unit_weight NUMERIC(10,2)
);

CREATE TABLE SupplyChain.Calendar_Capacity (
    work_date DATE NOT NULL,
    resource_id INT NOT NULL REFERENCES SupplyChain.Resource(resource_id),
    available_hours NUMERIC(10,2) DEFAULT 23.00,
    PRIMARY KEY (work_date, resource_id)
);

CREATE TABLE SupplyChain.MRP_Plan (
    mrp_id SERIAL PRIMARY KEY,
    sales_order_id INT,
    product_id CHAR(12),
    resource_id INT,
    operation_no INT,
    qty_units NUMERIC(18,3),
    weight_ton NUMERIC(18,2),
    required_hours NUMERIC(10,2),
    ready_date DATE,
    start_time TIME,
    end_time TIME
);
