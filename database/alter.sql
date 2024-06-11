ALTER TABLE "bills" ADD FOREIGN KEY ("phone") REFERENCES "accounts" ("phone");

ALTER TABLE "orders" ADD FOREIGN KEY ("bill_id") REFERENCES "bills" ("bill_id");

ALTER TABLE "orders" ADD FOREIGN KEY ("table_id") REFERENCES "tables" ("table_id");

ALTER TABLE "tables" ADD FOREIGN KEY ("area_id") REFERENCES "areas" ("area_id");

ALTER TABLE "join_food_combos" ADD FOREIGN KEY ("food_id") REFERENCES "foods" ("food_id");

ALTER TABLE "join_food_combos" ADD FOREIGN KEY ("combo_id") REFERENCES "combos" ("combo_id");

ALTER TABLE "orders" ADD FOREIGN KEY ("item_id") REFERENCES "menus" ("item_id") ;

ALTER TABLE "menus" ADD FOREIGN KEY ("food_id") REFERENCES "foods" ("food_id") ;

ALTER TABLE "menus" ADD FOREIGN KEY ("combo_id") REFERENCES "combos" ("combo_id") ;