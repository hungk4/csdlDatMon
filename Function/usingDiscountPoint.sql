-- Hàm   trừ discount_point
CREATE OR REPLACE FUNCTION F_UsingDiscountpoint(
    IN p_bill_id INT,
    IN p_reduce INT
)
RETURNS VOID AS $$
DECLARE
    v_user_point INT;
	v_total_price INT;
	v_phone VARCHAR;
BEGIN
    -- Lấy điểm giảm giá hiện tại của khách hàng
	SELECT phone INTO v_phone
	FROM bills WHERE bill_id = p_bill_id;
	
    SELECT discount_point INTO v_user_point
    FROM accounts
    WHERE phone = v_phone;
	
	SELECT total_price INTO v_total_price
	FROM bills
	WHERE bill_id = p_bill_id;
    -- Kiểm tra điều kiện để sử dụng điểm giảm giá
    IF p_reduce > 0 AND p_reduce % 5 = 0 AND p_reduce <= v_user_point AND v_total_price >= p_reduce THEN
        -- Thực hiện thêm dòng vào bảng Pays
		UPDATE bills SET reduce = p_reduce WHERE bill_id = p_bill_id;

        -- Cập nhật điểm giảm giá của khách hàng
        UPDATE accounts
        SET discount_point = v_user_point - p_reduce
        WHERE phone = v_phone;
		
		UPDATE bills
		SET total_price = v_total_price - p_reduce
		WHERE bill_id = p_bill_id;
    END IF;
END;
$$ LANGUAGE plpgsql;
