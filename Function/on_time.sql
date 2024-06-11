-- Check đến đúng giờ
CREATE OR REPLACE FUNCTION F_On_Time(p_bill_id INT)
RETURNS INT AS $$
DECLARE
    v_time_booking TIMESTAMP;
    v_time_check_in TIMESTAMP;
BEGIN
    SELECT time_booking, time_check_in 
    INTO v_time_booking, v_time_check_in 
    FROM bills
    WHERE bill_id = p_bill_id;
    
    IF v_time_booking IS NULL THEN
        RETURN 0;
    ELSIF ABS (EXTRACT(EPOCH FROM (v_time_check_in - v_time_booking)) / 60) <= 15 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;
