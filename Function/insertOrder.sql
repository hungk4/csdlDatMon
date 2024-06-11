-- Hàm order food
CREATE OR REPLACE FUNCTION F_InsertOrder (
    IN p_bill_id INT,
    IN p_item_id VARCHAR,
    IN p_table_id INT,
    IN p_quantity INT
) 
RETURNS VOID AS $$
DECLARE
    v_order_id INT;
    v_item_count INT;
    v_new_count INT;
BEGIN
    -- Initialize variables
    v_order_id := 0;
    v_item_count := 0;
    v_new_count := 0;

    -- Check if the order already exists in BillInfo
    SELECT order_id, quantity
    INTO v_order_id, v_item_count
    FROM orders
    WHERE bill_id = p_bill_id AND item_id = p_item_id;

    -- If order exists, update quantity
    IF v_order_id > 0 THEN
        v_new_count := v_item_count + p_quantity;
        IF v_new_count > 0 THEN
            -- Update the existing order
            UPDATE orders
            SET quantity = v_new_count
            WHERE order_id = v_order_id;
        END IF;
    ELSE
        -- Otherwise, insert a new order
        INSERT INTO orders (bill_id, item_id, table_id, quantity)
        VALUES (p_bill_id, p_item_id, p_table_id, p_quantity);
    END IF;
END;
$$ LANGUAGE plpgsql;
