-- Hàm cập nhật time_check_in cho KH đã book trước
CREATE OR REPLACE FUNCTION F_Update_Time_Check_In(p_phone varchar, p_bill_id INT)
RETURNS VARCHAR AS $$
DECLARE 
BEGIN
	UPDATE bills
	SET time_check_in = date_trunc('second',CURRENT_TIMESTAMP)
	WHERE phone = p_phone 
AND time_booking IS NOT NULL 
AND time_check_in IS NULL
AND p_bill_id = bill_id;
	RETURN 'da cap nhat time_check_in THANH CONG!';
END;
$$ LANGUAGE plpgsql;




-- vi du chay thu : select f_update_time_check_in('0123456789', 1);