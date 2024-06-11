-- Hàm thanh toán (chuyển bill_status từ 0 sang 1)

CREATE OR REPLACE FUNCTION F_Purchase(p_bill_id INT)
RETURNS VOID AS $$
BEGIN
	UPDATE bills SET bill_status = 1 WHERE bill_id = p_bill_id;
END;
$$ LANGUAGE plpgsql;
