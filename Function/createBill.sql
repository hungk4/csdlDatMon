-- Hàm tạo bill (giành cho khách chưa đặt trước) 
CREATE OR REPLACE FUNCTION F_Create_Bill(
p_phone VARCHAR, 
p_number_of_guest INT)
RETURNS VARCHAR AS $$
BEGIN
    -- kiểm tra số điện thoại hợp lệ
    IF NOT EXISTS(SELECT 1 FROM accounts WHERE phone = p_phone) THEN
        RETURN 'sdt ko ton tai';
    END IF;

    -- Thêm một bản ghi mới vào bảng bills với thời gian hiện tại đã loại bỏ phần mili giây
    INSERT INTO bills (phone, time_check_in, bill_status, number_of_guest)
    VALUES (p_phone, date_trunc('second', clock_timestamp()), 0, p_number_of_guest);

    RETURN 'tao bill thanh cong';
END;
$$ LANGUAGE plpgsql;



-- vi du chay thu:  select F_Create_Bill('0123456789', 2);