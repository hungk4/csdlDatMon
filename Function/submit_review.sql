-- hàm gửi đánh giá, điểm
CREATE OR REPLACE FUNCTION submit_review(
	p_bill_id INT,
	p_point INT,
	p_comment varchar
)
RETURNS VOID AS $$
BEGIN
	IF p_point < 1 OR p_point > 5 THEN
		RAISE EXCEPTION 'diem danh gia phai tu 1 den 5';
	END IF;
	
	UPDATE bills
	SET point = p_point, comment = p_comment
	WHERE bill_id = p_bill_id;
END;
$$ LANGUAGE plpgsql;
