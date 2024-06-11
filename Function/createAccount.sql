-- Hàm tạo account
CREATE OR REPLACE FUNCTION F_Create_Account(p_phone VARCHAR, p_name VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
	v_username VARCHAR;
BEGIN
	SELECT name INTO v_username
	FROM accounts WHERE phone = p_phone;
	
	IF v_username IS NULL THEN
		BEGIN
			INSERT INTO accounts (phone, name, type, discount_point, visit_count)
			VALUES (p_phone, p_name, 'customer' , 0, 0);
			RETURN 'tao tai khoan thanh cong';
		EXCEPTION WHEN OTHERS THEN
			RETURN 'co loi xay ra khi tao tai khoan';
		END;
	ELSE
		RETURN 'tai khoan voi sdt nay da ton tai';
	END IF;
END;
$$ LANGUAGE plpgsql;

-- SELECT f_create_account('0123456789', 'mai minh quan');