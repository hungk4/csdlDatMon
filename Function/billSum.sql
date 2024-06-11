-- // Hàm tính hóa đơn gốc ban đầu
CREATE OR REPLACE FUNCTION F_BillSum(p_bill_id INT)
RETURNS VOID AS $$
DECLARE
    v_total_sum_food INT := 0;
    v_total_sum_combo INT := 0;
BEGIN
    -- Tính tổng giá trị các món ăn
    SELECT COALESCE(SUM(f.price * o.quantity), 0)
    INTO v_total_sum_food
    FROM orders AS o
    JOIN foods AS f ON f.food_id = o.item_id
    WHERE o.bill_id = p_bill_id;


    -- Tính tổng giá trị các combo
    SELECT COALESCE(SUM(c.price * o.quantity), 0)
    INTO v_total_sum_combo
    FROM orders AS o
    JOIN combos AS c ON c.combo_id = o.item_id
    WHERE o.bill_id = p_bill_id;


    -- Trả về tổng giá trị
    update bills set total_price = v_total_sum_food + v_total_sum_combo
    where bill_id = p_bill_id ;
END;
$$ LANGUAGE plpgsql;
