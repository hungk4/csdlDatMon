PGDMP  -    3                |            datDoAn    16.2    16.2 K    D           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            E           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            F           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            G           1262    22906    datDoAn    DATABASE     �   CREATE DATABASE "datDoAn" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE "datDoAn";
                postgres    false            �            1255    23026    add_combo_to_menu()    FUNCTION     �   CREATE FUNCTION public.add_combo_to_menu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO menus (item_id, food_id, combo_id) VALUES (NEW.combo_id, 'NF', NEW.combo_id);
  RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.add_combo_to_menu();
       public          postgres    false            �            1255    23022    add_food_to_menu()    FUNCTION     �   CREATE FUNCTION public.add_food_to_menu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO menus (item_id, food_id, combo_id) VALUES (NEW.food_id, new.food_id, 'NC');
  RETURN NEW;
END;
$$;
 )   DROP FUNCTION public.add_food_to_menu();
       public          postgres    false            �            1255    23084    f_billsum(integer)    FUNCTION     �  CREATE FUNCTION public.f_billsum(p_bill_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 3   DROP FUNCTION public.f_billsum(p_bill_id integer);
       public          postgres    false            �            1255    23043 6   f_create_account(character varying, character varying)    FUNCTION     W  CREATE FUNCTION public.f_create_account(p_phone character varying, p_name character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;
 \   DROP FUNCTION public.f_create_account(p_phone character varying, p_name character varying);
       public          postgres    false            �            1255    23081 )   f_create_bill(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.f_create_bill(p_phone character varying, p_number_of_guest integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;
 Z   DROP FUNCTION public.f_create_bill(p_phone character varying, p_number_of_guest integer);
       public          postgres    false            �            1255    23082 I   f_create_booking(character varying, timestamp without time zone, integer)    FUNCTION       CREATE FUNCTION public.f_create_booking(p_phone character varying, p_time_booking timestamp without time zone, p_number_of_guest integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- kiểm tra sdt hợp lệ
    IF NOT EXISTS(SELECT 1 FROM accounts WHERE phone = p_phone) THEN
        RETURN 'sdt ko ton tai';
    END IF;
    
    INSERT INTO bills(phone, time_booking, bill_status, number_of_guest)
    VALUES (p_phone, p_time_booking, 0, p_number_of_guest);
    
    RETURN 'tao booking thanh cong';
END;
$$;
 �   DROP FUNCTION public.f_create_booking(p_phone character varying, p_time_booking timestamp without time zone, p_number_of_guest integer);
       public          postgres    false            �            1255    23056 ;   f_insertorder(integer, character varying, integer, integer)    FUNCTION       CREATE FUNCTION public.f_insertorder(p_bill_id integer, p_item_id character varying, p_table_id integer, p_quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 |   DROP FUNCTION public.f_insertorder(p_bill_id integer, p_item_id character varying, p_table_id integer, p_quantity integer);
       public          postgres    false            �            1255    23062    f_on_time(integer)    FUNCTION       CREATE FUNCTION public.f_on_time(p_bill_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;
 3   DROP FUNCTION public.f_on_time(p_bill_id integer);
       public          postgres    false            �            1255    23093    f_purchase(integer)    FUNCTION     �   CREATE FUNCTION public.f_purchase(p_bill_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE bills SET bill_status = 1 WHERE bill_id = p_bill_id;
END;
$$;
 4   DROP FUNCTION public.f_purchase(p_bill_id integer);
       public          postgres    false            �            1255    23065 2   f_update_time_check_in(character varying, integer)    FUNCTION     �  CREATE FUNCTION public.f_update_time_check_in(p_phone character varying, p_bill_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
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
$$;
 [   DROP FUNCTION public.f_update_time_check_in(p_phone character varying, p_bill_id integer);
       public          postgres    false            �            1255    23085 &   f_usingdiscountpoint(integer, integer)    FUNCTION     9  CREATE FUNCTION public.f_usingdiscountpoint(p_bill_id integer, p_reduce integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;
 P   DROP FUNCTION public.f_usingdiscountpoint(p_bill_id integer, p_reduce integer);
       public          postgres    false            �            1255    23028    remove_combo_from_menu()    FUNCTION     �   CREATE FUNCTION public.remove_combo_from_menu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM menus WHERE item_id = OLD.combo_id;
	RETURN OLD;
END;
$$;
 /   DROP FUNCTION public.remove_combo_from_menu();
       public          postgres    false            �            1255    23024    remove_food_from_menu()    FUNCTION     �   CREATE FUNCTION public.remove_food_from_menu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM menus WHERE item_id = OLD.food_id;
	RETURN OLD;
END;
$$;
 .   DROP FUNCTION public.remove_food_from_menu();
       public          postgres    false            �            1255    23080 2   submit_review(integer, integer, character varying)    FUNCTION     W  CREATE FUNCTION public.submit_review(p_bill_id integer, p_point integer, p_comment character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF p_point < 1 OR p_point > 5 THEN
		RAISE EXCEPTION 'diem danh gia phai tu 1 den 5';
	END IF;
	
	UPDATE bills
	SET point = p_point, comment = p_comment
	WHERE bill_id = p_bill_id;
END;
$$;
 e   DROP FUNCTION public.submit_review(p_bill_id integer, p_point integer, p_comment character varying);
       public          postgres    false            �            1255    23078    update_combo_status_to_menu()    FUNCTION     �  CREATE FUNCTION public.update_combo_status_to_menu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.combo_status = 'available' AND NEW.combo_status = 'unavailable' THEN
        DELETE FROM menus WHERE item_id = NEW.combo_id;
	ELSEIF OLD.combo_status = 'unavailable' AND NEW.combo_status = 'available' THEN
        INSERT INTO menus(item_id, food_id, combo_id) 
				VALUES(NEW.combo_id, 'NF', NEW.combo_id) ;
    END IF;
    RETURN NEW;
END;
$$;
 4   DROP FUNCTION public.update_combo_status_to_menu();
       public          postgres    false            �            1255    23086    update_discount_points()    FUNCTION     �  CREATE FUNCTION public.update_discount_points() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.visit_count = 5 THEN
    UPDATE accounts SET discount_point = NEW.discount_point + 4 WHERE phone = NEW.phone;
  ELSIF NEW.visit_count > 5 AND NEW.visit_count % 5 = 0 THEN
    UPDATE accounts SET discount_point = NEW.discount_point + ((NEW.visit_count / 5) - 1) * 10 WHERE phone = NEW.phone;
  END IF;
  RETURN NEW;
END;
$$;
 /   DROP FUNCTION public.update_discount_points();
       public          postgres    false            �            1255    23076    update_food_status_to_menu()    FUNCTION     �  CREATE FUNCTION public.update_food_status_to_menu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.food_status = 'available' AND NEW.food_status = 'unavailable' THEN
        DELETE FROM menus WHERE item_id = NEW.food_id;
	ELSEIF OLD.food_status = 'unavailable' AND NEW.food_status = 'available' THEN
        INSERT INTO menus(item_id, food_id, combo_id) 
				VALUES(NEW.food_id, NEW.food_id, 'NC') ;
    END IF;
    RETURN NEW;
END;
$$;
 3   DROP FUNCTION public.update_food_status_to_menu();
       public          postgres    false            �            1255    23091    updatebillwhenpaid()    FUNCTION        CREATE FUNCTION public.updatebillwhenpaid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
	v_on_time INT;
	v_having_visit INT;
	v_phone VARCHAR;
	v_having_point FLOAT;
	v_total_present FLOAT;
BEGIN
  	-- Update bàn thành trống sau khi thanh toán
      UPDATE tables
      SET status = 0
      WHERE table_id IN (
         SELECT table_id
         FROM orders
         WHERE bill_id = NEW.bill_id
      );
	  
	  -- Giảm 1% nếu đặt trước và đến đúng giờ
	SELECT f_on_Time(NEW.bill_id) INTO v_on_time;
	IF v_on_time = 1 THEN
	  UPDATE bills SET total_price = NEW.total_price * 0.99
	  WHERE bill_id = NEW.bill_id;
	END IF;
	
	-- Tăng visit_count
	SELECT phone INTO v_phone
	FROM bills WHERE bill_id = NEW.bill_id;
	
	SELECT visit_count INTO v_having_visit
    FROM accounts
    WHERE phone = v_phone;
	
	UPDATE accounts SET visit_count = v_having_visit + 1
	WHERE phone = v_phone;
	
	-- Cộng 2% gtri hóa đơn vào discount_point của KH
	SELECT discount_point INTO v_having_point
	FROM accounts WHERE phone = v_phone;
	-- Lấy total_price đã giảm 1%
	SELECT total_price INTO v_total_present
	FROM bills WHERE bill_id = NEW.bill_id;
	-- Update lại discount_point
	UPDATE accounts SET discount_point = v_having_point + ((v_total_present)* 0.2);
    RETURN NEW;
END;
$$;
 +   DROP FUNCTION public.updatebillwhenpaid();
       public          postgres    false            �            1259    22907    accounts    TABLE     �   CREATE TABLE public.accounts (
    phone character varying NOT NULL,
    name character varying,
    type character varying,
    discount_point double precision,
    visit_count integer
);
    DROP TABLE public.accounts;
       public         heap    postgres    false            �            1259    22944    areas    TABLE     ]   CREATE TABLE public.areas (
    area_id integer NOT NULL,
    area_name character varying
);
    DROP TABLE public.areas;
       public         heap    postgres    false            �            1259    22915    bills    TABLE     �  CREATE TABLE public.bills (
    bill_id integer NOT NULL,
    time_check_in timestamp without time zone,
    time_check_out timestamp without time zone,
    point integer,
    comment text,
    bill_status integer,
    time_booking timestamp without time zone,
    total_price double precision,
    phone character varying,
    reduce double precision,
    number_of_guest integer
);
    DROP TABLE public.bills;
       public         heap    postgres    false            �            1259    22914    bills_bill_id_seq    SEQUENCE     �   CREATE SEQUENCE public.bills_bill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.bills_bill_id_seq;
       public          postgres    false    217            H           0    0    bills_bill_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.bills_bill_id_seq OWNED BY public.bills.bill_id;
          public          postgres    false    216            �            1259    22965    combos    TABLE     �   CREATE TABLE public.combos (
    combo_id character varying NOT NULL,
    combo_name character varying,
    combo_status character varying,
    price integer
);
    DROP TABLE public.combos;
       public         heap    postgres    false            �            1259    22958    foods    TABLE     �   CREATE TABLE public.foods (
    food_id character varying NOT NULL,
    name character varying,
    price integer,
    food_status character varying,
    description character varying
);
    DROP TABLE public.foods;
       public         heap    postgres    false            �            1259    22972    join_food_combos    TABLE     h   CREATE TABLE public.join_food_combos (
    food_id character varying,
    combo_id character varying
);
 $   DROP TABLE public.join_food_combos;
       public         heap    postgres    false            �            1259    22951    menus    TABLE     �   CREATE TABLE public.menus (
    item_id character varying NOT NULL,
    food_id character varying,
    combo_id character varying
);
    DROP TABLE public.menus;
       public         heap    postgres    false            �            1259    22931    orders    TABLE     �   CREATE TABLE public.orders (
    order_id integer NOT NULL,
    bill_id integer,
    item_id character varying,
    table_id integer,
    quantity integer
);
    DROP TABLE public.orders;
       public         heap    postgres    false            �            1259    22930    orders_order_id_seq    SEQUENCE     �   CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.orders_order_id_seq;
       public          postgres    false    219            I           0    0    orders_order_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;
          public          postgres    false    218            �            1259    22939    tables    TABLE     }   CREATE TABLE public.tables (
    table_id integer NOT NULL,
    capacity integer,
    status integer,
    area_id integer
);
    DROP TABLE public.tables;
       public         heap    postgres    false            �           2604    22918    bills bill_id    DEFAULT     n   ALTER TABLE ONLY public.bills ALTER COLUMN bill_id SET DEFAULT nextval('public.bills_bill_id_seq'::regclass);
 <   ALTER TABLE public.bills ALTER COLUMN bill_id DROP DEFAULT;
       public          postgres    false    217    216    217            �           2604    22934    orders order_id    DEFAULT     r   ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);
 >   ALTER TABLE public.orders ALTER COLUMN order_id DROP DEFAULT;
       public          postgres    false    218    219    219            7          0    22907    accounts 
   TABLE DATA           R   COPY public.accounts (phone, name, type, discount_point, visit_count) FROM stdin;
    public          postgres    false    215   �y       =          0    22944    areas 
   TABLE DATA           3   COPY public.areas (area_id, area_name) FROM stdin;
    public          postgres    false    221   |       9          0    22915    bills 
   TABLE DATA           �   COPY public.bills (bill_id, time_check_in, time_check_out, point, comment, bill_status, time_booking, total_price, phone, reduce, number_of_guest) FROM stdin;
    public          postgres    false    217   L|       @          0    22965    combos 
   TABLE DATA           K   COPY public.combos (combo_id, combo_name, combo_status, price) FROM stdin;
    public          postgres    false    224   ��       ?          0    22958    foods 
   TABLE DATA           O   COPY public.foods (food_id, name, price, food_status, description) FROM stdin;
    public          postgres    false    223    �       A          0    22972    join_food_combos 
   TABLE DATA           =   COPY public.join_food_combos (food_id, combo_id) FROM stdin;
    public          postgres    false    225   Z�       >          0    22951    menus 
   TABLE DATA           ;   COPY public.menus (item_id, food_id, combo_id) FROM stdin;
    public          postgres    false    222   w�       ;          0    22931    orders 
   TABLE DATA           P   COPY public.orders (order_id, bill_id, item_id, table_id, quantity) FROM stdin;
    public          postgres    false    219   �       <          0    22939    tables 
   TABLE DATA           E   COPY public.tables (table_id, capacity, status, area_id) FROM stdin;
    public          postgres    false    220   _�       J           0    0    bills_bill_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.bills_bill_id_seq', 11, true);
          public          postgres    false    216            K           0    0    orders_order_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.orders_order_id_seq', 17, true);
          public          postgres    false    218            �           2606    22913    accounts accounts_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (phone);
 @   ALTER TABLE ONLY public.accounts DROP CONSTRAINT accounts_pkey;
       public            postgres    false    215            �           2606    22950    areas areas_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.areas
    ADD CONSTRAINT areas_pkey PRIMARY KEY (area_id);
 :   ALTER TABLE ONLY public.areas DROP CONSTRAINT areas_pkey;
       public            postgres    false    221            �           2606    22922    bills bills_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_pkey PRIMARY KEY (bill_id);
 :   ALTER TABLE ONLY public.bills DROP CONSTRAINT bills_pkey;
       public            postgres    false    217            �           2606    22971    combos combos_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.combos
    ADD CONSTRAINT combos_pkey PRIMARY KEY (combo_id);
 <   ALTER TABLE ONLY public.combos DROP CONSTRAINT combos_pkey;
       public            postgres    false    224            �           2606    22964    foods foods_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_pkey PRIMARY KEY (food_id);
 :   ALTER TABLE ONLY public.foods DROP CONSTRAINT foods_pkey;
       public            postgres    false    223            �           2606    22957    menus menus_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (item_id);
 :   ALTER TABLE ONLY public.menus DROP CONSTRAINT menus_pkey;
       public            postgres    false    222            �           2606    22938    orders orders_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public            postgres    false    219            �           2606    22943    tables tables_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.tables
    ADD CONSTRAINT tables_pkey PRIMARY KEY (table_id);
 <   ALTER TABLE ONLY public.tables DROP CONSTRAINT tables_pkey;
       public            postgres    false    220            �           1259    23095    phone    INDEX     ;   CREATE INDEX phone ON public.accounts USING btree (phone);
    DROP INDEX public.phone;
       public            postgres    false    215            �           1259    23103    uidx_time_check_in    INDEX     L   CREATE INDEX uidx_time_check_in ON public.bills USING hash (time_check_in);
 &   DROP INDEX public.uidx_time_check_in;
       public            postgres    false    217            �           2620    23029    combos after_combo_delete    TRIGGER        CREATE TRIGGER after_combo_delete AFTER DELETE ON public.combos FOR EACH ROW EXECUTE FUNCTION public.remove_combo_from_menu();
 2   DROP TRIGGER after_combo_delete ON public.combos;
       public          postgres    false    224    229            �           2620    23027    combos after_combo_insert    TRIGGER     z   CREATE TRIGGER after_combo_insert AFTER INSERT ON public.combos FOR EACH ROW EXECUTE FUNCTION public.add_combo_to_menu();
 2   DROP TRIGGER after_combo_insert ON public.combos;
       public          postgres    false    224    228            �           2620    23079 !   combos after_combo_status_to_menu    TRIGGER     �   CREATE TRIGGER after_combo_status_to_menu AFTER UPDATE OF combo_status ON public.combos FOR EACH ROW WHEN (((old.combo_status)::text IS DISTINCT FROM (new.combo_status)::text)) EXECUTE FUNCTION public.update_combo_status_to_menu();
 :   DROP TRIGGER after_combo_status_to_menu ON public.combos;
       public          postgres    false    243    224    224    224            �           2620    23025    foods after_food_delete    TRIGGER     |   CREATE TRIGGER after_food_delete AFTER DELETE ON public.foods FOR EACH ROW EXECUTE FUNCTION public.remove_food_from_menu();
 0   DROP TRIGGER after_food_delete ON public.foods;
       public          postgres    false    227    223            �           2620    23023    foods after_food_insert    TRIGGER     w   CREATE TRIGGER after_food_insert AFTER INSERT ON public.foods FOR EACH ROW EXECUTE FUNCTION public.add_food_to_menu();
 0   DROP TRIGGER after_food_insert ON public.foods;
       public          postgres    false    223    226            �           2620    23077    foods after_food_status_to_menu    TRIGGER     �   CREATE TRIGGER after_food_status_to_menu AFTER UPDATE OF food_status ON public.foods FOR EACH ROW WHEN (((old.food_status)::text IS DISTINCT FROM (new.food_status)::text)) EXECUTE FUNCTION public.update_food_status_to_menu();
 8   DROP TRIGGER after_food_status_to_menu ON public.foods;
       public          postgres    false    223    223    246    223            �           2620    23087 '   accounts trigger_update_discount_points    TRIGGER     �   CREATE TRIGGER trigger_update_discount_points AFTER UPDATE OF visit_count ON public.accounts FOR EACH ROW WHEN ((old.visit_count IS DISTINCT FROM new.visit_count)) EXECUTE FUNCTION public.update_discount_points();
 @   DROP TRIGGER trigger_update_discount_points ON public.accounts;
       public          postgres    false    215    215    215    252            �           2620    23092 $   bills utg_updatebillwhenpaid_trigger    TRIGGER     �   CREATE TRIGGER utg_updatebillwhenpaid_trigger AFTER UPDATE OF bill_status ON public.bills FOR EACH ROW WHEN ((old.bill_status IS DISTINCT FROM new.bill_status)) EXECUTE FUNCTION public.updatebillwhenpaid();
 =   DROP TRIGGER utg_updatebillwhenpaid_trigger ON public.bills;
       public          postgres    false    217    217    253    217            �           2606    22977    bills bills_phone_fkey    FK CONSTRAINT     y   ALTER TABLE ONLY public.bills
    ADD CONSTRAINT bills_phone_fkey FOREIGN KEY (phone) REFERENCES public.accounts(phone);
 @   ALTER TABLE ONLY public.bills DROP CONSTRAINT bills_phone_fkey;
       public          postgres    false    4742    215    217            �           2606    23002 /   join_food_combos join_food_combos_combo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.join_food_combos
    ADD CONSTRAINT join_food_combos_combo_id_fkey FOREIGN KEY (combo_id) REFERENCES public.combos(combo_id);
 Y   ALTER TABLE ONLY public.join_food_combos DROP CONSTRAINT join_food_combos_combo_id_fkey;
       public          postgres    false    225    224    4758            �           2606    22997 .   join_food_combos join_food_combos_food_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.join_food_combos
    ADD CONSTRAINT join_food_combos_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(food_id);
 X   ALTER TABLE ONLY public.join_food_combos DROP CONSTRAINT join_food_combos_food_id_fkey;
       public          postgres    false    225    4756    223            �           2606    23035    menus menus_combo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_combo_id_fkey FOREIGN KEY (combo_id) REFERENCES public.combos(combo_id);
 C   ALTER TABLE ONLY public.menus DROP CONSTRAINT menus_combo_id_fkey;
       public          postgres    false    222    4758    224            �           2606    23030    menus menus_food_id_fkey    FK CONSTRAINT     |   ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(food_id);
 B   ALTER TABLE ONLY public.menus DROP CONSTRAINT menus_food_id_fkey;
       public          postgres    false    4756    223    222            �           2606    22982    orders orders_bill_id_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_bill_id_fkey FOREIGN KEY (bill_id) REFERENCES public.bills(bill_id);
 D   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_bill_id_fkey;
       public          postgres    false    4745    217    219            �           2606    23007    orders orders_item_id_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.menus(item_id);
 D   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_item_id_fkey;
       public          postgres    false    222    4754    219            �           2606    22987    orders orders_table_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_table_id_fkey FOREIGN KEY (table_id) REFERENCES public.tables(table_id);
 E   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_table_id_fkey;
       public          postgres    false    4750    220    219            �           2606    22992    tables tables_area_id_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.tables
    ADD CONSTRAINT tables_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.areas(area_id);
 D   ALTER TABLE ONLY public.tables DROP CONSTRAINT tables_area_id_fkey;
       public          postgres    false    220    4752    221            7   W  x���OO�0��Χ�'@��?GZ�[*!@˅��5���AN�(�~'�=9=���y~�7#��JJ4�݆��%���~Y�����#�~��F�s=�oSץw~8����\�A#Py���Yƥ��B>��F5d *���C�#�L%Ǳ�Q68��Rl�w]��?�i�u�רA:�ؾ�)�]�c��"F	쩄���c�0���VғA�)�t�W��6���!	ڱm[�0�����8%�Q`�g7!���M��}�a4��f����QB~�ҊCVH��rؿX�&�M5�D� ��:%����Ʈ�������Tl�!��XJ,�"3��Z;t�0{J��!�|S�kD-*�JC�~�L�(�|�䫕�I���ڳ}���s(��$E�D�]ʧ!���^�]{'-q��C�;��o��u�J�Hm9�-E�sz��~�rL�����R|�6���yąz�i1=~�!�ǖj�^9���l?���(y	�^ �m�y�U�RÐ�ME[������TUt��m�#�e/�&'�:��P4���^/|\��w���,�l����j~���gb�n곤��id˹�Om	+k	5:���<�TUؼ\5M�@<��      =      x�3�,�,�2�,JM/�I,����� @�s      9   .  x��Yۑc;����	�oI�F���q��=�;U3_Va@�M#㍀��/���~#����������p���o@<U��~�}�$��$���lʴi�\o$���9%)u��� ;R�jm)�/���}YI5�y�D����HJϓ�9�@p32��un4K}x�&>��i��M����������Ѻ��Ii��_t�#�$u��y���ձ�p(��iC��zL�#Me����0s���E\�7L�)�����
|F�A�����̴�q�� �s!'rX�w�!���N��(GB��_︦����L GS|?M-��vw^
tV@�'�W#�|�	�:����Ө�!��#�43T|�ݬ���x���(��U<EdzMI��ų9QnD	
�P �(]��HATԧ	��D؉�Љq��}
w�ޔ='����x
��%d�LmJI�J}�5���z���
}r]JJ7��������_�*:X�9����dN�]ƽO'���`qj�E��jNO�&��`j:~�O��I�gӓ�t��q�'�Y3Hd��������DJ������f3*�]D��=�/-Y�:N͂��<獵O�yS9�)u��h|�7���%�YC;�s�՜ �ʚRi"بjAT垴�#��l�E�W��C�O<��I�ڋ����L�Ru�G��#���OA�3��uN ~ߧP�ߙW��C��X����Kl��?8yt!�6�e!��J��[ ���<[fE�����z�	�ջ��Co�(_^lg���fJ�$������n�m4��#)�N_x�0l9�MY<���>kF���g\-p�y���h#������^O���y��j�
�'�I�� �l=_�m"E��*��my���~~!��Q�c����� |�`k��H����V�ƐZZ�>��,�\�>�O�� ��c!Zw��Z��dN*Tۆ��'.��M�3)��A�c����5����>?ӄ����[x��
Uw?���A��_�x#��<�9�W��_�F�����S}�QRv?�a"�G*��q*0�䦹	W���u��!LQA�!vP��em����9)��:�7ϩ�1(�OV���!���jR�S�����^Q��(Q�w���
��L%����|A��q��k�۸��ǪH���^����k�`mכ�yNg�/��N�������.�^�/#�f��;�#"f����	��饼Y<�lb1�f}�FG�Z�y;jSҗ�Z���x�0@/���$?�{������}�x�^�P��W��hp���;~<q��sV)�g�~5�n��=(�PFy���;F���Z��!d�      @   f   x�s6�tK��̩�L,K��IL�I�43�r6���/K-RpI,��KG�4J� %�s�D�����.�9��H��\~Μd��l��XPP������Ĕ+F��� �.(�      ?   J  x�mR�N1�7_��y�L�CBE:DE�9��Y�ٖH�׳	�k�bƳ�3��Pg��,�Ø@n �P<�g�ԤZ@ݓ�)��(�&�����:�@.hU6F��mĬ�a�&
�9+X䴠l���c/<�������q���l�d��cVY�)�b�u	K��MrA���َD�'��/���Y$׶D�g���`[R�ϡ�0b[.�/﬒������
��Ѡ�ߌ�S��0��&c��z�c�5�c��<l��gQ�KtU�:�G��B����v�S�ޱ�V��O ӟ�z���u�U�鵏cC���o�#W������L&߅m��      A      x������ � �      >   �   x�-��C1kj� ���������N��O{bO��� ,��ayCX>�/��OxJ	O逧Tv�J�T�]�2�b���E�ص�ڨ��09,9"gɌ\%+�*��佼u�}������9�1<      ;   G
  x�]�K��(EǙ�鰑��3�V��_GߏpV��=���2����������z�w�s�s�����!	�ϝ��N��Ը�y�y��?������ht ���
�b�� ��g����w�ɿw>'��}�W2�N��g��tZ�m���� n��6�&���s�o?|n�|N?w>��6^���_��� 8�"%m6����%�~�O��F8=D�vA�Ԫ�t�`Z�����Hc�y�kb����{^j�����9G����E���6$���;�c (0_A�)�-��w.�"�WIĔ�o�����E�K��*{����夽���4L�$�8�����x�u���뗵���.�"�{(N�~��bab˦�{)�4?�H���zU��X6�2il�'h^6]&D�k=�{6�z��-����Z�(O����eۖ�f]�Y�&�D��j"��x� `X8�+���!��Vx2�]��5E\�\_��u߾��q(q! ��?��4�����6A�.������ɍVK0�~����2f!����k�������_d�.���/���T;�$S6������e��5�����Л����)��\-Q�LN�����>����T�)�Ĳ�"�E�b���%��c�sW2�x���6�����ڍ�woz�6Ho�����z���S.Ӱ�ۦFS	?3�yLa�tB��8�Q9w=�c�8�e��h2�����ܼ*��h[>/qo�����ߐhb?�]���x��?�D�;E�^�H�6v�B����΋��������B�7�ZF��j�w�B�^�d
��~���NGsp�L�eZF�t�wc�!��3��j�<�?�m���WJxC���ಹ��j�?����ok�#賟Uwhw�o��&��p�}�櫊&(x�.�ܙf��/� ���eƷA��U��9����x��A���NaV��sy��m�je�i�9h:�y�A�I�6�:)���y%t]�4AK(��y����Ā��*� �)9�+!����۸mL�=�RT���tƇ���銠A�SU�mi���#	5W��!����;�_�°/S��&!%0�1Q���F�E��mS������$��d��]�D\Az�~� v�Jn��]�UA7�isl����"<hz�v�k�rE<�)�t��.�pE� m���A���*oM�:���o��e԰���`
�4F\��O�j
�F������X��pU H$�箰����5]��T���av��[x�(˻�.^����_'�Os�/�2o�� t��pj ���1Do���R��;��~h�?V���j� ���}jm�^U��!�]K�g'H<��V��'Zz�aN+U��w�'���Dl��J�{��k���gC�zjP�Cڎ�f�.H{�������)�}R���w���}�|({�Q�{ټosyC؁ϻ ���Hc΢ !��2�zy-C�i�E����J|�\B^�u�hWH��ፐ���"�Aҁ��C��5�|��A�ɮ��
�˵��䒱A։Y�m�g�>T��׸kC 6�ǂPu��d�I]FDdD@��M���q@ׅQ��C�������*U����]��)c�|����DL����N�]��p=fzo�*ć�4� ���5{hy�)��>�s�	����+��G��r�ބS��m��W+Mm��6��d8��}����}�:c�5���= �C�nD �CU�	�g��hQ#.Yﺿ
h���S�,���Ž1���5�}��X�}�:=C��~
����]7{B�^^w�I�
POK�u���_��t%#_H���#M%*:�s�(��\G5D@�)1�S
���ZkL�\����57�Ō��{����=��x>�:�i�J)���U��b�Rl�<� ��F`�g�9�e����B�?u�y~�N�|��	�Q7�x�s?�Jz���Ib�K�KH#]���%���+�|J��0��s�Y��,L���@��<Eb@ȧ.Q��Pr�=/q�G-�9k@��z6���#��]�9��;�9��pʽv߀����*r��oA�u����E��Ǽm�lNh����~a�~��2���>�����2ޘơqO��0�s�faB��S�о��ඹΜ��V{.�.ߦ��[�5!�!k;�v�����MN�I&������iڏ+:�[Y�����K�.W���v�-D��m>)$D})�MgxF4��5~�T�/oq-߄�˼j�!�kV�Gs#>��/�I5������&!�������i�$�C����~|�B�}�ev����ϐ�	�T7!��I�|�_h�!�B���Z���>!���\�oB�w�Bw��Kj���:	}ߺ6�1E�l�Tڟ����FG��5EB��^� ��푋���V�"!Uu�� �;�cDB�w<UsB�i]���� �ʧ:M��>O��a}��m4A�w:K�
q��ʿR4�O�	m�l��]؍���kX�i�$߅�pJ�:�%��A��Z����]،wawQ���Z�������,����Gt����A=��[GS��P���^V
t�\��\�&�s�s�����OŝԽ}��vݶ���z
��Ӽ/s�o���Y��.�v��y����3J	      <   E   x�5���0���0E�mw��s4p�����-��=6'��X
��v�/��Vg�G��*�vk��] ~���     