-- MIGRATION: SEED INVENTORY FROM EXCEL
DO $$
DECLARE
  cat_id UUID;
  prod_id UUID;
BEGIN
  -- zino SHAKA KHAFIS  dambeTX400 (60223)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zino SHAKA KHAFIS  dambeTX400 (60223)', '60223', cat_id, 'TX400', 'unknown', 58.0, 85.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- zinoSHAKA KHAFIS   hore TX400 (6022)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zinoSHAKA KHAFIS   hore TX400 (6022)', '6022', cat_id, 'TX400', 'unknown', 58.0, 85.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- SHAKA KHAFIS 371 hore 30283
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHAKA KHAFIS 371 hore 30283', NULL, cat_id, '371', 'unknown', 45.0, 60.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- SHAKA KHAFIS 371 dambe 40088
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHAKA KHAFIS 371 dambe 40088', NULL, cat_id, '371', 'unknown', 45.0, 60.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- filtar dheer naafato 80311  org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar dheer naafato 80311  org', NULL, cat_id, 'General', 'original', 18.0, 25.0, 18, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 18, 0, 18, 'Excel Migration');
  -- filtar saliid 70005 org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar saliid 70005 org', NULL, cat_id, 'General', 'original', 5.0, 7.0, 25, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 25, 0, 25, 'Excel Migration');
  -- filtar naafato gaaban 80012
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar naafato gaaban 80012', NULL, cat_id, 'General', 'unknown', 13.0, 18.0, 17, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 17, 0, 17, 'Excel Migration');
  -- filtar naafato TX400 ORG (TR22384)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar naafato TX400 ORG (TR22384)', NULL, cat_id, 'TX400', 'original', 7.5, 15.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- filtar saliid TX400 70031 org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar saliid TX400 70031 org', NULL, cat_id, 'TX400', 'original', 8.0, 15.0, 42, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 42, 0, 42, 'Excel Migration');
  -- rabadh kaabaan EOM 20278
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rabadh kaabaan EOM 20278', NULL, cat_id, 'General', 'unknown', 80.0, 110.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- SINO BUUSH XIDHIIDHIYE HOOSE ORG 21177
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SINO BUUSH XIDHIIDHIYE HOOSE ORG 21177', NULL, cat_id, 'Sino', 'original', 28.0, 40.0, 16, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 16, 0, 16, 'Excel Migration');
  -- KAANWEYS DAMBE 12GOD ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAANWEYS DAMBE 12GOD ORG', NULL, cat_id, 'General', 'original', 33.0, 55.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- KAAWEYS DAMBE 14 GODLE ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAAWEYS DAMBE 14 GODLE ORG', NULL, cat_id, 'General', 'original', 33.0, 55.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- KAANWEYS HORE TX400  ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAANWEYS HORE TX400  ORG', NULL, cat_id, 'TX400', 'original', 25.0, 50.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- KAAWEYS HORE 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAAWEYS HORE 371', NULL, cat_id, '371', 'unknown', 25.0, 45.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- BUUSH KAABAN ORG shiimisyo 20078
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BUUSH KAABAN ORG shiimisyo 20078', NULL, cat_id, 'General', 'original', 1.5, 4.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- SHID FAREEN IGSAL ORG TX40 50002
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHID FAREEN IGSAL ORG TX40 50002', NULL, cat_id, 'General', 'original', 39.0, 80.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- SHID FAREEN IGSAL ORG 371 410031
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHID FAREEN IGSAL ORG 371 410031', NULL, cat_id, '371', 'original', 25.0, 45.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- FILTER QACAAYAD ORG 3286
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('FILTER QACAAYAD ORG 3286', NULL, cat_id, 'General', 'original', 7.0, 15.0, 16, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 16, 0, 16, 'Excel Migration');
  -- TUUBO NAAFATO 371 ORG 3 NOOC (80017) (80018) (80019)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('TUUBO NAAFATO 371 ORG 3 NOOC (80017) (80018) (80019)', '80017', cat_id, '371', 'original', 5.5, 20.0, 24, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 24, 0, 24, 'Excel Migration');
  -- TUUBO NAAFATO TX400 ORG 50021
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('TUUBO NAAFATO TX400 ORG 50021', NULL, cat_id, 'TX400', 'original', 8.0, 16.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- SHIDH POWER ORG 70228
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHIDH POWER ORG 70228', NULL, cat_id, 'General', 'original', 14.0, 35.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- HAAN KALIISH ORG 30041
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('HAAN KALIISH ORG 30041', NULL, cat_id, 'General', 'original', 8.0, 110.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- BADHAD GIIJIYE 371 60313
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD GIIJIYE 371 60313', NULL, cat_id, '371', 'unknown', 17.0, 35.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- BADHAD MISHIIN 371 ORG 8BK1050
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD MISHIIN 371 ORG 8BK1050', NULL, cat_id, '371', 'original', 9.0, 18.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- BADHAD AC ORG -6BK1020
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD AC ORG -6BK1020', '6BK1020', cat_id, 'General', 'original', 7.5, 15.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- BADHAD DAYNABO ORG -6BK783
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD DAYNABO ORG -6BK783', '6BK783', cat_id, 'General', 'original', 7.5, 15.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- MURAADYAD HAAD ORG 371 -5005
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Muraadyad Haad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('MURAADYAD HAAD ORG 371 -5005', '5005', cat_id, '371', 'original', 60.0, 80.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- MURAADYAD HAAD ORG TX 400 -7025 - 7021
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Muraadyad Haad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('MURAADYAD HAAD ORG TX 400 -7025 - 7021', '7021', cat_id, 'TX400', 'original', 60.0, 85.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- KHASHAAFAD  371 ORG - 90102
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KHASHAAFAD  371 ORG - 90102', '90102', cat_id, '371', 'original', 60.0, 80.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- KHASHAAFAD  336 ORG -90001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KHASHAAFAD  336 ORG -90001', '90001', cat_id, '336', 'original', 60.0, 75.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- KHASHAAFAD  TX400  ORG - 90061
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KHASHAAFAD  TX400  ORG - 90061', '90061', cat_id, 'TX400', 'original', 78.0, 100.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- INDHO HORE 371 ORG -20002 - 20001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO HORE 371 ORG -20002 - 20001', '20001', cat_id, '371', 'original', 80.0, 95.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- INDHO TURUS 371 ORG - 200025  - 200026
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO TURUS 371 ORG - 200025  - 200026', '200026', cat_id, '371', 'original', 32.0, 40.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- INDHO TURUS TX 400 ORG -6002
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO TURUS TX 400 ORG -6002', '6002', cat_id, 'TX400', 'original', 25.0, 40.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- INDHO HORE TX 400 ORG - 6001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO HORE TX 400 ORG - 6001', '6001', cat_id, 'TX400', 'original', 60.0, 90.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- BUUSH SABARAD KHAFIS YARE 371 ORG -30263
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BUUSH SABARAD KHAFIS YARE 371 ORG -30263', '30263', cat_id, '371', 'original', 2.0, 4.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- BUUSH SABARAD KHAFIS WEYN  371 ORG -30061
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BUUSH SABARAD KHAFIS WEYN  371 ORG -30061', '30061', cat_id, '371', 'original', 3.9, 7.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- BOLTAAYIR TX400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOLTAAYIR TX400', NULL, cat_id, 'TX400', 'unknown', 2.2, 5.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- BOLTAAYIR 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOLTAAYIR 371', NULL, cat_id, '371', 'unknown', 3.8, 5.0, 25, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 25, 0, 25, 'Excel Migration');
  -- LAMDAD HOBOS DAMBE ORG -190*220*30
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('LAMDAD HOBOS DAMBE ORG -190*220*30', NULL, cat_id, 'General', 'original', 7.0, 15.0, 18, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 18, 0, 18, 'Excel Migration');
  -- LAMDAD HOBOS HORE  ORG  -140*160*13
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('LAMDAD HOBOS HORE  ORG  -140*160*13', NULL, cat_id, 'General', 'original', 4.0, 8.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- LAMDAD KOMBOROSOL juundo -32*52*7
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('LAMDAD KOMBOROSOL juundo -32*52*7', NULL, cat_id, 'General', 'unknown', 3.8, 8.0, 16, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 16, 0, 16, 'Excel Migration');
  -- BOOLBEERIN CANDHO 6312N ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Boolbeerin' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOOLBEERIN CANDHO 6312N ORG', NULL, cat_id, 'General', 'original', 13.0, 35.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- KILIISH IMADAX 2MADAX ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kiliish / Okiyo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KILIISH IMADAX 2MADAX ORG', NULL, cat_id, 'General', 'original', 12.0, 25.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- SIIQ LEEWAR 371 ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SIIQ LEEWAR 371 ORG', NULL, cat_id, '371', 'original', 28.0, 37.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- SIIQ LEEWAR 371 COPY
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SIIQ LEEWAR 371 COPY', NULL, cat_id, '371', 'copy', 4.0, 10.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- BOOLXIDHIDHIYE DHER ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOOLXIDHIDHIYE DHER ORG', NULL, cat_id, 'General', 'original', 3.0, 5.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- BOOLXIDHIDHIYE GAABAN ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOOLXIDHIDHIYE GAABAN ORG', NULL, cat_id, 'General', 'original', 2.0, 5.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- ISBIRIINO KAAWEYS ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ISBIRIINO KAAWEYS ORG', NULL, cat_id, 'General', 'original', 1.5, 4.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- XIDHIIDHIYE V -29272
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XIDHIIDHIYE V -29272', '29272', cat_id, 'General', 'unknown', 70.0, 100.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- RAMOODH OKIYO
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kiliish / Okiyo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('RAMOODH OKIYO', NULL, cat_id, 'General', 'unknown', 75.0, 110.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- CALEEN LAALAAD -30034
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('CALEEN LAALAAD -30034', '30034', cat_id, 'General', 'unknown', 12.0, 20.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- KILIIB TURUBO 3 NOOC -19215*19216*80060
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KILIIB TURUBO 3 NOOC -19215*19216*80060', NULL, cat_id, 'General', 'unknown', 2.2, 6.0, 15, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 15, 0, 15, 'Excel Migration');
  -- KOBAAL HORE 35 -
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KOBAAL HORE 35 -', NULL, cat_id, 'General', 'unknown', 6.5, 15.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- SIIQ LEEWAR ORG TX400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SIIQ LEEWAR ORG TX400', NULL, cat_id, 'TX400', 'original', 28.0, 35.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- zino SANTARA BOOL HORE
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zino SANTARA BOOL HORE', NULL, cat_id, 'Sino', 'unknown', 2.0, 4.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- SALIID DELO 1LITIR DIESEL
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID DELO 1LITIR DIESEL', NULL, cat_id, 'General', 'unknown', 2.9, 3.5, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- SALIID PETROL HAVOLINE ONE LITER
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID PETROL HAVOLINE ONE LITER', NULL, cat_id, 'General', 'unknown', 2.9, 3.5, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- SALIID PETROL HAVOLINE 4 LITER
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID PETROL HAVOLINE 4 LITER', NULL, cat_id, 'General', 'unknown', 11.0, 15.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- SALIID  CASTROL 25 LITER
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID  CASTROL 25 LITER', NULL, cat_id, 'General', 'unknown', 95.0, 110.0, 12, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 12, 0, 12, 'Excel Migration');
  -- XAYDH TASQIYAD
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XAYDH TASQIYAD', NULL, cat_id, 'General', 'unknown', 3.75, 6.0, 12, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 12, 0, 12, 'Excel Migration');
  -- XAYDH HOBOS
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XAYDH HOBOS', NULL, cat_id, 'General', 'unknown', 3.75, 6.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- XAYDH HOBOS YAR YAR
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XAYDH HOBOS YAR YAR', NULL, cat_id, 'General', 'unknown', 2.4, 3.5, 46, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 46, 0, 46, 'Excel Migration');
  -- BALASH DHEHA YAR
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BALASH DHEHA YAR', NULL, cat_id, 'General', 'unknown', 1.25, 3.0, 18, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 18, 0, 18, 'Excel Migration');
  -- SALIID BAREEK
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID BAREEK', NULL, cat_id, 'General', 'unknown', 1.1, 1.0, 17, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 17, 0, 17, 'Excel Migration');
  -- SALIID HAYDAROOLIK
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID HAYDAROOLIK', NULL, cat_id, 'General', 'unknown', 1.5, 2.5, 11, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 11, 0, 11, 'Excel Migration');
  -- ISTEERIN GAADHI
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ISTEERIN GAADHI', NULL, cat_id, 'General', 'unknown', 2.4, 5.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- AIR FRESH biif
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('AIR FRESH biif', NULL, cat_id, 'General', 'unknown', 0.25, 2.0, 7, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 7, 0, 7, 'Excel Migration');
  -- FUSE CARD WEYN
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('FUSE CARD WEYN', NULL, cat_id, 'General', 'unknown', 0.35, 1.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- DAWO DAXAL
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWO DAXAL', NULL, cat_id, 'General', 'unknown', 1.16, 2.0, 13, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 13, 0, 13, 'Excel Migration');
  -- DAWO KARBEYDHAR
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWO KARBEYDHAR', NULL, cat_id, 'General', 'unknown', 1.0, 2.0, 15, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 15, 0, 15, 'Excel Migration');
  -- air kawar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('air kawar', NULL, cat_id, 'General', 'unknown', 1.1, 1.0, 31, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 31, 0, 31, 'Excel Migration');
  -- DAWODIESAL
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWODIESAL', NULL, cat_id, 'General', 'unknown', 1.66, 3.0, 12, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 12, 0, 12, 'Excel Migration');
  -- DAWO PETRO
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWO PETRO', NULL, cat_id, 'General', 'unknown', 1.16, 2.5, 12, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 12, 0, 12, 'Excel Migration');
  -- XABAG BAATIN BLACK
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XABAG BAATIN BLACK', NULL, cat_id, 'General', 'unknown', 1.16, 2.0, 7, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 7, 0, 7, 'Excel Migration');
  -- ISKU DAR 5 MINI
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ISKU DAR 5 MINI', NULL, cat_id, 'General', 'unknown', 1.16, 2.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- DHASH BAALASH
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DHASH BAALASH', NULL, cat_id, 'General', 'unknown', 1.16, 2.0, 15, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 15, 0, 15, 'Excel Migration');
  -- xadhig waayar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('xadhig waayar', NULL, cat_id, 'General', 'unknown', 0.0, 1.5, 90, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 90, 0, 90, 'Excel Migration');
  -- lambad 10 watt
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('lambad 10 watt', NULL, cat_id, 'General', 'unknown', 0.7, 2.0, 24, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 24, 0, 24, 'Excel Migration');
  -- fiish
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('fiish', NULL, cat_id, 'General', 'unknown', 1.0, 1.5, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- iswiij
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('iswiij', NULL, cat_id, 'General', 'unknown', 1.0, 1.5, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- lamp holder
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('lamp holder', NULL, cat_id, 'General', 'unknown', 0.29, 1.0, 40, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 40, 0, 40, 'Excel Migration');
  -- indhaha dhinaca
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indhaha dhinaca', NULL, cat_id, 'General', 'unknown', 2.4, 4.0, 54, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 54, 0, 54, 'Excel Migration');
  -- sino dhagax camuud -20042
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino dhagax camuud -20042', '20042', cat_id, 'Sino', 'unknown', 60.0, 80.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- sino buush camuud -20191
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush camuud -20191', '20191', cat_id, 'Sino', 'unknown', 23.0, 35.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino weysar sabarad khafis -30263
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino weysar sabarad khafis -30263', '30263', cat_id, 'Sino', 'unknown', 2.0, 4.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- sino  biin shakal -30239
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino  biin shakal -30239', '30239', cat_id, 'Sino', 'unknown', 2.0, 4.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- sino bool beerin feeran igsal 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino bool beerin feeran igsal 371', NULL, cat_id, '371', 'unknown', 2.0, 9.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- sino malqacaad bireeg l L and R -40057(L) - 40056(R)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino malqacaad bireeg l L and R -40057(L) - 40056(R)', NULL, cat_id, 'Sino', 'unknown', 14.0, 20.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- sino connector4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino connector4', NULL, cat_id, 'Sino', 'unknown', 0.5, 1.0, 50, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 50, 0, 50, 'Excel Migration');
  -- connector6
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector6', NULL, cat_id, 'General', 'unknown', 0.5, 1.0, 50, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 50, 0, 50, 'Excel Migration');
  -- connector8
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector8', NULL, cat_id, 'General', 'unknown', 0.5, 1.0, 50, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 50, 0, 50, 'Excel Migration');
  -- connector10
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector10', NULL, cat_id, 'General', 'unknown', 0.5, 1.0, 49, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 49, 0, 49, 'Excel Migration');
  -- connector12
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector12', NULL, cat_id, 'General', 'unknown', 0.5, 1.0, 48, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 48, 0, 48, 'Excel Migration');
  -- sino lamdad camuud weyn -160*194*10.5
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lamdad camuud weyn -160*194*10.5', NULL, cat_id, 'Sino', 'unknown', 4.5, 10.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- sino lamdad camuud yar -160*185*10.5
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lamdad camuud yar -160*185*10.5', NULL, cat_id, 'Sino', 'unknown', 4.0, 8.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- tuumbo naqas 4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 4', NULL, cat_id, 'General', 'unknown', 15.0, 1.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- tuumbo naqas 6
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 6', NULL, cat_id, 'General', 'unknown', 18.0, 1.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- tuumbo naqas 8
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 8', NULL, cat_id, 'General', 'unknown', 18.0, 1.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- tuumbo naqas 10
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 10', NULL, cat_id, 'General', 'unknown', 25.0, 1.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- tuumbo naqas 12
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 12', NULL, cat_id, 'General', 'unknown', 25.0, 1.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- sino bogos kileesh asli -30023
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino bogos kileesh asli -30023', '30023', cat_id, 'Sino', 'original', 28.0, 40.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- sino buush afargees yar  20221
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush afargees yar  20221', NULL, cat_id, 'Sino', 'unknown', 1.8, 4.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- sino buush afargees weyn -20159
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush afargees weyn -20159', '20159', cat_id, 'Sino', 'unknown', 1.8, 4.0, 16, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 16, 0, 16, 'Excel Migration');
  -- muraayad gool TX400 -6656
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('muraayad gool TX400 -6656', '6656', cat_id, 'TX400', 'unknown', 25.0, 37.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- muraayad gool 371  -70010
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('muraayad gool 371  -70010', '70010', cat_id, '371', 'unknown', 5.0, 10.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino guluub H4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino guluub H4', NULL, cat_id, 'Sino', 'unknown', 2.0, 3.0, 19, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 19, 0, 19, 'Excel Migration');
  -- sino guluub H3
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino guluub H3', NULL, cat_id, 'Sino', 'unknown', 1.5, 3.0, 17, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 17, 0, 17, 'Excel Migration');
  -- sino guluub H1
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino guluub H1', NULL, cat_id, 'Sino', 'unknown', 1.5, 3.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino shaandho naqas -60521
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino shaandho naqas -60521', '60521', cat_id, 'Sino', 'unknown', 19.0, 30.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- bam xaydh 1 kg
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bam xaydh 1 kg', NULL, cat_id, 'General', 'unknown', 6.5, 26.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- okiyo gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kiliish / Okiyo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('okiyo gaadhi', NULL, cat_id, 'General', 'unknown', 60.0, 110.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- bool gudban
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bool gudban', NULL, cat_id, 'General', 'unknown', 20.0, 30.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- bool rimool
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bool rimool', NULL, cat_id, 'General', 'unknown', 2.65, 10.0, 13, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 13, 0, 13, 'Excel Migration');
  -- rabadh tiimone
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rabadh tiimone', NULL, cat_id, 'General', 'unknown', 3.3, 10.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- bool garbo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bool garbo', NULL, cat_id, 'General', 'unknown', 24.9, 40.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- buush x.rimool
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush x.rimool', NULL, cat_id, 'General', 'unknown', 3.99, 10.0, 19, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 19, 0, 19, 'Excel Migration');
  -- baanad 10mm (20370)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanad 10mm (20370)', '20370', cat_id, 'General', 'unknown', 0.7, 1.5, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- baanad dh/ baraas 17mm ( 20440) china
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanad dh/ baraas 17mm ( 20440) china', NULL, cat_id, 'General', 'unknown', 1.2, 2.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- filter gaadhi yar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filter gaadhi yar', NULL, cat_id, 'General', 'unknown', 0.91, 1.5, 26, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 26, 0, 26, 'Excel Migration');
  -- dismis faseex
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dismis faseex', NULL, cat_id, 'General', 'unknown', 5.9, 1.5, 23, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 23, 0, 23, 'Excel Migration');
  -- silisteeb
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('silisteeb', NULL, cat_id, 'General', 'unknown', 0.3, 0.5, 24, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 24, 0, 24, 'Excel Migration');
  -- buush raam hore -80035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush raam hore -80035', '80035', cat_id, 'General', 'unknown', 3.5, 6.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- buush raam dambe -80035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush raam dambe -80035', '80035', cat_id, 'General', 'unknown', 3.5, 6.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- buush raam ramoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush raam ramoodh', NULL, cat_id, 'General', 'unknown', 3.5, 6.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- xabag cad 99
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('xabag cad 99', NULL, cat_id, 'General', 'unknown', 1.5, 2.0, 12, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 12, 0, 12, 'Excel Migration');
  -- wood xabag cad loox
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('wood xabag cad loox', NULL, cat_id, 'General', 'unknown', 1.3, 2.5, 21, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 21, 0, 21, 'Excel Migration');
  -- sino filter saliid 70005
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter saliid 70005', NULL, cat_id, 'Sino', 'unknown', 3.0, 8.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- sino filter naafato 80012
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter naafato 80012', NULL, cat_id, 'Sino', 'unknown', 3.0, 8.0, 16, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 16, 0, 16, 'Excel Migration');
  -- sino filter dheer 80311
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter dheer 80311', NULL, cat_id, 'Sino', 'unknown', 5.0, 12.0, 18, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 18, 0, 18, 'Excel Migration');
  -- sino filter saliid TX400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter saliid TX400', NULL, cat_id, 'TX400', 'unknown', 5.5, 14.0, 14, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 14, 0, 14, 'Excel Migration');
  -- sino filter naafato1334
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter naafato1334', NULL, cat_id, 'Sino', 'unknown', 4.0, 14.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- biin rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('biin rimoodh', NULL, cat_id, 'General', 'unknown', 19.0, 30.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- rabadh rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rabadh rimoodh', NULL, cat_id, 'General', 'unknown', 0.9, 10.0, 12, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 12, 0, 12, 'Excel Migration');
  -- buush jiide  rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush jiide  rimoodh', NULL, cat_id, 'General', 'unknown', 3.5, 7.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- buushka okiyada
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buushka okiyada', NULL, cat_id, 'General', 'unknown', 5.5, 10.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- haraaqo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('haraaqo', NULL, cat_id, 'General', 'unknown', 1.0, 1.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- dhanbaraas 12
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 12', NULL, cat_id, 'General', 'unknown', 0.85, 2.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- dhanbaraas 13
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 13', NULL, cat_id, 'General', 'unknown', 0.9, 2.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- dhanbaraas 14
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 14', NULL, cat_id, 'General', 'unknown', 0.95, 2.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- dhanbaraas 17
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 17', NULL, cat_id, 'General', 'unknown', 1.3, 2.5, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- dhanbaraas 19
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 19', NULL, cat_id, 'General', 'unknown', 1.5, 3.5, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- dhanbaraas 22
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 22', NULL, cat_id, 'General', 'unknown', 2.1, 3.5, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- dhanbaraas 24
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 24', NULL, cat_id, 'General', 'unknown', 2.55, 4.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- dhanbaraas 27
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 27', NULL, cat_id, 'General', 'unknown', 3.0, 4.5, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- dhanbaraas 30
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 30', NULL, cat_id, 'General', 'unknown', 3.5, 5.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- dhagax moole jare9"
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhagax moole jare9"', NULL, cat_id, 'General', 'unknown', 2.5, 3.5, 30, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 30, 0, 30, 'Excel Migration');
  -- laxaamad 3.2
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('laxaamad 3.2', NULL, cat_id, 'General', 'unknown', 1.0, 6.5, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- baaleys 220
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baaleys 220', NULL, cat_id, 'General', 'unknown', 0.3, 1.0, 98, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 98, 0, 98, 'Excel Migration');
  -- baaleys 60
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baaleys 60', NULL, cat_id, 'General', 'unknown', 0.32, 1.0, 94, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 94, 0, 94, 'Excel Migration');
  -- dhagax mole qore 9
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhagax mole qore 9', NULL, cat_id, 'General', 'unknown', 3.2, 5.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- dhagax qore 7
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhagax qore 7', NULL, cat_id, 'General', 'unknown', 1.8, 3.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- saliid euro
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('saliid euro', NULL, cat_id, 'General', 'unknown', 67.0, 90.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- daawe gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('daawe gaadhi', NULL, cat_id, 'General', 'unknown', 75.0, 120.0, 0, 5, 'active')
  RETURNING id INTO prod_id;
  -- tuubyo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuubyo', NULL, cat_id, 'General', 'unknown', 18.0, 22.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- ban xaydh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ban xaydh', NULL, cat_id, 'General', 'unknown', 5.5, 15.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- baanado ula weyne
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanado ula weyne', NULL, cat_id, 'General', 'unknown', 75.0, 110.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- tuunbo xaydh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuunbo xaydh', NULL, cat_id, 'General', 'unknown', 1.5, 3.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- baanad ula yare
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanad ula yare', NULL, cat_id, 'General', 'unknown', 20.0, 45.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- galaas baston riin creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('galaas baston riin creaket', NULL, cat_id, 'General', 'unknown', 1000.0, 1200.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- baakin dhan creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baakin dhan creaket', NULL, cat_id, 'General', 'unknown', 230.0, 150.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- 7121463701fooshad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('7121463701fooshad', NULL, cat_id, 'General', 'unknown', 40.0, 185.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- ck8415 salaf creaket 11/15
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8415 salaf creaket 11/15', NULL, cat_id, 'General', 'unknown', 195.0, 250.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- ck8415 salaf creaket 11/14
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8415 salaf creaket 11/14', NULL, cat_id, 'General', 'unknown', 195.0, 250.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- ck8139 shidh f.igsal
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8139 shidh f.igsal', NULL, cat_id, 'General', 'unknown', 55.0, 90.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- 30x32 sheeg baane
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('30x32 sheeg baane', NULL, cat_id, 'General', 'unknown', 12.0, 25.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- 32x33  sheeg baane
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('32x33  sheeg baane', NULL, cat_id, 'General', 'unknown', 12.0, 25.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- ck8597 rabadh jen creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8597 rabadh jen creaket', NULL, cat_id, 'General', 'unknown', 41.0, 135.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- 9125521174 xidhiidhiye qaloca
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9125521174 xidhiidhiye qaloca', NULL, cat_id, 'General', 'unknown', 50.0, 75.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- 614040021 bakin dhaban creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('614040021 bakin dhaban creaket', NULL, cat_id, 'General', 'unknown', 1.3, 2.5, 18, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 18, 0, 18, 'Excel Migration');
  -- 60080218 hand pump creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('60080218 hand pump creaket', NULL, cat_id, 'General', 'unknown', 6.0, 15.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- ck 8010 bambaji creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck 8010 bambaji creaket', NULL, cat_id, 'General', 'unknown', 30.0, 45.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- 60313 badhad giije creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('60313 badhad giije creaket', NULL, cat_id, 'General', 'unknown', 40.0, 65.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- 9231320271 dhiif candho cadi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9231320271 dhiif candho cadi', NULL, cat_id, 'General', 'unknown', 115.0, 145.0, 0, 5, 'active')
  RETURNING id INTO prod_id;
  -- 9231320261 sabarad dhiif copy
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9231320261 sabarad dhiif copy', NULL, cat_id, 'General', 'copy', 30.0, 70.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- 1642870231  fooshad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642870231  fooshad', NULL, cat_id, 'General', 'unknown', 24.0, 80.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- saliid qatol
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('saliid qatol', NULL, cat_id, 'General', 'unknown', 45.0, 14.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- 600 kobaal fo6
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('600 kobaal fo6', NULL, cat_id, 'General', 'unknown', 6.2, 10.0, 7, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 7, 0, 7, 'Excel Migration');
  -- 600-32 kobaal dambe
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('600-32 kobaal dambe', NULL, cat_id, 'General', 'unknown', 10.0, 15.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- 50 ton jeeg dheer
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('50 ton jeeg dheer', NULL, cat_id, 'General', 'unknown', 43.0, 60.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- 32 ton jeeg
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('32 ton jeeg', NULL, cat_id, 'General', 'unknown', 30.0, 40.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- 1642340002 gacan albaab
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642340002 gacan albaab', NULL, cat_id, 'General', 'unknown', 9.0, 25.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- 1642340015 siiq daaqad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642340015 siiq daaqad', NULL, cat_id, 'General', 'unknown', 5.0, 14.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- 1642340014 siiq daaqad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642340014 siiq daaqad', NULL, cat_id, 'General', 'unknown', 5.0, 14.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- 1500090039 booldaynabo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1500090039 booldaynabo', NULL, cat_id, 'General', 'unknown', 7.0, 12.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- 6800340015 fasexad hobos
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('6800340015 fasexad hobos', NULL, cat_id, 'General', 'unknown', 1.5, 4.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- 1857 automatic salaf
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1857 automatic salaf', NULL, cat_id, 'General', 'unknown', 24.0, 40.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- 9925530058 hosbeeb kular
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9925530058 hosbeeb kular', NULL, cat_id, 'General', 'unknown', 12.0, 18.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- 1500119215 clip tuubo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1500119215 clip tuubo', NULL, cat_id, 'General', 'unknown', 2.0, 5.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- 9725520227 bool xidhiidhiye
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9725520227 bool xidhiidhiye', NULL, cat_id, 'General', 'unknown', 2.0, 5.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- 420 bool santar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('420 bool santar', NULL, cat_id, 'General', 'unknown', 3.2, 7.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- sino footari
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino footari', NULL, cat_id, 'Sino', 'unknown', 1.5, 5.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- sino waysar diif 10 god
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar diif 10 god', NULL, cat_id, 'Sino', 'unknown', 3.5, 7.0, 6, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 6, 0, 6, 'Excel Migration');
  -- sino cidi dhiif 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino cidi dhiif 371', NULL, cat_id, '371', 'unknown', 3.8, 7.0, 14, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 14, 0, 14, 'Excel Migration');
  -- sino waysar canjalada dhiif tx400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar canjalada dhiif tx400', NULL, cat_id, 'TX400', 'unknown', 1.5, 5.0, 24, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 24, 0, 24, 'Excel Migration');
  -- sino waysar dhiif 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar dhiif 371', NULL, cat_id, '371', 'unknown', 3.5, 7.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- sino waysar hawsisn 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar hawsisn 371', NULL, cat_id, '371', 'unknown', 3.5, 7.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino canjald dhiif wayn 20040
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino canjald dhiif wayn 20040', NULL, cat_id, 'Sino', 'unknown', 19.0, 40.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- sino canjald dhiif yar 0035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino canjald dhiif yar 0035', NULL, cat_id, 'Sino', 'unknown', 9.0, 20.0, 17, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 17, 0, 17, 'Excel Migration');
  -- sino afar gees tx400 0035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino afar gees tx400 0035', NULL, cat_id, 'TX400', 'unknown', 20.0, 40.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino afar gees tx400 0044
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino afar gees tx400 0044', NULL, cat_id, 'TX400', 'unknown', 20.0, 40.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino waysar hawsin tx400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar hawsin tx400', NULL, cat_id, 'TX400', 'unknown', 3.8, 7.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- weysaro bir ah
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('weysaro bir ah', NULL, cat_id, 'General', 'unknown', 1.0, 7.0, 12, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 12, 0, 12, 'Excel Migration');
  -- sino lamdad candho -85*105*8
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lamdad candho -85*105*8', NULL, cat_id, 'Sino', 'unknown', 3.8, 10.0, 15, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 15, 0, 15, 'Excel Migration');
  -- sino waysar candho caag -20153
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar candho caag -20153', '20153', cat_id, 'Sino', 'unknown', 1.0, 5.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- rinoodh baraasad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rinoodh baraasad', NULL, cat_id, 'General', 'unknown', 20.0, 40.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- rinoodh baraasad org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rinoodh baraasad org', NULL, cat_id, 'General', 'original', 20.0, 80.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- sino sabarad dhiif asli -20135
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino sabarad dhiif asli -20135', '20135', cat_id, 'Sino', 'original', 90.0, 130.0, 0, 5, 'active')
  RETURNING id INTO prod_id;
  -- sino dhiif dhan asli -20271
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino dhiif dhan asli -20271', '20271', cat_id, 'Sino', 'original', 380.0, 550.0, 0, 5, 'active')
  RETURNING id INTO prod_id;
  -- SINO Kabiin kaaban -520065
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SINO Kabiin kaaban -520065', '520065', cat_id, 'Sino', 'unknown', 3.5, 6.0, 11, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 11, 0, 11, 'Excel Migration');
  -- tasqiyado
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tasqiyado', NULL, cat_id, 'General', 'unknown', 0.19, 0.5, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- zino dhaban dabka --11137
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zino dhaban dabka --11137', '11137', cat_id, 'Sino', 'unknown', 90.0, 230.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- tuumbo biriig  -60450
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo biriig  -60450', '60450', cat_id, 'General', 'unknown', 5.0, 10.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- caleen kaban hore -20007
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('caleen kaban hore -20007', '20007', cat_id, 'General', 'unknown', 25.0, 50.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- ac komborosool -39016
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ac komborosool -39016', '39016', cat_id, 'General', 'unknown', 80.0, 160.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- bastoon leeawr -70014
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bastoon leeawr -70014', '70014', cat_id, 'General', 'unknown', 12.0, 25.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- lafta xaraar -90061
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('lafta xaraar -90061', '90061', cat_id, 'General', 'unknown', 3.5, 7.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- taangi  naafato
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('taangi  naafato', NULL, cat_id, 'General', 'unknown', 285.0, 415.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- rimoodh daran wayne-77630
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rimoodh daran wayne-77630', '77630', cat_id, 'General', 'unknown', 9.0, 390.0, 0, 5, 'active')
  RETURNING id INTO prod_id;
  -- buush canjalad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush canjalad', NULL, cat_id, 'General', 'unknown', 3.5, 7.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- ilyaro  gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ilyaro  gaadhi', NULL, cat_id, 'General', 'unknown', 10.0, 20.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- sino salaf 371 -90001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino salaf 371 -90001', '90001', cat_id, '371', 'unknown', 75.0, 250.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino salaf 400 -301602
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino salaf 400 -301602', '301602', cat_id, 'Sino', 'unknown', 85.0, 500.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino daynabo 371 -90042
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino daynabo 371 -90042', '90042', cat_id, '371', 'unknown', 60.0, 235.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino daynabo 400 -50099
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino daynabo 400 -50099', '50099', cat_id, 'Sino', 'unknown', 70.0, 280.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino rikoodh - 80001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino rikoodh - 80001', '80001', cat_id, 'Sino', 'unknown', 50.0, 65.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- sino rabadh jeen -13261
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino rabadh jeen -13261', '13261', cat_id, 'Sino', 'unknown', 20.0, 135.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- daboolo taayir
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('daboolo taayir', NULL, cat_id, 'General', 'unknown', 5.0, 20.0, 9, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 9, 0, 9, 'Excel Migration');
  -- sino shakal air beeg -40086
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino shakal air beeg -40086', '40086', cat_id, 'Sino', 'unknown', 20.0, 70.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- sino taangi biyo saayid -30333
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino taangi biyo saayid -30333', '30333', cat_id, 'Sino', 'unknown', 10.0, 70.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- abwaal jeenta -
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('abwaal jeenta -', NULL, cat_id, 'General', 'unknown', 2.0, 6.0, 20, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 20, 0, 20, 'Excel Migration');
  -- sino ac kombrosool 400 -3000007
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino ac kombrosool 400 -3000007', '3000007', cat_id, 'Sino', 'unknown', 50.0, 200.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- kaabane rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane rimoodh', NULL, cat_id, 'General', 'unknown', 230.0, 500.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- kaawe gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaawe gaadhi', NULL, cat_id, 'General', 'unknown', 80.0, 120.0, 0, 5, 'active')
  RETURNING id INTO prod_id;
  -- indhaha lesarka wawaeyn -200002*20001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indhaha lesarka wawaeyn -200002*20001', NULL, cat_id, 'General', 'unknown', 122.0, 340.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- indhaha turuska yaryar -20025*20026
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indhaha turuska yaryar -20025*20026', NULL, cat_id, 'General', 'unknown', 60.0, 80.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- shidh fereen igsal TX 400 org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('shidh fereen igsal TX 400 org', NULL, cat_id, 'TX400', 'original', 95.0, 140.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- sino bambo dhan -tx 400 -671518
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino bambo dhan -tx 400 -671518', '671518', cat_id, 'TX400', 'unknown', 1800.0, 2500.0, 0, 5, 'active')
  RETURNING id INTO prod_id;
  -- sino fortaangi naafato -
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino fortaangi naafato -', NULL, cat_id, 'Sino', 'unknown', 4.0, 10.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- sino lafta xaraarada -tx 400 -90792
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lafta xaraarada -tx 400 -90792', '90792', cat_id, 'TX400', 'unknown', 9.0, 18.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- sino dabaalato -50133
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino dabaalato -50133', '50133', cat_id, 'Sino', 'unknown', 25.0, 40.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- dismis abukaashe
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dismis abukaashe', NULL, cat_id, 'General', 'unknown', 1.5, 2.0, 23, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 23, 0, 23, 'Excel Migration');
  -- indho kaluun
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indho kaluun', NULL, cat_id, 'General', 'unknown', 3.0, 4.0, 42, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 42, 0, 42, 'Excel Migration');
  -- indho dheer
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indho dheer', NULL, cat_id, 'General', 'unknown', 6.0, 7.5, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- indho shabag
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indho shabag', NULL, cat_id, 'General', 'unknown', 2.0, 3.0, 35, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 35, 0, 35, 'Excel Migration');
  -- abwaal v
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('abwaal v', NULL, cat_id, 'General', 'unknown', 2.0, 7.0, 8, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 8, 0, 8, 'Excel Migration');
  -- kaabane hore NO:1 -20072-1
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:1 -20072-1', '1', cat_id, 'General', 'unknown', 45.0, 70.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- kaabane hore NO:2 -20072-2
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:2 -20072-2', '2', cat_id, 'General', 'unknown', 35.0, 55.0, 5, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 5, 0, 5, 'Excel Migration');
  -- kaabane hore NO:3 -20072-3
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:3 -20072-3', '3', cat_id, 'General', 'unknown', 25.0, 50.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- kaabane hore NO:4 -20072-4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:4 -20072-4', '4', cat_id, 'General', 'unknown', 25.0, 50.0, 3, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 3, 0, 3, 'Excel Migration');
  -- habdhiif
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('habdhiif', NULL, cat_id, 'General', 'unknown', 25.0, 50.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- sino buush sabarad qafis yar TX -100609
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush sabarad qafis yar TX -100609', '100609', cat_id, 'Sino', 'unknown', 10.0, 35.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- sino buush sabarad qafis  weyn TX -96210
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush sabarad qafis  weyn TX -96210', '96210', cat_id, 'Sino', 'unknown', 10.0, 30.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- sino tuunbo nafato tx 400 -250021
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino tuunbo nafato tx 400 -250021', '250021', cat_id, 'TX400', 'unknown', 15.0, 35.0, 15, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 15, 0, 15, 'Excel Migration');
  -- sino hoos beeb tx 371 -- 1131
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino hoos beeb tx 371 -- 1131', '1131', cat_id, '371', 'unknown', 15.0, 30.0, 2, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 2, 0, 2, 'Excel Migration');
  -- weysar dhiif
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('weysar dhiif', NULL, cat_id, 'General', 'unknown', 20.0, 35.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- sino hoosbeeb turubo yar -10103
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino hoosbeeb turubo yar -10103', '10103', cat_id, 'Sino', 'unknown', 7.0, 15.0, 4, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 4, 0, 4, 'Excel Migration');
  -- boolbeern 32020
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Boolbeerin' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('boolbeern 32020', NULL, cat_id, 'General', 'unknown', 18.0, 36.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- boolbeern 32017
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Boolbeerin' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('boolbeern 32017', NULL, cat_id, 'General', 'unknown', 18.0, 36.0, 1, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 1, 0, 1, 'Excel Migration');
  -- sino tx 400 biin kaanweys - 50211
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino tx 400 biin kaanweys - 50211', '50211', cat_id, 'TX400', 'unknown', 1.8, 18.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
  -- dhikil  kaanweys
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, part_code, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhikil  kaanweys', NULL, cat_id, 'General', 'unknown', 13.0, 30.0, 10, 5, 'active')
  RETURNING id INTO prod_id;
  INSERT INTO stock_movements (product_id, movement_type, quantity_change, quantity_before, quantity_after, notes)
  VALUES (prod_id, 'initial_stock', 10, 0, 10, 'Excel Migration');
END $$;