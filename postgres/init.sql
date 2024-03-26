DROP TABLE IF EXISTS crm_user CASCADE;
DROP TABLE IF EXISTS permission CASCADE;
DROP TABLE IF EXISTS permission_allocation CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer_order CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;


CREATE TABLE IF NOT EXISTS crm_user (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_by INT REFERENCES crm_user(id),
    updated_by INT REFERENCES crm_user(id),
    deleted_by INT REFERENCES crm_user(id)
);

CREATE TABLE IF NOT EXISTS permission (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_by INT REFERENCES crm_user(id),
    updated_by INT REFERENCES crm_user(id),
    deleted_by INT REFERENCES crm_user(id)
);

CREATE TABLE IF NOT EXISTS permission_allocation (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES crm_user(id),
    permission_id INT REFERENCES permission(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_by INT REFERENCES crm_user(id),
    updated_by INT REFERENCES crm_user(id),
    deleted_by INT REFERENCES crm_user(id)
);


CREATE TABLE IF NOT EXISTS customer (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    representative INT REFERENCES crm_user(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_by INT REFERENCES crm_user(id),
    updated_by INT REFERENCES crm_user(id),
    deleted_by INT REFERENCES crm_user(id)
);

CREATE TABLE IF NOT EXISTS product (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_by INT REFERENCES crm_user(id),
    updated_by INT REFERENCES crm_user(id),
    deleted_by INT REFERENCES crm_user(id)
);

CREATE TABLE IF NOT EXISTS customer_order (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(id),
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INT REFERENCES crm_user(id),
    updated_by INT REFERENCES crm_user(id),
    deleted_by INT REFERENCES crm_user(id)
);

CREATE TABLE IF NOT EXISTS order_item (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES customer_order(id),
    product_id INT REFERENCES product(id),
    quantity INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by INT REFERENCES crm_user(id),
    updated_by INT REFERENCES crm_user(id),
    deleted_by INT REFERENCES crm_user(id)
);




CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at_before_update ON customer;
DROP TRIGGER IF EXISTS set_updated_at_before_update ON customer_order;
DROP TRIGGER IF EXISTS set_updated_at_before_update ON product;
DROP TRIGGER IF EXISTS set_updated_at_before_update ON order_item;

CREATE TRIGGER set_updated_at_before_update
BEFORE UPDATE ON customer
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_before_update
BEFORE UPDATE ON customer_order
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_before_update
BEFORE UPDATE ON product
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_before_update
BEFORE UPDATE ON order_item
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


DO $$

DECLARE
    customer_id INT;
    product_id INT;
    order_id INT;
    admin_1 INT;
    admin_2 INT;
    admin_permission_id INT;
BEGIN


  IF (SELECT COUNT(*) FROM crm_user) = 0 THEN
    RAISE NOTICE 'Starting data generation...';
    INSERT INTO crm_user (username, created_by, updated_by) VALUES
    ('admin 1', 1, 1),
    ('admin 2', 1, 1),
    ('crm_user 3', 1, 1),
    ('crm_user 4', 1, 1),
    ('crm_user 5', 1, 1),
    ('crm_user 6', 1, 1),
    ('crm_user 7', 1, 1),
    ('crm_user 8', 1, 1),
    ('crm_user 9', 1, 1),
    ('crm_user 10', 1, 1);

    SELECT id INTO admin_1 FROM crm_user WHERE username = 'admin 1';
    SELECT id INTO admin_2 FROM crm_user WHERE username = 'admin 2';

    INSERT INTO permission (name, created_by, updated_by) VALUES
    ('admin', 1, 1);

    SELECT id INTO admin_permission_id FROM permission WHERE name = 'admin';
    INSERT INTO permission_allocation (user_id, permission_id, created_by, updated_by) VALUES
    (admin_1, admin_permission_id, 1, 1),
    (admin_2, admin_permission_id, 1, 1);


    BEGIN
      FOR i IN 1..50 LOOP
        INSERT INTO customer (name, representative, created_by, updated_by) VALUES
        ('Customer ' || i, (i % 10) + 1, 1, 1)
        RETURNING id INTO customer_id;
        
        FOR j IN 1..3 LOOP
          INSERT INTO customer_order (customer_id, created_by, updated_by) VALUES
          (customer_id, 1, 1)
          RETURNING id INTO order_id;
          
          FOR k IN 1..5 LOOP
            INSERT INTO product (name, price, created_by, updated_by) VALUES
            ('Product ' || k, 10.00 * k, 1, 1)
            RETURNING id INTO product_id;
            
            INSERT INTO order_item (order_id, product_id, quantity, created_by, updated_by) VALUES
            (order_id, product_id, k, 1, 1);
          END LOOP;
        END LOOP;
      END LOOP;
    END;
  RAISE NOTICE 'Data generation completed successfully.';
  ELSE
    RAISE NOTICE 'No need to create data.';
  END IF;
END $$;

