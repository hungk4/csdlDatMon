-- Hàm booking
CREATE OR REPLACE FUNCTION F_Create_Booking(
    p_phone VARCHAR, 
    p_time_booking timestamp,
    p_number_of_guest	 int
)
RETURNS VARCHAR AS $$
BEGIN
    -- kiểm tra sdt hợp lệ
    IF NOT EXISTS(SELECT 1 FROM accounts WHERE phone = p_phone) THEN
        RETURN 'sdt ko ton tai';
    END IF;
    
    INSERT INTO bills(phone, time_booking, bill_status, number_of_guest)
    VALUES (p_phone, p_time_booking, 0, p_number_of_guest);
    
    RETURN 'tao booking thanh cong';
END;
$$ LANGUAGE plpgsql;

-- SELECT F_Create_Booking('0123456789', '2024-06-11 18:00:00', 3);