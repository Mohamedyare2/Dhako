-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- PROFILES (Linked to Auth)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    role TEXT CHECK (role IN ('admin', 'staff')) DEFAULT 'staff',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CATEGORIES
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_so TEXT UNIQUE NOT NULL,
    name_en TEXT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PRODUCTS
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    part_code TEXT,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    vehicle_model TEXT,
    quality_grade TEXT CHECK (quality_grade IN ('original', 'copy', 'unknown')) DEFAULT 'unknown',
    cost_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    selling_price NUMERIC(12,2) NOT NULL DEFAULT 0,
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5,
    status TEXT CHECK (status IN ('active', 'archived')) DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CUSTOMERS
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    phone TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SALES
CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    customer_name_raw TEXT,
    sale_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    amount_paid NUMERIC(12,2) DEFAULT 0,
    balance_due NUMERIC(12,2) GENERATED ALWAYS AS (total_amount - amount_paid) STORED,
    payment_status TEXT CHECK (payment_status IN ('paid', 'partial', 'credit')) DEFAULT 'paid',
    notes TEXT,
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SALE ITEMS
CREATE TABLE sale_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id UUID REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name_raw TEXT,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL,
    total_price NUMERIC(12,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- STOCK MOVEMENTS
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    movement_type TEXT CHECK (movement_type IN ('initial_stock', 'sale', 'adjustment_increase', 'adjustment_decrease', 'purchase')),
    quantity_change INTEGER NOT NULL,
    quantity_before INTEGER,
    quantity_after INTEGER,
    reference_id UUID, -- Link to sales.id or null
    notes TEXT,
    performed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CREDIT ACCOUNTS
CREATE TABLE credit_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    customer_name_raw TEXT,
    description TEXT,
    amount_owed NUMERIC(12,2) NOT NULL DEFAULT 0,
    amount_paid NUMERIC(12,2) DEFAULT 0,
    status TEXT CHECK (status IN ('open', 'settled', 'partial')) DEFAULT 'open',
    source_sheet TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AUDIT LOGS
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    old_value JSONB,
    new_value JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MIGRATION ERRORS
CREATE TABLE migration_errors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_sheet TEXT,
    source_row INTEGER,
    raw_data JSONB,
    error_type TEXT,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- TRIGGERS FOR UPDATED_AT
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_credit_accounts_updated_at BEFORE UPDATE ON credit_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE migration_errors ENABLE ROW LEVEL SECURITY;

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles: Users can read all profiles (to see who did what). Users can only update their own profile.
CREATE POLICY "Profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admins can update any profile" ON profiles FOR UPDATE USING (is_admin());

-- Categories: Anyone authenticated can read. Admins can insert/update/delete.
CREATE POLICY "Categories are viewable by authenticated users" ON categories FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can insert categories" ON categories FOR INSERT WITH CHECK (is_admin());
CREATE POLICY "Admins can update categories" ON categories FOR UPDATE USING (is_admin());
CREATE POLICY "Admins can delete categories" ON categories FOR DELETE USING (is_admin());

-- Products: Anyone authenticated can read. Anyone authenticated can update (for stock changes, etc.). Only admins can delete.
CREATE POLICY "Products are viewable by authenticated users" ON products FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Products can be inserted by authenticated users" ON products FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Products can be updated by authenticated users" ON products FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admins can delete products" ON products FOR DELETE USING (is_admin());

-- Customers: Anyone authenticated can read, insert, update.
CREATE POLICY "Customers are viewable by authenticated users" ON customers FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Customers can be inserted by authenticated users" ON customers FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Customers can be updated by authenticated users" ON customers FOR UPDATE USING (auth.role() = 'authenticated');

-- Sales & Sale Items: Anyone authenticated can read, insert, update.
CREATE POLICY "Sales are viewable by authenticated users" ON sales FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Sales can be inserted by authenticated users" ON sales FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Sales can be updated by authenticated users" ON sales FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Sale items are viewable by authenticated users" ON sale_items FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Sale items can be inserted by authenticated users" ON sale_items FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Stock Movements: Anyone authenticated can view and insert.
CREATE POLICY "Stock movements are viewable by authenticated users" ON stock_movements FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Stock movements can be inserted by authenticated users" ON stock_movements FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Credit Accounts: Anyone authenticated can view and insert/update.
CREATE POLICY "Credit accounts are viewable by authenticated users" ON credit_accounts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Credit accounts can be inserted by authenticated users" ON credit_accounts FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Credit accounts can be updated by authenticated users" ON credit_accounts FOR UPDATE USING (auth.role() = 'authenticated');

-- Audit Logs & Migration Errors: Only admins can view, everyone can insert.
CREATE POLICY "Admins can view audit logs" ON audit_logs FOR SELECT USING (is_admin());
CREATE POLICY "Anyone can insert audit logs" ON audit_logs FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can view migration errors" ON migration_errors FOR SELECT USING (is_admin());
CREATE POLICY "Anyone can insert migration errors" ON migration_errors FOR INSERT WITH CHECK (auth.role() = 'authenticated');
INSERT INTO categories (name_so, name_en, description) VALUES
('Filtarada', 'Filters', 'Oil, air, and fuel filters'),
('Shaka Khafis', 'Shock Absorbers', 'Front and rear shock absorbers'),
('Rabadh Kaabaan', 'Wheel Bearings/Mounts', 'Rubber mounts and bearings'),
('Buush', 'Bushings', 'Various suspension and mechanical bushings'),
('Kaanweys', 'Tie Rods / Steering', 'Steering components'),
('Boolbeerin', 'Ball Bearings', 'Mechanical bearings'),
('Muraadyad Haad', 'Windshield / Wipers', 'Glass and wiper components'),
('Khashaafad', 'Clutch Components', 'Clutch plates and components'),
('Laydhadhka', 'Lighting', 'Headlights, taillights, bulbs (Indho, Lambad, Guluub)'),
('Lamdado', 'Seals / Gaskets', 'Engine and mechanical seals'),
('Bool / Baanad', 'Nuts & Bolts', 'Hardware, bolts, nuts'),
('Saliid / Dacawo', 'Oils & Fluids', 'Engine oil, brake fluid, hydraulic oil, additives'),
('Tuubo', 'Hoses & Tubes', 'Rubber and metal hoses'),
('Abwaal', 'Washers', 'Hardware washers'),
('Xidhiidhiye', 'Linkages', 'Connectors and linkage parts'),
('Qalab / Tools', 'Tools', 'Spanners (Dhanbaraas), cutting discs (Dhagax moole)'),
('Siiq', 'Springs', 'Coil and leaf springs'),
('Kiliish / Okiyo', 'Keys & Locks', 'Ignition keys and locks'),
('Koronto / Electrical', 'Electrical', 'Connectors, switches, fuses'),
('Guud / General', 'General Parts', 'Other miscellaneous parts')
ON CONFLICT (name_so) DO NOTHING;
-- This script is completely safe to run multiple times.

DO $$
DECLARE
    admin_id UUID;
    staff_id UUID;
BEGIN
    -- 1. Link Admin
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@dhako.com' LIMIT 1;
    IF admin_id IS NOT NULL THEN
        INSERT INTO public.profiles (id, full_name, role)
        VALUES (admin_id, 'Dhako Admin', 'admin')
        ON CONFLICT (id) DO UPDATE SET role = 'admin';
    END IF;

    -- 2. Link Staff
    SELECT id INTO staff_id FROM auth.users WHERE email = 'staff@dhako.com' LIMIT 1;
    IF staff_id IS NOT NULL THEN
        INSERT INTO public.profiles (id, full_name, role)
        VALUES (staff_id, 'Dhako Staff', 'staff')
        ON CONFLICT (id) DO UPDATE SET role = 'staff';
    END IF;
END $$;
-- ================================================================
-- MIGRATION 006: Seed data from second Excel file
-- Contains: New Inventory (Sheet1), Sales (Sheet2),
--           Workshop Service (Sheet3), Credit Accounts (Sheet4, Sheet5)
-- ================================================================

-- ================================================================
-- SHEET 1: New Inventory Items
-- ================================================================
DO $$
DECLARE
  cat_id UUID;
  prod_id UUID;
BEGIN
  -- zino SHAKA KHAFIS  dambeTX400 (60223)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zino SHAKA KHAFIS  dambeTX400 (60223)', cat_id, 'TX400', 'unknown', 58.0, 85.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- zinoSHAKA KHAFIS   hore TX400 (6022)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zinoSHAKA KHAFIS   hore TX400 (6022)', cat_id, 'TX400', 'unknown', 58.0, 85.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SHAKA KHAFIS 371 hore 30283
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHAKA KHAFIS 371 hore 30283', cat_id, '371', 'unknown', 45.0, 60.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SHAKA KHAFIS 371 dambe 40088
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHAKA KHAFIS 371 dambe 40088', cat_id, '371', 'unknown', 45.0, 60.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- filtar dheer naafato 80311  org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar dheer naafato 80311  org', cat_id, 'General', 'original', 18.0, 25.0, 18, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- filtar saliid 70005 org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar saliid 70005 org', cat_id, 'General', 'original', 5.0, 7.0, 25, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- filtar naafato gaaban 80012
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar naafato gaaban 80012', cat_id, 'General', 'unknown', 13.0, 18.0, 17, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- filtar naafato TX400 ORG (TR22384)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar naafato TX400 ORG (TR22384)', cat_id, 'TX400', 'original', 7.5, 15.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- filtar saliid TX400 70031 org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filtar saliid TX400 70031 org', cat_id, 'TX400', 'original', 8.0, 15.0, 42, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- rabadh kaabaan EOM 20278
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rabadh kaabaan EOM 20278', cat_id, 'General', 'unknown', 80.0, 110.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SINO BUUSH XIDHIIDHIYE HOOSE ORG 21177
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SINO BUUSH XIDHIIDHIYE HOOSE ORG 21177', cat_id, 'Sino', 'original', 28.0, 40.0, 16, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KAANWEYS DAMBE 12GOD ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAANWEYS DAMBE 12GOD ORG', cat_id, 'General', 'original', 33.0, 55.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KAAWEYS DAMBE 14 GODLE ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAAWEYS DAMBE 14 GODLE ORG', cat_id, 'General', 'original', 33.0, 55.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KAANWEYS HORE TX400  ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAANWEYS HORE TX400  ORG', cat_id, 'TX400', 'original', 25.0, 50.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KAAWEYS HORE 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KAAWEYS HORE 371', cat_id, '371', 'unknown', 25.0, 45.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BUUSH KAABAN ORG shiimisyo 20078
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BUUSH KAABAN ORG shiimisyo 20078', cat_id, 'General', 'original', 1.5, 4.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SHID FAREEN IGSAL ORG TX40 50002
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHID FAREEN IGSAL ORG TX40 50002', cat_id, 'General', 'original', 39.0, 80.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SHID FAREEN IGSAL ORG 371 410031
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHID FAREEN IGSAL ORG 371 410031', cat_id, '371', 'original', 25.0, 45.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- FILTER QACAAYAD ORG 3286
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('FILTER QACAAYAD ORG 3286', cat_id, 'General', 'original', 7.0, 15.0, 16, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- TUUBO NAAFATO 371 ORG 3 NOOC (80017) (80018) (80019)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('TUUBO NAAFATO 371 ORG 3 NOOC (80017) (80018) (80019)', cat_id, '371', 'original', 5.5, 20.0, 24, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- TUUBO NAAFATO TX400 ORG 50021
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('TUUBO NAAFATO TX400 ORG 50021', cat_id, 'TX400', 'original', 8.0, 16.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SHIDH POWER ORG 70228
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SHIDH POWER ORG 70228', cat_id, 'General', 'original', 14.0, 35.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- HAAN KALIISH ORG 30041
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('HAAN KALIISH ORG 30041', cat_id, 'General', 'original', 8.0, 110.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BADHAD GIIJIYE 371 60313
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD GIIJIYE 371 60313', cat_id, '371', 'unknown', 17.0, 35.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BADHAD MISHIIN 371 ORG 8BK1050
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD MISHIIN 371 ORG 8BK1050', cat_id, '371', 'original', 9.0, 18.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BADHAD AC ORG -6BK1020
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD AC ORG -6BK1020', cat_id, 'General', 'original', 7.5, 15.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BADHAD DAYNABO ORG -6BK783
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BADHAD DAYNABO ORG -6BK783', cat_id, 'General', 'original', 7.5, 15.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- MURAADYAD HAAD ORG 371 -5005
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Muraadyad Haad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('MURAADYAD HAAD ORG 371 -5005', cat_id, '371', 'original', 60.0, 80.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- MURAADYAD HAAD ORG TX 400 -7025 - 7021
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Muraadyad Haad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('MURAADYAD HAAD ORG TX 400 -7025 - 7021', cat_id, 'TX400', 'original', 60.0, 85.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KHASHAAFAD  371 ORG - 90102
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KHASHAAFAD  371 ORG - 90102', cat_id, '371', 'original', 60.0, 80.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KHASHAAFAD  336 ORG -90001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KHASHAAFAD  336 ORG -90001', cat_id, '336', 'original', 60.0, 75.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KHASHAAFAD  TX400  ORG - 90061
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KHASHAAFAD  TX400  ORG - 90061', cat_id, 'TX400', 'original', 78.0, 100.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- INDHO HORE 371 ORG -20002 - 20001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO HORE 371 ORG -20002 - 20001', cat_id, '371', 'original', 80.0, 95.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- INDHO TURUS 371 ORG - 200025  - 200026
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO TURUS 371 ORG - 200025  - 200026', cat_id, '371', 'original', 32.0, 40.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- INDHO TURUS TX 400 ORG -6002
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO TURUS TX 400 ORG -6002', cat_id, 'TX400', 'original', 25.0, 40.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- INDHO HORE TX 400 ORG - 6001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('INDHO HORE TX 400 ORG - 6001', cat_id, 'TX400', 'original', 60.0, 90.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BUUSH SABARAD KHAFIS YARE 371 ORG -30263
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BUUSH SABARAD KHAFIS YARE 371 ORG -30263', cat_id, '371', 'original', 2.0, 4.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BUUSH SABARAD KHAFIS WEYN  371 ORG -30061
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BUUSH SABARAD KHAFIS WEYN  371 ORG -30061', cat_id, '371', 'original', 3.9, 7.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BOLTAAYIR TX400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOLTAAYIR TX400', cat_id, 'TX400', 'unknown', 2.2, 5.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BOLTAAYIR 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOLTAAYIR 371', cat_id, '371', 'unknown', 3.8, 5.0, 25, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- LAMDAD HOBOS DAMBE ORG -190*220*30
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('LAMDAD HOBOS DAMBE ORG -190*220*30', cat_id, 'General', 'original', 7.0, 15.0, 18, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- LAMDAD HOBOS HORE  ORG  -140*160*13
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('LAMDAD HOBOS HORE  ORG  -140*160*13', cat_id, 'General', 'original', 4.0, 8.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- LAMDAD KOMBOROSOL juundo -32*52*7
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('LAMDAD KOMBOROSOL juundo -32*52*7', cat_id, 'General', 'unknown', 3.8, 8.0, 16, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BOOLBEERIN CANDHO 6312N ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Boolbeerin' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOOLBEERIN CANDHO 6312N ORG', cat_id, 'General', 'original', 13.0, 35.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KILIISH IMADAX 2MADAX ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kiliish / Okiyo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KILIISH IMADAX 2MADAX ORG', cat_id, 'General', 'original', 12.0, 25.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SIIQ LEEWAR 371 ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SIIQ LEEWAR 371 ORG', cat_id, '371', 'original', 28.0, 37.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SIIQ LEEWAR 371 COPY
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SIIQ LEEWAR 371 COPY', cat_id, '371', 'copy', 4.0, 10.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BOOLXIDHIDHIYE DHER ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOOLXIDHIDHIYE DHER ORG', cat_id, 'General', 'original', 3.0, 5.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BOOLXIDHIDHIYE GAABAN ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BOOLXIDHIDHIYE GAABAN ORG', cat_id, 'General', 'original', 2.0, 5.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ISBIRIINO KAAWEYS ORG
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ISBIRIINO KAAWEYS ORG', cat_id, 'General', 'original', 1.5, 4.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- XIDHIIDHIYE V -29272
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XIDHIIDHIYE V -29272', cat_id, 'General', 'unknown', 70.0, 100.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- RAMOODH OKIYO
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kiliish / Okiyo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('RAMOODH OKIYO', cat_id, 'General', 'unknown', 75.0, 110.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- CALEEN LAALAAD -30034
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('CALEEN LAALAAD -30034', cat_id, 'General', 'unknown', 12.0, 20.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KILIIB TURUBO 3 NOOC -19215*19216*80060
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kiliish / Okiyo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KILIIB TURUBO 3 NOOC -19215*19216*80060', cat_id, 'General', 'unknown', 2.2, 6.0, 15, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- KOBAAL HORE 35 -
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('KOBAAL HORE 35 -', cat_id, 'General', 'unknown', 6.5, 15.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SIIQ LEEWAR ORG TX400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SIIQ LEEWAR ORG TX400', cat_id, 'TX400', 'original', 28.0, 35.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- zino SANTARA BOOL HORE
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zino SANTARA BOOL HORE', cat_id, 'Sino', 'unknown', 2.0, 4.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SALIID DELO 1LITIR DIESEL
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID DELO 1LITIR DIESEL', cat_id, 'General', 'unknown', 2.9, 3.5, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SALIID PETROL HAVOLINE ONE LITER
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID PETROL HAVOLINE ONE LITER', cat_id, 'General', 'unknown', 2.9, 3.5, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SALIID PETROL HAVOLINE 4 LITER
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID PETROL HAVOLINE 4 LITER', cat_id, 'General', 'unknown', 11.0, 15.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SALIID  CASTROL 25 LITER
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID  CASTROL 25 LITER', cat_id, 'General', 'unknown', 95.0, 110.0, 12, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- XAYDH TASQIYAD
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XAYDH TASQIYAD', cat_id, 'General', 'unknown', 3.75, 6.0, 12, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- XAYDH HOBOS
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XAYDH HOBOS', cat_id, 'General', 'unknown', 3.75, 6.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- XAYDH HOBOS YAR YAR
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XAYDH HOBOS YAR YAR', cat_id, 'General', 'unknown', 2.4, 3.5, 46, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- BALASH DHEHA YAR
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('BALASH DHEHA YAR', cat_id, 'General', 'unknown', 1.25, 3.0, 18, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SALIID BAREEK
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID BAREEK', cat_id, 'General', 'unknown', 1.1, 1.0, 17, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SALIID HAYDAROOLIK
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SALIID HAYDAROOLIK', cat_id, 'General', 'unknown', 1.5, 2.5, 11, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ISTEERIN GAADHI
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ISTEERIN GAADHI', cat_id, 'General', 'unknown', 2.4, 5.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- AIR FRESH biif
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('AIR FRESH biif', cat_id, 'General', 'unknown', 0.25, 2.0, 7, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- FUSE CARD WEYN
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('FUSE CARD WEYN', cat_id, 'General', 'unknown', 0.35, 1.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- DAWO DAXAL
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWO DAXAL', cat_id, 'General', 'unknown', 1.16, 2.0, 13, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- DAWO KARBEYDHAR
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWO KARBEYDHAR', cat_id, 'General', 'unknown', 1.0, 2.0, 15, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- air kawar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('air kawar', cat_id, 'General', 'unknown', 1.1, 1.0, 31, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- DAWODIESAL
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWODIESAL', cat_id, 'General', 'unknown', 1.66, 3.0, 12, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- DAWO PETRO
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DAWO PETRO', cat_id, 'General', 'unknown', 1.16, 2.5, 12, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- XABAG BAATIN BLACK
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('XABAG BAATIN BLACK', cat_id, 'General', 'unknown', 1.16, 2.0, 7, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ISKU DAR 5 MINI
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ISKU DAR 5 MINI', cat_id, 'General', 'unknown', 1.16, 2.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- DHASH BAALASH
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('DHASH BAALASH', cat_id, 'General', 'unknown', 1.16, 2.0, 15, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- xadhig waayar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('xadhig waayar', cat_id, 'General', 'unknown', 0, 1.5, 90, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- lambad 10 watt
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('lambad 10 watt', cat_id, 'General', 'unknown', 0.7, 2.0, 24, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- fiish
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('fiish', cat_id, 'General', 'unknown', 1.0, 1.5, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- iswiij
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Koronto / Electrical' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('iswiij', cat_id, 'General', 'unknown', 1.0, 1.5, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- lamp holder
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('lamp holder', cat_id, 'General', 'unknown', 0.29, 1.0, 40, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- indhaha dhinaca
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indhaha dhinaca', cat_id, 'General', 'unknown', 2.4, 4.0, 54, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino dhagax camuud -20042
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino dhagax camuud -20042', cat_id, 'Sino', 'unknown', 60.0, 80.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino buush camuud -20191
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush camuud -20191', cat_id, 'Sino', 'unknown', 23.0, 35.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino weysar sabarad khafis -30263
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino weysar sabarad khafis -30263', cat_id, 'Sino', 'unknown', 2.0, 4.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino  biin shakal -30239
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino  biin shakal -30239', cat_id, 'Sino', 'unknown', 2.0, 4.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino bool beerin feeran igsal 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Boolbeerin' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino bool beerin feeran igsal 371', cat_id, '371', 'unknown', 2.0, 9.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino malqacaad bireeg l L and R -40057(L) - 40056(R)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino malqacaad bireeg l L and R -40057(L) - 40056(R)', cat_id, 'Sino', 'unknown', 14.0, 20.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino connector4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino connector4', cat_id, 'Sino', 'unknown', 0.5, 1.0, 50, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- connector6
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector6', cat_id, 'General', 'unknown', 0.5, 1.0, 50, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- connector8
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector8', cat_id, 'General', 'unknown', 0.5, 1.0, 50, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- connector10
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector10', cat_id, 'General', 'unknown', 0.5, 1.0, 49, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- connector12
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('connector12', cat_id, 'General', 'unknown', 0.5, 1.0, 48, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino lamdad camuud weyn -160*194*10.5
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lamdad camuud weyn -160*194*10.5', cat_id, 'Sino', 'unknown', 4.5, 10.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino lamdad camuud yar -160*185*10.5
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lamdad camuud yar -160*185*10.5', cat_id, 'Sino', 'unknown', 4.0, 8.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuumbo naqas 4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 4', cat_id, 'General', 'unknown', 15.0, 1.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuumbo naqas 6
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 6', cat_id, 'General', 'unknown', 18.0, 1.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuumbo naqas 8
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 8', cat_id, 'General', 'unknown', 18.0, 1.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuumbo naqas 10
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 10', cat_id, 'General', 'unknown', 25.0, 1.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuumbo naqas 12
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo naqas 12', cat_id, 'General', 'unknown', 25.0, 1.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino bogos kileesh asli -30023
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino bogos kileesh asli -30023', cat_id, 'Sino', 'original', 28.0, 40.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino buush afargees yar  20221
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush afargees yar  20221', cat_id, 'Sino', 'unknown', 1.8, 4.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino buush afargees weyn -20159
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush afargees weyn -20159', cat_id, 'Sino', 'unknown', 1.8, 4.0, 16, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- muraayad gool TX400 -6656
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Muraadyad Haad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('muraayad gool TX400 -6656', cat_id, 'TX400', 'unknown', 25.0, 37.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- muraayad gool 371  -70010
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Muraadyad Haad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('muraayad gool 371  -70010', cat_id, '371', 'unknown', 5.0, 10.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino guluub H4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino guluub H4', cat_id, 'Sino', 'unknown', 2.0, 3.0, 19, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino guluub H3
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino guluub H3', cat_id, 'Sino', 'unknown', 1.5, 3.0, 17, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino guluub H1
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino guluub H1', cat_id, 'Sino', 'unknown', 1.5, 3.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino shaandho naqas -60521
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino shaandho naqas -60521', cat_id, 'Sino', 'unknown', 19.0, 30.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- bam xaydh 1 kg
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bam xaydh 1 kg', cat_id, 'General', 'unknown', 6.5, 26.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- okiyo gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kiliish / Okiyo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('okiyo gaadhi', cat_id, 'General', 'unknown', 60.0, 110.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- bool gudban
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bool gudban', cat_id, 'General', 'unknown', 20.0, 30.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- bool rimool
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bool rimool', cat_id, 'General', 'unknown', 2.65, 10.0, 13, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- rabadh tiimone
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rabadh tiimone', cat_id, 'General', 'unknown', 3.3, 10.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- bool garbo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bool garbo', cat_id, 'General', 'unknown', 24.9, 40.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- buush x.rimool
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush x.rimool', cat_id, 'General', 'unknown', 3.99, 10.0, 19, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- baanad 10mm (20370)
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanad 10mm (20370)', cat_id, 'General', 'unknown', 0.7, 1.5, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- baanad dh/ baraas 17mm ( 20440) china
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanad dh/ baraas 17mm ( 20440) china', cat_id, 'General', 'unknown', 1.2, 2.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- filter gaadhi yar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('filter gaadhi yar', cat_id, 'General', 'unknown', 0.91, 1.5, 26, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dismis faseex
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dismis faseex', cat_id, 'General', 'unknown', 5.9, 1.5, 23, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- silisteeb
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('silisteeb', cat_id, 'General', 'unknown', 0.3, 0.5, 24, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- buush raam hore -80035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush raam hore -80035', cat_id, 'General', 'unknown', 3.5, 6.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- buush raam dambe -80035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush raam dambe -80035', cat_id, 'General', 'unknown', 3.5, 6.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- buush raam ramoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush raam ramoodh', cat_id, 'General', 'unknown', 3.5, 6.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- xabag cad 99
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('xabag cad 99', cat_id, 'General', 'unknown', 1.5, 2.0, 12, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- wood xabag cad loox
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('wood xabag cad loox', cat_id, 'General', 'unknown', 1.3, 2.5, 21, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino filter saliid 70005
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter saliid 70005', cat_id, 'Sino', 'unknown', 3.0, 8.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino filter naafato 80012
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter naafato 80012', cat_id, 'Sino', 'unknown', 3.0, 8.0, 16, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino filter dheer 80311
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter dheer 80311', cat_id, 'Sino', 'unknown', 5.0, 12.0, 18, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino filter saliid TX400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter saliid TX400', cat_id, 'TX400', 'unknown', 5.5, 14.0, 14, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino filter naafato1334
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Filtarada' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino filter naafato1334', cat_id, 'Sino', 'unknown', 4.0, 14.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- biin rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('biin rimoodh', cat_id, 'General', 'unknown', 19.0, 30.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- rabadh rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rabadh rimoodh', cat_id, 'General', 'unknown', 0.9, 10.0, 12, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- buush jiide  rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush jiide  rimoodh', cat_id, 'General', 'unknown', 3.5, 7.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- buushka okiyada
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buushka okiyada', cat_id, 'General', 'unknown', 5.5, 10.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- haraaqo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('haraaqo', cat_id, 'General', 'unknown', 1.0, 1.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 12
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 12', cat_id, 'General', 'unknown', 0.85, 2.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 13
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 13', cat_id, 'General', 'unknown', 0.9, 2.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 14
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 14', cat_id, 'General', 'unknown', 0.95, 2.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 17
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 17', cat_id, 'General', 'unknown', 1.3, 2.5, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 19
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 19', cat_id, 'General', 'unknown', 1.5, 3.5, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 22
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 22', cat_id, 'General', 'unknown', 2.1, 3.5, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 24
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 24', cat_id, 'General', 'unknown', 2.55, 4.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 27
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 27', cat_id, 'General', 'unknown', 3.0, 4.5, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhanbaraas 30
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhanbaraas 30', cat_id, 'General', 'unknown', 3.5, 5.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhagax moole jare9"
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhagax moole jare9"', cat_id, 'General', 'unknown', 2.5, 3.5, 30, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- laxaamad 3.2
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('laxaamad 3.2', cat_id, 'General', 'unknown', 1.0, 6.5, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- baaleys 220
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baaleys 220', cat_id, 'General', 'unknown', 0.3, 1.0, 98, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- baaleys 60
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baaleys 60', cat_id, 'General', 'unknown', 0.32, 1.0, 94, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhagax mole qore 9
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhagax mole qore 9', cat_id, 'General', 'unknown', 3.2, 5.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhagax qore 7
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Qalab / Tools' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhagax qore 7', cat_id, 'General', 'unknown', 1.8, 3.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- saliid euro
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('saliid euro', cat_id, 'General', 'unknown', 67.0, 90.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- daawe gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('daawe gaadhi', cat_id, 'General', 'unknown', 75.0, 120.0, 0, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuubyo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuubyo', cat_id, 'General', 'unknown', 18.0, 22.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ban xaydh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ban xaydh', cat_id, 'General', 'unknown', 5.5, 15.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- baanado ula weyne
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanado ula weyne', cat_id, 'General', 'unknown', 75.0, 110.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuunbo xaydh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuunbo xaydh', cat_id, 'General', 'unknown', 1.5, 3.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- baanad ula yare
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baanad ula yare', cat_id, 'General', 'unknown', 20.0, 45.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- galaas baston riin creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('galaas baston riin creaket', cat_id, 'General', 'unknown', 1000.0, 1200.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- baakin dhan creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('baakin dhan creaket', cat_id, 'General', 'unknown', 230.0, 150.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 7121463701fooshad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('7121463701fooshad', cat_id, 'General', 'unknown', 40.0, 185.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ck8415 salaf creaket 11/15
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8415 salaf creaket 11/15', cat_id, 'General', 'unknown', 195.0, 250.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ck8415 salaf creaket 11/14
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8415 salaf creaket 11/14', cat_id, 'General', 'unknown', 195.0, 250.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ck8139 shidh f.igsal
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8139 shidh f.igsal', cat_id, 'General', 'unknown', 55.0, 90.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 30x32 sheeg baane
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('30x32 sheeg baane', cat_id, 'General', 'unknown', 12.0, 25.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 32x33  sheeg baane
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('32x33  sheeg baane', cat_id, 'General', 'unknown', 12.0, 25.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ck8597 rabadh jen creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck8597 rabadh jen creaket', cat_id, 'General', 'unknown', 41.0, 135.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 9125521174 xidhiidhiye qaloca
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Xidhiidhiye' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9125521174 xidhiidhiye qaloca', cat_id, 'General', 'unknown', 50.0, 75.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 614040021 bakin dhaban creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('614040021 bakin dhaban creaket', cat_id, 'General', 'unknown', 1.3, 2.5, 18, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 60080218 hand pump creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('60080218 hand pump creaket', cat_id, 'General', 'unknown', 6.0, 15.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ck 8010 bambaji creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ck 8010 bambaji creaket', cat_id, 'General', 'unknown', 30.0, 45.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 60313 badhad giije creaket
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('60313 badhad giije creaket', cat_id, 'General', 'unknown', 40.0, 65.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 9231320271 dhiif candho cadi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9231320271 dhiif candho cadi', cat_id, 'General', 'unknown', 115.0, 145.0, 0, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 9231320261 sabarad dhiif copy
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9231320261 sabarad dhiif copy', cat_id, 'General', 'copy', 30.0, 70.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 1642870231  fooshad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642870231  fooshad', cat_id, 'General', 'unknown', 24.0, 80.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- saliid qatol
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Saliid / Dacawo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('saliid qatol', cat_id, 'General', 'unknown', 45.0, 14.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 600 kobaal fo6
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('600 kobaal fo6', cat_id, 'General', 'unknown', 6.2, 10.0, 7, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 600-32 kobaal dambe
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('600-32 kobaal dambe', cat_id, 'General', 'unknown', 10.0, 15.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 50 ton jeeg dheer
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('50 ton jeeg dheer', cat_id, 'General', 'unknown', 43.0, 60.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 32 ton jeeg
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('32 ton jeeg', cat_id, 'General', 'unknown', 30.0, 40.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 1642340002 gacan albaab
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642340002 gacan albaab', cat_id, 'General', 'unknown', 9.0, 25.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 1642340015 siiq daaqad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642340015 siiq daaqad', cat_id, 'General', 'unknown', 5.0, 14.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 1642340014 siiq daaqad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Siiq' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1642340014 siiq daaqad', cat_id, 'General', 'unknown', 5.0, 14.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 1500090039 booldaynabo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1500090039 booldaynabo', cat_id, 'General', 'unknown', 7.0, 12.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 6800340015 fasexad hobos
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('6800340015 fasexad hobos', cat_id, 'General', 'unknown', 1.5, 4.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 1857 automatic salaf
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1857 automatic salaf', cat_id, 'General', 'unknown', 24.0, 40.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 9925530058 hosbeeb kular
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9925530058 hosbeeb kular', cat_id, 'General', 'unknown', 12.0, 18.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 1500119215 clip tuubo
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('1500119215 clip tuubo', cat_id, 'General', 'unknown', 2.0, 5.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 9725520227 bool xidhiidhiye
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('9725520227 bool xidhiidhiye', cat_id, 'General', 'unknown', 2.0, 5.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- 420 bool santar
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Bool / Baanad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('420 bool santar', cat_id, 'General', 'unknown', 3.2, 7.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino footari
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino footari', cat_id, 'Sino', 'unknown', 1.5, 5.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino waysar diif 10 god
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar diif 10 god', cat_id, 'Sino', 'unknown', 3.5, 7.0, 6, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino cidi dhiif 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino cidi dhiif 371', cat_id, '371', 'unknown', 3.8, 7.0, 14, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino waysar canjalada dhiif tx400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar canjalada dhiif tx400', cat_id, 'TX400', 'unknown', 1.5, 5.0, 24, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino waysar dhiif 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar dhiif 371', cat_id, '371', 'unknown', 3.5, 7.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino waysar hawsisn 371
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar hawsisn 371', cat_id, '371', 'unknown', 3.5, 7.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino canjald dhiif wayn 20040
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino canjald dhiif wayn 20040', cat_id, 'Sino', 'unknown', 19.0, 40.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino canjald dhiif yar 0035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino canjald dhiif yar 0035', cat_id, 'Sino', 'unknown', 9.0, 20.0, 17, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino afar gees tx400 0035
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino afar gees tx400 0035', cat_id, 'TX400', 'unknown', 20.0, 40.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino afar gees tx400 0044
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino afar gees tx400 0044', cat_id, 'TX400', 'unknown', 20.0, 40.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino waysar hawsin tx400
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar hawsin tx400', cat_id, 'TX400', 'unknown', 3.8, 7.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- weysaro bir ah
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('weysaro bir ah', cat_id, 'General', 'unknown', 1.0, 7.0, 12, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino lamdad candho -85*105*8
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Lamdado' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lamdad candho -85*105*8', cat_id, 'Sino', 'unknown', 3.8, 10.0, 15, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino waysar candho caag -20153
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino waysar candho caag -20153', cat_id, 'Sino', 'unknown', 1.0, 5.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- rinoodh baraasad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rinoodh baraasad', cat_id, 'General', 'unknown', 20.0, 40.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- rinoodh baraasad org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rinoodh baraasad org', cat_id, 'General', 'original', 20.0, 80.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino sabarad dhiif asli -20135
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino sabarad dhiif asli -20135', cat_id, 'Sino', 'original', 90.0, 130.0, 0, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino dhiif dhan asli -20271
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino dhiif dhan asli -20271', cat_id, 'Sino', 'original', 380.0, 550.0, 0, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- SINO Kabiin kaaban -520065
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('SINO Kabiin kaaban -520065', cat_id, 'Sino', 'unknown', 3.5, 6.0, 11, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tasqiyado
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tasqiyado', cat_id, 'General', 'unknown', 0.19, 0.5, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- zino dhaban dabka --11137
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('zino dhaban dabka --11137', cat_id, 'Sino', 'unknown', 90.0, 230.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- tuumbo biriig  -60450
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('tuumbo biriig  -60450', cat_id, 'General', 'unknown', 5.0, 10.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- caleen kaban hore -20007
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('caleen kaban hore -20007', cat_id, 'General', 'unknown', 25.0, 50.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ac komborosool -39016
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ac komborosool -39016', cat_id, 'General', 'unknown', 80.0, 160.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- bastoon leeawr -70014
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('bastoon leeawr -70014', cat_id, 'General', 'unknown', 12.0, 25.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- lafta xaraar -90061
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('lafta xaraar -90061', cat_id, 'General', 'unknown', 3.5, 7.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- taangi  naafato
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('taangi  naafato', cat_id, 'General', 'unknown', 285.0, 415.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- rimoodh daran wayne-77630
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('rimoodh daran wayne-77630', cat_id, 'General', 'unknown', 9.0, 390.0, 0, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- buush canjalad
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('buush canjalad', cat_id, 'General', 'unknown', 3.5, 7.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- ilyaro  gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('ilyaro  gaadhi', cat_id, 'General', 'unknown', 10.0, 20.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino salaf 371 -90001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino salaf 371 -90001', cat_id, '371', 'unknown', 75.0, 250.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino salaf 400 -301602
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Khashaafad' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino salaf 400 -301602', cat_id, 'Sino', 'unknown', 85.0, 500.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino daynabo 371 -90042
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino daynabo 371 -90042', cat_id, '371', 'unknown', 60.0, 235.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino daynabo 400 -50099
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino daynabo 400 -50099', cat_id, 'Sino', 'unknown', 70.0, 280.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino rikoodh - 80001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino rikoodh - 80001', cat_id, 'Sino', 'unknown', 50.0, 65.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino rabadh jeen -13261
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Rabadh Kaabaan' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino rabadh jeen -13261', cat_id, 'Sino', 'unknown', 20.0, 135.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- daboolo taayir
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('daboolo taayir', cat_id, 'General', 'unknown', 5.0, 20.0, 9, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino shakal air beeg -40086
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Shaka Khafis' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino shakal air beeg -40086', cat_id, 'Sino', 'unknown', 20.0, 70.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino taangi biyo saayid -30333
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino taangi biyo saayid -30333', cat_id, 'Sino', 'unknown', 10.0, 70.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- abwaal jeenta -
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('abwaal jeenta -', cat_id, 'General', 'unknown', 2.0, 6.0, 20, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino ac kombrosool 400 -3000007
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino ac kombrosool 400 -3000007', cat_id, 'Sino', 'unknown', 50.0, 200.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- kaabane rimoodh
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane rimoodh', cat_id, 'General', 'unknown', 230.0, 500.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- kaawe gaadhi
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaawe gaadhi', cat_id, 'General', 'unknown', 80.0, 120.0, 0, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- indhaha lesarka wawaeyn -200002*20001
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indhaha lesarka wawaeyn -200002*20001', cat_id, 'General', 'unknown', 122.0, 340.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- indhaha turuska yaryar -20025*20026
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indhaha turuska yaryar -20025*20026', cat_id, 'General', 'unknown', 60.0, 80.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- shidh fereen igsal TX 400 org
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('shidh fereen igsal TX 400 org', cat_id, 'TX400', 'original', 95.0, 140.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino bambo dhan -tx 400 -671518
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino bambo dhan -tx 400 -671518', cat_id, 'TX400', 'unknown', 1800.0, 2500.0, 0, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino fortaangi naafato -
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino fortaangi naafato -', cat_id, 'Sino', 'unknown', 4.0, 10.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino lafta xaraarada -tx 400 -90792
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino lafta xaraarada -tx 400 -90792', cat_id, 'TX400', 'unknown', 9.0, 18.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino dabaalato -50133
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino dabaalato -50133', cat_id, 'Sino', 'unknown', 25.0, 40.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dismis abukaashe
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dismis abukaashe', cat_id, 'General', 'unknown', 1.5, 2.0, 23, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- indho kaluun
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indho kaluun', cat_id, 'General', 'unknown', 3.0, 4.0, 42, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- indho dheer
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indho dheer', cat_id, 'General', 'unknown', 6.0, 7.5, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- indho shabag
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Laydhadhka' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('indho shabag', cat_id, 'General', 'unknown', 2.0, 3.0, 35, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- abwaal v
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Abwaal' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('abwaal v', cat_id, 'General', 'unknown', 2.0, 7.0, 8, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- kaabane hore NO:1 -20072-1
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:1 -20072-1', cat_id, 'General', 'unknown', 45.0, 70.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- kaabane hore NO:2 -20072-2
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:2 -20072-2', cat_id, 'General', 'unknown', 35.0, 55.0, 5, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- kaabane hore NO:3 -20072-3
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:3 -20072-3', cat_id, 'General', 'unknown', 25.0, 50.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- kaabane hore NO:4 -20072-4
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('kaabane hore NO:4 -20072-4', cat_id, 'General', 'unknown', 25.0, 50.0, 3, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- habdhiif
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('habdhiif', cat_id, 'General', 'unknown', 25.0, 50.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino buush sabarad qafis yar TX -100609
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush sabarad qafis yar TX -100609', cat_id, 'Sino', 'unknown', 10.0, 35.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino buush sabarad qafis  weyn TX -96210
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Buush' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino buush sabarad qafis  weyn TX -96210', cat_id, 'Sino', 'unknown', 10.0, 30.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino tuunbo nafato tx 400 -250021
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Tuubo' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino tuunbo nafato tx 400 -250021', cat_id, 'TX400', 'unknown', 15.0, 35.0, 15, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino hoos beeb tx 371 -- 1131
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino hoos beeb tx 371 -- 1131', cat_id, '371', 'unknown', 15.0, 30.0, 2, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- weysar dhiif
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('weysar dhiif', cat_id, 'General', 'unknown', 20.0, 35.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino hoosbeeb turubo yar -10103
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino hoosbeeb turubo yar -10103', cat_id, 'Sino', 'unknown', 7.0, 15.0, 4, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- boolbeern 32020
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Boolbeerin' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('boolbeern 32020', cat_id, 'General', 'unknown', 18.0, 36.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- boolbeern 32017
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Boolbeerin' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('boolbeern 32017', cat_id, 'General', 'unknown', 18.0, 36.0, 1, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- sino tx 400 biin kaanweys - 50211
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('sino tx 400 biin kaanweys - 50211', cat_id, 'TX400', 'unknown', 1.8, 18.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
  -- dhikil  kaanweys
  SELECT id INTO cat_id FROM categories WHERE name_so = 'Kaanweys' LIMIT 1;
  IF cat_id IS NULL THEN SELECT id INTO cat_id FROM categories WHERE name_so = 'Guud / General' LIMIT 1; END IF;
  INSERT INTO products (name, category_id, vehicle_model, quality_grade, cost_price, selling_price, quantity_on_hand, min_stock_level, status)
  VALUES ('dhikil  kaanweys', cat_id, 'General', 'unknown', 13.0, 30.0, 10, 5, 'active')
  ON CONFLICT DO NOTHING;
END $$;

-- ================================================================
-- SHEET 2: Daily Sales Transactions
-- ================================================================
DO $$
DECLARE
  sale_id UUID;
  cust_id UUID;
BEGIN
  -- Sale: Walk-in Customer on 2026-07-07
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-07-07', 50.0, 50.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'BOLTAAYIR TX400', 1, 50.0, 50.0);
  -- Sale: dhuux cisman on 2026-07-07
  INSERT INTO customers (name) VALUES ('dhuux cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cisman', '2026-07-07', 684.0, 684.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, '4 BUUSH XIDHII', 1, 160.0, 160.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'LABA RABADH KABAAN', 1, 220.0, 220.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'SHALIID 20 LITER', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'BIIF DAXAL', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'FILTER', 1, 75.0, 75.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'AIR FRESH BIIF', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baalash daxal', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashafad 371', 1, 90.0, 90.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato', 1, 18.0, 18.0);
  -- Sale: 16 on 2026-07-11
  INSERT INTO customers (name) VALUES ('16') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = '16' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, '16', '2026-07-11', 295.0, 295.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'SHAKAL KHAFIS HORE TX', 1, 170.0, 170.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 20 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato', 1, 25.0, 25.0);
  -- Sale: AHmed case on 2026-07-14
  INSERT INTO customers (name) VALUES ('AHmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'AHmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'AHmed case', '2026-07-14', 558.0, 558.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid bareek', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haan kilis', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, '4 rabadh kamaan', 1, 420.0, 420.0);
  -- Sale: khader ileeye on 2026-07-14
  INSERT INTO customers (name) VALUES ('khader ileeye') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'khader ileeye' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'khader ileeye', '2026-07-14', 126.0, 126.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweys 2 sad', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indhaha dhinaca', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 12.0, 12.0);
  -- Sale: nimcaan abdiraxman on 2026-07-15
  INSERT INTO customers (name) VALUES ('nimcaan abdiraxman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'nimcaan abdiraxman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'nimcaan abdiraxman', '2026-07-15', 55.0, 55.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush xidhidhiye', 1, 40.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'booltayir 371', 1, 15.0, 15.0);
  -- Sale: ismaciil ceerigabo on 2026-07-16
  INSERT INTO customers (name) VALUES ('ismaciil ceerigabo') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ismaciil ceerigabo' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ismaciil ceerigabo', '2026-07-16', 203.0, 203.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 20 liter iyo 3 liter', 1, 112.0, 112.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato 3066', 1, 30.0, 30.0);
  -- Sale: dhuux cisman on 2026-07-16
  INSERT INTO customers (name) VALUES ('dhuux cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cisman', '2026-07-16', 56.0, 56.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 18.0, 18.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indho dhinac ah', 1, 32.0, 32.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baalash', 1, 3.0, 3.0);
  -- Sale: guuleed tuuriseed on 2026-07-16
  INSERT INTO customers (name) VALUES ('guuleed tuuriseed') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'guuleed tuuriseed' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'guuleed tuuriseed', '2026-07-16', 191.0, 191.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 20 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato 3066', 1, 30.0, 30.0);
  -- Sale: dhuux cisman on 2026-07-17
  INSERT INTO customers (name) VALUES ('dhuux cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cisman', '2026-07-17', 106.5, 106.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos', 1, 42.0, 42.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal ramoodh', 1, 60.0, 60.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal yaryar', 1, 1.5, 1.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 3.0, 3.0);
  -- Sale: Walk-in Customer on 2026-07-20
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-07-20', 276.5, 276.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'cumar cisman', 1, 106.5, 106.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 20 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaaban', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter 7005', 1, 15.0, 15.0);
  -- Sale: dhuubo /ahmed case on 2026-07-20
  INSERT INTO customers (name) VALUES ('dhuubo /ahmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo /ahmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo /ahmed case', '2026-07-20', 285.6, 285.6, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush xidhiye 4', 1, 160.0, 160.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'muraayad haad goal ah', 1, 37.0, 37.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal qafis', 1, 88.0, 88.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'laba abwaal', 1, 0.6, 0.6);
  -- Sale: hamze abdijibaar on 2026-07-20
  INSERT INTO customers (name) VALUES ('hamze abdijibaar') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'hamze abdijibaar' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'hamze abdijibaar', '2026-07-20', 115.0, 115.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweysyo', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xabag', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 2.0, 2.0);
  -- Sale: cumar cisman on 2026-07-20
  INSERT INTO customers (name) VALUES ('cumar cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cumar cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cumar cisman', '2026-07-20', 24.6, 24.6, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobso', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'laba bool 12 ah', 1, 0.6, 0.6);
  -- Sale: cumar cisman on 2026-07-20
  INSERT INTO customers (name) VALUES ('cumar cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cumar cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cumar cisman', '2026-07-20', 11.5, 11.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'silisteeb', 1, 0.5, 0.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'guluuboH4', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'guluuboH3', 1, 6.0, 6.0);
  -- Sale: Ina nabadidiid on 2026-07-20
  INSERT INTO customers (name) VALUES ('Ina nabadidiid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Ina nabadidiid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Ina nabadidiid', '2026-07-20', 100.2, 100.2, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'silisteeb', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'labad bool 12', 1, 0.6, 0.6);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'toorno', 1, 40.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo', 1, 7.0, 7.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'waayer laydh', 1, 9.0, 9.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siiq leewer', 1, 37.0, 37.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 2.6, 2.6);
  -- Sale: Ali baashe on 2026-07-27
  INSERT INTO customers (name) VALUES ('Ali baashe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Ali baashe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Ali baashe', '2026-07-27', 329.5, 329.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter 2liter', 1, 108.0, 108.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  naafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo daxal', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xayd tasqiyad', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabadh raam', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweysyo', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xabag loox', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balays laba xabo', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siisteeb', 1, 0.5, 0.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash dheeha', 1, 3.0, 3.0);
  -- Sale: Walk-in Customer on 2026-07-28
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-07-28', 14.0, 14.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter 70005', 1, 14.0, 14.0);
  -- Sale: sharmarke/ ina nabadiid on 2026-07-29
  INSERT INTO customers (name) VALUES ('sharmarke/ ina nabadiid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sharmarke/ ina nabadiid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sharmarke/ ina nabadiid', '2026-07-29', 90.0, 90.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'qashaafad', 1, 90.0, 90.0);
  -- Sale: Walk-in Customer on 2026-07-30
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-07-30', 168.0, 168.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 24.0, 24.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter caqayad', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter 70005', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 15.0, 15.0);
  -- Sale: dhuubo /ahmed case on 2026-07-30
  INSERT INTO customers (name) VALUES ('dhuubo /ahmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo /ahmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo /ahmed case', '2026-07-30', 90.0, 90.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'il horeTX 400', 1, 90.0, 90.0);
  -- Sale: bishii August 2026 on 2026-07-30
  INSERT INTO customers (name) VALUES ('bishii August 2026') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'bishii August 2026' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'bishii August 2026', '2026-07-30', 0.4, 0.4, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'labal bool toban 10 ah', 1, 0.4, 0.4);
  -- Sale: ina shaadh cas on 2026-08-02
  INSERT INTO customers (name) VALUES ('ina shaadh cas') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina shaadh cas' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina shaadh cas', '2026-08-02', 224.0, 224.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nnafato', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush xidhiye', 1, 80.0, 80.0);
  -- Sale: aden bogsiiye          02 /08/2026 on 2026-08-02
  INSERT INTO customers (name) VALUES ('aden bogsiiye          02 /08/2026') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'aden bogsiiye          02 /08/2026' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'aden bogsiiye          02 /08/2026', '2026-08-02', 153.5, 153.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal  14 ah', 1, 0.6, 0.6);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indhaha dhinaca', 1, 48.0, 48.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysaro', 1, 16.0, 16.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buushqafis', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'biin rimoodh', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad 22 ah', 1, 3.5, 3.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh biif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal', 1, 2.4, 2.4);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shimisyo', 1, 30.0, 30.0);
  -- Sale: Jiiro on 2026-08-02
  INSERT INTO customers (name) VALUES ('Jiiro') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Jiiro' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Jiiro', '2026-08-02', 136.0, 136.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaaban', 1, 10.0, 10.0);
  -- Sale: khader  weyrax on 2026-08-03
  INSERT INTO customers (name) VALUES ('khader  weyrax') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'khader  weyrax' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'khader  weyrax', '2026-08-03', 195.0, 195.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal khafis', 1, 170.0, 170.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh biif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash dheeha', 1, 9.0, 9.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid hydroolik', 1, 2.0, 2.0);
  -- Sale: xasan godad  03/08 /2026 on 2026-08-03
  INSERT INTO customers (name) VALUES ('xasan godad  03/08 /2026') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'xasan godad  03/08 /2026' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'xasan godad  03/08 /2026', '2026-08-03', 8.3, 8.3, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'laxaamad', 1, 6.5, 6.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'isku dar', 1, 1.8, 1.8);
  -- Sale: dhuubo /ahmed case on 2026-08-03
  INSERT INTO customers (name) VALUES ('dhuubo /ahmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo /ahmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo /ahmed case', '2026-08-03', 180.0, 180.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 20 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer c', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  naafato', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuyuub', 1, 22.0, 22.0);
  -- Sale: bashiir 6 on 2020-08-06
  INSERT INTO customers (name) VALUES ('bashiir 6') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'bashiir 6' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'bashiir 6', '2020-08-06', 45.0, 45.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweys 2 sad iyo badh', 1, 45.0, 45.0);
  -- Sale: dhuux cisman on 2026-08-06
  INSERT INTO customers (name) VALUES ('dhuux cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cisman', '2026-08-06', 58.0, 58.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dher org', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter caqayad', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air freshbiif', 1, 2.0, 2.0);
  -- Sale: saalax  xabiib on 2026-08-08
  INSERT INTO customers (name) VALUES ('saalax  xabiib') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'saalax  xabiib' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'saalax  xabiib', '2026-08-08', 177.0, 177.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter 3liter', 1, 105.0, 105.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer org', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 12.0, 12.0);
  -- Sale: abdigoordambe on 2026-08-08
  INSERT INTO customers (name) VALUES ('abdigoordambe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'abdigoordambe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'abdigoordambe', '2026-08-08', 179.0, 179.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter and 2 liter', 1, 108.0, 108.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  naafato org', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'banad', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid delo', 1, 3.0, 3.0);
  -- Sale: tuur siyine on 2026-08-08
  INSERT INTO customers (name) VALUES ('tuur siyine') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'tuur siyine' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'tuur siyine', '2026-08-08', 525.0, 525.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabadh kaman', 1, 220.0, 220.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'bayteryo', 1, 290.0, 290.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'ban xaydh', 1, 15.0, 15.0);
  -- Sale: c/raxman mawliid haybe on 2026-08-09
  INSERT INTO customers (name) VALUES ('c/raxman mawliid haybe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'c/raxman mawliid haybe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'c/raxman mawliid haybe', '2026-08-09', 16.0, 16.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 4 liter', 1, 13.5, 13.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter yar', 1, 1.5, 1.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saleed bareek', 1, 1.0, 1.0);
  -- Sale: dhuubo /ahmed case on 2026-08-09
  INSERT INTO customers (name) VALUES ('dhuubo /ahmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo /ahmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo /ahmed case', '2026-08-09', 158.0, 158.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuyuub', 1, 22.0, 22.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash dheeha', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'daawe', 1, 120.0, 120.0);
  -- Sale: social ahmed case on 2026-08-09
  INSERT INTO customers (name) VALUES ('social ahmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'social ahmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'social ahmed case', '2026-08-09', 279.0, 279.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 20 liter one liter', 1, 104.0, 104.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid gaban', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  naafato', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 13.0, 13.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashafad TX400', 1, 100.0, 100.0);
  -- Sale: saalax  xabiib   cidig on 2026-08-09
  INSERT INTO customers (name) VALUES ('saalax  xabiib   cidig') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'saalax  xabiib   cidig' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'saalax  xabiib   cidig', '2026-08-09', 15.0, 15.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter caqqayad', 1, 15.0, 15.0);
  -- Sale: abdi hulube on 2026-08-10
  INSERT INTO customers (name) VALUES ('abdi hulube') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'abdi hulube' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'abdi hulube', '2026-08-10', 85.0, 85.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal qafis dambe', 1, 85.0, 85.0);
  -- Sale: dhuubo /ahmed case on 2026-08-10
  INSERT INTO customers (name) VALUES ('dhuubo /ahmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo /ahmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo /ahmed case', '2026-08-10', 3.0, 3.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuubo naqas', 1, 3.0, 3.0);
  -- Sale: abdi xerow dayax on 2026-08-10
  INSERT INTO customers (name) VALUES ('abdi xerow dayax') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'abdi xerow dayax' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'abdi xerow dayax', '2026-08-10', 100.0, 100.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuul baanado ulaweyne', 1, 100.0, 100.0);
  -- Sale: bareeg/ cumar on 2026-08-10
  INSERT INTO customers (name) VALUES ('bareeg/ cumar') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'bareeg/ cumar' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'bareeg/ cumar', '2026-08-10', 110.0, 110.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuul baanado ulaweyne', 1, 110.0, 110.0);
  -- Sale: abdikayd / iid ethiopia on 2026-08-10
  INSERT INTO customers (name) VALUES ('abdikayd / iid ethiopia') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'abdikayd / iid ethiopia' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'abdikayd / iid ethiopia', '2026-08-10', 105.0, 105.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuul baanado ulaweyne', 1, 105.0, 105.0);
  -- Sale: Ali baashe on 2026-08-12
  INSERT INTO customers (name) VALUES ('Ali baashe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Ali baashe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Ali baashe', '2026-08-12', 200.0, 200.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal khafis dambe', 1, 170.0, 170.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo naafato', 1, 30.0, 30.0);
  -- Sale: Alaab ah on 2026-08-12
  INSERT INTO customers (name) VALUES ('Alaab ah') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Alaab ah' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Alaab ah', '2026-08-12', 9.0, 9.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad 10 iyi 12 ah', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanado 12,13,14, iib toos ah', 1, 6.0, 6.0);
  -- Sale: goob joog on 2026-08-13
  INSERT INTO customers (name) VALUES ('goob joog') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'goob joog' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'goob joog', '2026-08-13', 89.0, 89.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal hore 400', 1, 85.0, 85.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lingtools', 1, 2.0, 2.0);
  -- Sale: ina janaale on 2026-08-13
  INSERT INTO customers (name) VALUES ('ina janaale') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina janaale' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina janaale', '2026-08-13', 120.5, 120.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'daawe', 1, 120.0, 120.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baaleys', 1, 0.5, 0.5);
  -- Sale: xasan xa aji faarax on 2026-08-14
  INSERT INTO customers (name) VALUES ('xasan xa aji faarax') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'xasan xa aji faarax' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'xasan xa aji faarax', '2026-08-14', 2.7, 2.7, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos yar', 1, 2.7, 2.7);
  -- Sale: ina shaadh cas on 2026-08-15
  INSERT INTO customers (name) VALUES ('ina shaadh cas') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina shaadh cas' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina shaadh cas', '2026-08-15', 80.25, 80.25, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'muraad haad 371', 1, 80.0, 80.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'bool 12 ah', 1, 0.25, 0.25);
  -- Sale: Walk-in Customer on 2026-08-15
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-15', 5.0, 5.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad ii ah 17', 1, 5.0, 5.0);
  -- Sale: sidii cisman on 2026-08-16
  INSERT INTO customers (name) VALUES ('sidii cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sidii cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sidii cisman', '2026-08-16', 8.0, 8.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid hyrolic', 1, 2.0, 2.0);
  -- Sale: bilaa bareek on 2026-08-16
  INSERT INTO customers (name) VALUES ('bilaa bareek') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'bilaa bareek' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'bilaa bareek', '2026-08-16', 101.0, 101.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25b liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 1.0, 1.0);
  -- Sale: dhuux cisman   1 on 2026-08-07
  INSERT INTO customers (name) VALUES ('dhuux cisman   1') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cisman   1' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cisman   1', '2026-08-07', 189.5, 189.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siiq leewer', 1, 37.0, 37.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shimisyo', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indhaha dhinaca', 1, 16.0, 16.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'silisteeb', 1, 0.5, 0.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo xaydh', 1, 3.0, 3.0);
  -- Sale: sharmarke/ ina nabadiid on 2026-08-17
  INSERT INTO customers (name) VALUES ('sharmarke/ ina nabadiid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sharmarke/ ina nabadiid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sharmarke/ ina nabadiid', '2026-08-17', 158.0, 158.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lamdado', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato dheer', 1, 11.0, 11.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter 25 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 2.0, 2.0);
  -- Sale: ina malow on 2026-08-19
  INSERT INTO customers (name) VALUES ('ina malow') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina malow' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina malow', '2026-08-19', 84.0, 84.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air freshbiif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xayd tasqiyad', 1, 13.0, 13.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'boltayir 371', 1, 45.0, 45.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo daxal', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'badhada ac', 1, 15.0, 15.0);
  -- Sale: Walk-in Customer on 2026-08-15
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-15', 120.0, 120.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'daawe', 1, 120.0, 120.0);
  -- Sale: bareeg/ cumar on 2026-08-19
  INSERT INTO customers (name) VALUES ('bareeg/ cumar') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'bareeg/ cumar' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'bareeg/ cumar', '2026-08-19', 314.0, 314.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 liter', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad 30', 1, 5.0, 5.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad 22 ah', 1, 3.5, 3.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'banad 13 ah', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad 14 ah', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'badhad ac', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'isku dar', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabadh kaban', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh biif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwal 12 and 10', 1, 0.5, 0.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'hand pump', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 15.0, 15.0);
  -- Sale: dhuubo on 2026-08-19
  INSERT INTO customers (name) VALUES ('dhuubo') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo', '2026-08-19', 302.0, 302.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo daxal', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo kaanbydher', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush kaaban', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 22', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 38.0, 38.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 and 5 l', 1, 132.0, 132.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 5.0, 5.0);
  -- Sale: dhago cade on 2026-08-20
  INSERT INTO customers (name) VALUES ('dhago cade') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhago cade' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhago cade', '2026-08-20', 284.0, 284.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 27 l', 1, 108.0, 108.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer org', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khasaafad', 1, 85.0, 85.0);
  -- Sale: Walk-in Customer on 2026-08-20
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-20', 35.0, 35.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siiq leewer', 1, 35.0, 35.0);
  -- Sale: Walk-in Customer on 2026-08-20
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-20', 13.0, 13.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo naqas 371', 1, 13.0, 13.0);
  -- Sale: Walk-in Customer on 2026-08-20
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-20', 4.0, 4.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 4.0, 4.0);
  -- Sale: c/shakuur on 2026-08-20
  INSERT INTO customers (name) VALUES ('c/shakuur') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'c/shakuur' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'c/shakuur', '2026-08-20', 191.0, 191.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid', 1, 114.0, 114.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  saliid org', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  -- Sale: mo siciid on 2026-08-21
  INSERT INTO customers (name) VALUES ('mo siciid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'mo siciid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'mo siciid', '2026-08-21', 69.0, 69.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filtre  dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter caqaayad', 1, 15.0, 15.0);
  -- Sale: Walk-in Customer on 2026-08-20
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-20', 7.0, 7.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  -- Sale: cabdi najax   wayrax on 2026-08-21
  INSERT INTO customers (name) VALUES ('cabdi najax   wayrax') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cabdi najax   wayrax' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cabdi najax   wayrax', '2026-08-21', 222.0, 222.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 18.0, 18.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo  xaydh', 1, 3.0, 3.0);
  -- Sale: tuur siyine on 2026-08-22
  INSERT INTO customers (name) VALUES ('tuur siyine') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'tuur siyine' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'tuur siyine', '2026-08-22', 135.0, 135.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal khafis  dambe', 1, 123.0, 123.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'isbirino kanweys', 1, 8.0, 8.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush qafis', 1, 4.0, 4.0);
  -- Sale: Walk-in Customer on 2026-08-23
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-23', 6.0, 6.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo daxal', 1, 6.0, 6.0);
  -- Sale: Walk-in Customer on 2026-08-23
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-23', 4.5, 4.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'connector 12', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lington black', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'swich bakhtiso', 1, 1.5, 1.5);
  -- Sale: Walk-in Customer on 2026-08-24
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-24', 5.9, 5.9, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air freshbiif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'hydralic', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid bareeg', 1, 0.9, 0.9);
  -- Sale: naasir mohamed ali on 2026-08-25
  INSERT INTO customers (name) VALUES ('naasir mohamed ali') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'naasir mohamed ali' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'naasir mohamed ali', '2026-08-25', 37.0, 37.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 10 liter', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid bareeg', 1, 1.0, 1.0);
  -- Sale: c/casis cadaan weyne on 2026-08-25
  INSERT INTO customers (name) VALUES ('c/casis cadaan weyne') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'c/casis cadaan weyne' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'c/casis cadaan weyne', '2026-08-25', 15.0, 15.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo naafato', 1, 15.0, 15.0);
  -- Sale: ayuub on 2026-08-25
  INSERT INTO customers (name) VALUES ('ayuub') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ayuub' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ayuub', '2026-08-25', 5.0, 5.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, '2 liter salid', 1, 3.5, 3.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter yar', 1, 1.5, 1.5);
  -- Sale: cidig on 2026-08-25
  INSERT INTO customers (name) VALUES ('cidig') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cidig' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cidig', '2026-08-25', 153.0, 153.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashaafad  400 TX', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siiq leewer TX', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'guluubo H4', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 15.0, 15.0);
  -- Sale: Walk-in Customer on 2026-08-25
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-25', 11.0, 11.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'salid delo', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid hydaroolik', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 6.0, 6.0);
  -- Sale: khader yusuf on 2026-08-26
  INSERT INTO customers (name) VALUES ('khader yusuf') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'khader yusuf' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'khader yusuf', '2026-08-26', 40.0, 40.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad ula yare', 1, 40.0, 40.0);
  -- Sale: Walk-in Customer on 2026-08-25
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-25', 3.5, 3.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos yar', 1, 3.5, 3.5);
  -- Sale: sharmarke siyaad on 2026-08-26
  INSERT INTO customers (name) VALUES ('sharmarke siyaad') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sharmarke siyaad' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sharmarke siyaad', '2026-08-26', 160.0, 160.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashaafad    371', 1, 160.0, 160.0);
  -- Sale: dhuux cisman on 2026-08-27
  INSERT INTO customers (name) VALUES ('dhuux cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cisman', '2026-08-27', 166.0, 166.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'okiyo rimoodh', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siiq leewar', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kabaal', 1, 20.0, 20.0);
  -- Sale: Walk-in Customer on 2026-08-27
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-27', 1.5, 1.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tasqiyad yar', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'silisteeb', 1, 0.5, 0.5);
  -- Sale: cumar siciid on 2026-08-27
  INSERT INTO customers (name) VALUES ('cumar siciid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cumar siciid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cumar siciid', '2026-08-27', 40.0, 40.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'jeeg 32', 1, 38.0, 38.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 2.0, 2.0);
  -- Sale: sidiiq  cisman 27 /2026 on 2026-08-27
  INSERT INTO customers (name) VALUES ('sidiiq  cisman 27 /2026') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sidiiq  cisman 27 /2026' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sidiiq  cisman 27 /2026', '2026-08-27', 15.0, 15.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'bam xaydh', 1, 15.0, 15.0);
  -- Sale: dhuubo on 2026-08-27
  INSERT INTO customers (name) VALUES ('dhuubo') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo', '2026-08-27', 231.0, 231.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 39.0, 39.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 and 5 l', 1, 132.0, 132.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 5.0, 5.0);
  -- Sale: cumar siciid on 2026-08-29
  INSERT INTO customers (name) VALUES ('cumar siciid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cumar siciid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cumar siciid', '2026-08-29', 24.0, 24.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indho dhinac ah', 1, 16.0, 16.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indho dhinac ah', 1, 8.0, 8.0);
  -- Sale: abdi shaadh cas on 2026-08-29
  INSERT INTO customers (name) VALUES ('abdi shaadh cas') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'abdi shaadh cas' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'abdi shaadh cas', '2026-08-29', 179.0, 179.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter naafato', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'alaab kle', 1, 15.0, 15.0);
  -- Sale: ahmed case social on 2026-08-29
  INSERT INTO customers (name) VALUES ('ahmed case social') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ahmed case social' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ahmed case social', '2026-08-29', 466.0, 466.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'batery', 1, 280.0, 280.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 L', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 15.0, 15.0);
  -- Sale: Walk-in Customer on 2026-08-30
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-30', 42.0, 42.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'bool gudban', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush okiyo', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo', 1, 2.0, 2.0);
  -- Sale: goob joog on 2026-08-30
  INSERT INTO customers (name) VALUES ('goob joog') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'goob joog' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'goob joog', '2026-08-30', 95.0, 95.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuul baanado ulaweyne', 1, 95.0, 95.0);
  -- Sale: Walk-in Customer on 2026-08-30
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-30', 60.0, 60.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabdh rimoodh', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'oki gudban', 1, 30.0, 30.0);
  -- Sale: aden bogsiiye 30 /08/2026 on 2026-08-30
  INSERT INTO customers (name) VALUES ('aden bogsiiye 30 /08/2026') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'aden bogsiiye 30 /08/2026' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'aden bogsiiye 30 /08/2026', '2026-08-30', 208.0, 208.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush kaaban', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush qafis sabarad weyn', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'keebino', 1, 42.0, 42.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  naafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabdadh kabaan rimoodh', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush okiyo', 1, 10.0, 10.0);
  -- Sale: Walk-in Customer on 2026-08-30
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-08-30', 1.0, 1.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  -- Sale: ahmed ceeg on 2026-08-30
  INSERT INTO customers (name) VALUES ('ahmed ceeg') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ahmed ceeg' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ahmed ceeg', '2026-08-30', 1500.0, 1500.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shidh egene', 1, 1500.0, 1500.0);
  -- Sale: ina shaadh cas on 2026-08-31
  INSERT INTO customers (name) VALUES ('ina shaadh cas') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina shaadh cas' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina shaadh cas', '2026-08-31', 139.0, 139.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siiq leewar', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'biin qafis shakal', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal hore 371', 1, 60.0, 60.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo bireeg hore', 1, 17.0, 17.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo bambo', 1, 5.0, 5.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lamdad tuunbo', 1, 16.0, 16.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo karbaydhar', 1, 2.0, 2.0);
  -- Sale: jiiro on 2026-08-31
  INSERT INTO customers (name) VALUES ('jiiro') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'jiiro' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'jiiro', '2026-08-31', 45.0, 45.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo nafato', 1, 45.0, 45.0);
  -- Sale: dhego cade on 2026-09-01
  INSERT INTO customers (name) VALUES ('dhego cade') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhego cade' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhego cade', '2026-09-01', 35.0, 35.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shan bool rimoodh', 1, 35.0, 35.0);
  -- Sale: ina nabadid on 2026-09-01
  INSERT INTO customers (name) VALUES ('ina nabadid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina nabadid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina nabadid', '2026-09-01', 21.0, 21.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 13.0, 13.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh', 1, 2.0, 2.0);
  -- Sale: abdi goordambe on 2026-09-02
  INSERT INTO customers (name) VALUES ('abdi goordambe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'abdi goordambe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'abdi goordambe', '2026-09-02', 205.0, 205.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 27 liter', 1, 118.0, 118.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 24.0, 24.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid filter', 1, 34.0, 34.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 29.0, 29.0);
  -- Sale: kaarto on 2026-09-02
  INSERT INTO customers (name) VALUES ('kaarto') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'kaarto' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'kaarto', '2026-09-02', 190.0, 190.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 23.0, 23.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid filter', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'nafato filter', 1, 27.0, 27.0);
  -- Sale: maslax on 2026-09-02
  INSERT INTO customers (name) VALUES ('maslax') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'maslax' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'maslax', '2026-09-02', 231.0, 231.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 28 L', 1, 122.0, 122.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter saliid', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil naafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shimisyo al furaad', 1, 8.0, 8.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush kabaan', 1, 36.0, 36.0);
  -- Sale: mo awil on 2026-09-02
  INSERT INTO customers (name) VALUES ('mo awil') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'mo awil' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'mo awil', '2026-09-02', 12.0, 12.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid havoline', 1, 10.5, 10.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter yar', 1, 1.5, 1.5);
  -- Sale: hamze abdijibaar on 2026-09-02
  INSERT INTO customers (name) VALUES ('hamze abdijibaar') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'hamze abdijibaar' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'hamze abdijibaar', '2026-09-02', 100.0, 100.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashaafad  400 TX', 1, 100.0, 100.0);
  -- Sale: daraam on 2026-09-02
  INSERT INTO customers (name) VALUES ('daraam') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'daraam' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'daraam', '2026-09-02', 385.0, 385.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, '3 xabo', 1, 385.0, 385.0);
  -- Sale: Walk-in Customer on 2026-09-02
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-09-02', 1.0, 1.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 1.0, 1.0);
  -- Sale: c/shakuur mawliid on 2026-09-02
  INSERT INTO customers (name) VALUES ('c/shakuur mawliid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'c/shakuur mawliid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'c/shakuur mawliid', '2026-09-02', 117.5, 117.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashaafad tx 400', 1, 100.0, 100.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid hyrolic', 1, 2.5, 2.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  saliid org', 1, 15.0, 15.0);
  -- Sale: iid ethiopia on 2026-09-03
  INSERT INTO customers (name) VALUES ('iid ethiopia') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'iid ethiopia' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'iid ethiopia', '2026-09-03', 529.5, 529.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'afar weysar bir', 1, 18.0, 18.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'gees candho', 1, 16.0, 16.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'canjalad candho yar', 1, 40.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dhiiqo linstop', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kanbaydhar', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baalays', 1, 1.5, 1.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush roum', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'sabarad', 1, 120.0, 120.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo kaanbydher', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'canjalad candho yar', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lamdad candho', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'caleen weyn /irman', 1, 70.0, 70.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'cidiyo', 1, 8.0, 8.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweys sad', 1, 50.0, 50.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar hawsin', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar candho', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'halow shoft', 1, 40.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo logead', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'geer candho', 1, 60.0, 60.0);
  -- Sale: hasan godad on 2026-06-03
  INSERT INTO customers (name) VALUES ('hasan godad') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'hasan godad' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'hasan godad', '2026-06-03', 14.1, 14.1, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 19', 1, 12.5, 12.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 13 ah', 1, 1.6, 1.6);
  -- Sale: cidig on 2026-09-03
  INSERT INTO customers (name) VALUES ('cidig') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cidig' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cidig', '2026-09-03', 193.0, 193.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 29.0, 29.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil naafato', 1, 28.0, 28.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haaaqo', 1, 1.0, 1.0);
  -- Sale: Walk-in Customer on 2026-09-03
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-09-03', 4.0, 4.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid hydaroolik', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air freshbiif', 1, 2.0, 2.0);
  -- Sale: bareeg/ cumar on 2026-09-04
  INSERT INTO customers (name) VALUES ('bareeg/ cumar') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'bareeg/ cumar' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'bareeg/ cumar', '2026-09-04', 276.2, 276.2, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo daxal', 1, 2.5, 2.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo qalajiso', 1, 2.5, 2.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baalays', 1, 2.5, 2.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xabag', 1, 3.5, 3.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'sheeg baane', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweysyo 2 sad', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 18.0, 18.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'mareeg', 1, 60.0, 60.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xabag linstop', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'silisteeb', 1, 0.5, 0.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kiibiino', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'bool 19 ah', 1, 0.7, 0.7);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'keybiino nasteex', 1, 12.0, 12.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush roum', 1, 8.0, 8.0);
  -- Sale: sanweyne on 2026-09-04
  INSERT INTO customers (name) VALUES ('sanweyne') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sanweyne' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sanweyne', '2026-09-04', 80.0, 80.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashaafad    371', 1, 80.0, 80.0);
  -- Sale: Walk-in Customer on 2026-09-04
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-09-04', 230.0, 230.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dhabanta dabka', 1, 230.0, 230.0);
  -- Sale: caano 5 /9/2026 on 2026-09-04
  INSERT INTO customers (name) VALUES ('caano 5 /9/2026') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'caano 5 /9/2026' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'caano 5 /9/2026', '2026-09-04', 210.0, 210.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabadh kaban', 1, 210.0, 210.0);
  -- Sale: social on 2026-09-05
  INSERT INTO customers (name) VALUES ('social') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'social' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'social', '2026-09-05', 43.0, 43.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 13.0, 13.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shaag baane', 1, 30.0, 30.0);
  -- Sale: horn petrolin on 2026-09-05
  INSERT INTO customers (name) VALUES ('horn petrolin') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'horn petrolin' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'horn petrolin', '2026-09-05', 38.0, 38.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dhaban dab', 1, 38.0, 38.0);
  -- Sale: khader weyrax on 2026-09-06
  INSERT INTO customers (name) VALUES ('khader weyrax') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'khader weyrax' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'khader weyrax', '2026-09-06', 53.0, 53.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'siiq weer', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwal 24', 1, 10.0, 10.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwal 22', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo kaanbydher', 1, 4.0, 4.0);
  -- Sale: sharmarke siyaad on 2026-09-08
  INSERT INTO customers (name) VALUES ('sharmarke siyaad') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sharmarke siyaad' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sharmarke siyaad', '2026-09-08', 120.0, 120.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'daawe', 1, 120.0, 120.0);
  -- Sale: ali baashe on 2026-09-08
  INSERT INTO customers (name) VALUES ('ali baashe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ali baashe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ali baashe', '2026-09-08', 65.0, 65.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rikoodh', 1, 65.0, 65.0);
  -- Sale: Walk-in Customer on 2026-09-08
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-09-08', 1.0, 1.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwal 10', 1, 1.0, 1.0);
  -- Sale: rimoodh m.maame on 2026-09-09
  INSERT INTO customers (name) VALUES ('rimoodh m.maame') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'rimoodh m.maame' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'rimoodh m.maame', '2026-09-09', 95.5, 95.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweyso rimoodh', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'keebin kaanweyso bigidhe', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaanweysyo', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xabag', 1, 3.5, 3.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal rimoodh', 1, 12.0, 12.0);
  -- Sale: ina malow on 2026-09-09
  INSERT INTO customers (name) VALUES ('ina malow') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina malow' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina malow', '2026-09-09', 8.0, 8.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'ballash', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh biif', 1, 2.0, 2.0);
  -- Sale: tuur siyine on 2026-09-09
  INSERT INTO customers (name) VALUES ('tuur siyine') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'tuur siyine' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'tuur siyine', '2026-09-09', 15.0, 15.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresbiif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'keebino', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo xaydh', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo daxal', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuunbo', 1, 2.0, 2.0);
  -- Sale: abdikaren on 2026-09-09
  INSERT INTO customers (name) VALUES ('abdikaren') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'abdikaren' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'abdikaren', '2026-09-09', 190.0, 190.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'salid', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 22.0, 22.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f saliid', 1, 29.0, 29.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f nafato', 1, 28.0, 28.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  -- Sale: cumar ileeye on 2026-09-09
  INSERT INTO customers (name) VALUES ('cumar ileeye') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cumar ileeye' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cumar ileeye', '2026-09-09', 25.0, 25.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indhaha dhinaca', 1, 24.0, 24.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 10', 1, 1.0, 1.0);
  -- Sale: tuur siyine on 2026-09-10
  INSERT INTO customers (name) VALUES ('tuur siyine') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'tuur siyine' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'tuur siyine', '2026-09-10', 80.0, 80.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'khashaafad    371', 1, 80.0, 80.0);
  -- Sale: jiiro on 2026-09-10
  INSERT INTO customers (name) VALUES ('jiiro') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'jiiro' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'jiiro', '2026-09-10', 164.0, 164.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 and 5 l', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f saliid', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil nafato', 1, 15.0, 15.0);
  -- Sale: sanweyne on 2026-09-12
  INSERT INTO customers (name) VALUES ('sanweyne') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sanweyne' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sanweyne', '2026-09-12', 269.0, 269.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'salid 28 l', 1, 125.0, 125.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil gaban', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil nafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balaash', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh biif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuubo xaydh', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'daboolo taayir', 1, 40.0, 40.0);
  -- Sale: mooto on 2026-09-12
  INSERT INTO customers (name) VALUES ('mooto') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'mooto' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'mooto', '2026-09-12', 3.5, 3.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid delo', 1, 3.5, 3.5);
  -- Sale: dhuubo ahmed case on 2026-09-12
  INSERT INTO customers (name) VALUES ('dhuubo ahmed case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuubo ahmed case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuubo ahmed case', '2026-09-12', 110.0, 110.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabadh kaban', 1, 110.0, 110.0);
  -- Sale: hasan godad on 2026-09-13
  INSERT INTO customers (name) VALUES ('hasan godad') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'hasan godad' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'hasan godad', '2026-09-13', 39.0, 39.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indhaha dhinaca', 1, 24.0, 24.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indho dheer', 1, 15.0, 15.0);
  -- Sale: kayse  mouse on 2026-09-13
  INSERT INTO customers (name) VALUES ('kayse  mouse') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'kayse  mouse' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'kayse  mouse', '2026-09-13', 177.0, 177.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shidh power', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lamdad juundo', 1, 16.0, 16.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'qaliso', 1, 2.5, 2.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dhiiqo linstop', 1, 2.5, 2.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baaleys', 1, 0.5, 0.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'hydralic', 1, 12.5, 12.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'isku dar', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xidhhidhiye toosan', 1, 105.0, 105.0);
  -- Sale: hasan ogaal on 2026-09-13
  INSERT INTO customers (name) VALUES ('hasan ogaal') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'hasan ogaal' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'hasan ogaal', '2026-09-13', 3272.3, 3272.3, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indhaha dhinaca', 1, 104.0, 104.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 19', 1, 3.8, 3.8);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'silisteeb', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xadhig', 1, 3.0, 3.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baraasado', 1, 300.0, 300.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'bombo dhan', 1, 2300.0, 2300.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abukaashe', 1, 4.0, 4.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'isha dhan weyn', 1, 90.0, 90.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'isbirino kanweys', 1, 40.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid hydaroolik', 1, 5.0, 5.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakal dambe', 1, 170.0, 170.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shakalo hore', 1, 170.0, 170.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad 10 abdilahi jaar pare', 1, 1.5, 1.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 19', 1, 1.0, 1.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 10 ah', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 22ah', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kabaal bigidhe', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indha kaluun', 1, 32.0, 32.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 10', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'balash', 1, 6.0, 6.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'safeex', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresbiif', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'air fresh kawar', 1, 5.0, 5.0);
  -- Sale: Ahmed 707 on 2026-09-14
  INSERT INTO customers (name) VALUES ('Ahmed 707') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Ahmed 707' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Ahmed 707', '2026-09-14', 209.0, 209.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'muraayad haad 371', 1, 85.0, 85.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban saliid', 1, 36.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  naafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f dheer nafato', 1, 18.0, 18.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'muraad gool daqad bigidhe', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'murayad dhug saydh irman', 1, 15.0, 15.0);
  -- Sale: Walk-in Customer on 2026-09-15
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-09-15', 1.0, 1.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid bareeg', 1, 1.0, 1.0);
  -- Sale: jiiro on 2026-09-16
  INSERT INTO customers (name) VALUES ('jiiro') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'jiiro' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'jiiro', '2026-09-16', 120.0, 120.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'daawe', 1, 120.0, 120.0);
  -- Sale: maxamed jirde on 2026-09-16
  INSERT INTO customers (name) VALUES ('maxamed jirde') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'maxamed jirde' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'maxamed jirde', '2026-09-16', 80.0, 80.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'muraad haad TX', 1, 80.0, 80.0);
  -- Sale: hasan ogaal on 2026-09-17
  INSERT INTO customers (name) VALUES ('hasan ogaal') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'hasan ogaal' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'hasan ogaal', '2026-09-17', 15.0, 15.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh hobos', 1, 15.0, 15.0);
  -- Sale: atakooyin naqas bigidhe on 2026-09-17
  INSERT INTO customers (name) VALUES ('atakooyin naqas bigidhe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'atakooyin naqas bigidhe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'atakooyin naqas bigidhe', '2026-09-17', 255.0, 255.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo qalajiso', 1, 2.5, 2.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'Ac  komorosool', 1, 250.0, 250.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dawo kaabaydhar', 1, 2.5, 2.5);
  -- Sale: sharmarke siyaad on 2026-09-17
  INSERT INTO customers (name) VALUES ('sharmarke siyaad') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sharmarke siyaad' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sharmarke siyaad', '2026-09-17', 690.0, 690.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25', 1, 105.0, 105.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil dheer', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f saliid', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f nafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'taangi nafato', 1, 500.0, 500.0);
  -- Sale: cabdishakuur mawliid on 2026-09-17
  INSERT INTO customers (name) VALUES ('cabdishakuur mawliid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'cabdishakuur mawliid' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'cabdishakuur mawliid', '2026-09-17', 27.0, 27.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'biin rimoodh', 1, 27.0, 27.0);
  -- Sale: ina wadad yare on 2026-09-18
  INSERT INTO customers (name) VALUES ('ina wadad yare') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ina wadad yare' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ina wadad yare', '2026-09-18', 784.0, 784.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid  4 and 8 l', 1, 454.0, 454.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil dheer', 1, 60.0, 60.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f nafato', 1, 60.0, 60.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f saliid', 1, 90.0, 90.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kaawo', 1, 120.0, 120.0);
  -- Sale: 8 bool on 2026-09-19
  INSERT INTO customers (name) VALUES ('8 bool') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = '8 bool' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, '8 bool', '2026-09-19', 81.5, 81.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'indho dhinac ah', 1, 72.0, 72.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal', 1, 6.5, 6.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'silisteeb', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fiyuus', 1, 1.0, 1.0);
  -- Sale: sidiiq cisman on 2026-04-19
  INSERT INTO customers (name) VALUES ('sidiiq cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'sidiiq cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'sidiiq cisman', '2026-04-19', 8.0, 8.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal 19', 1, 1.5, 1.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 6.5, 6.5);
  -- Sale: goob joog on 2026-09-19
  INSERT INTO customers (name) VALUES ('goob joog') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'goob joog' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'goob joog', '2026-09-19', 143.5, 143.5, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25 and 2 l', 1, 113.5, 113.5);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter  naafato', 1, 30.0, 30.0);
  -- Sale: dhuux cismaan on 2026-09-19
  INSERT INTO customers (name) VALUES ('dhuux cismaan') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cismaan' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cismaan', '2026-09-19', 42.0, 42.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'abwaal v', 1, 42.0, 42.0);
  -- Sale: ali baashe on 2026-09-20
  INSERT INTO customers (name) VALUES ('ali baashe') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'ali baashe' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'ali baashe', '2026-09-20', 45.0, 45.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'tuubo naafato', 1, 45.0, 45.0);
  -- Sale: muxyadiin on 2026-09-20
  INSERT INTO customers (name) VALUES ('muxyadiin') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'muxyadiin' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'muxyadiin', '2026-09-20', 120.0, 120.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'daawe', 1, 120.0, 120.0);
  -- Sale: najax weyrax on 2026-09-20
  INSERT INTO customers (name) VALUES ('najax weyrax') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'najax weyrax' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'najax weyrax', '2026-09-20', 233.0, 233.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 28 L', 1, 123.0, 123.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 25.0, 25.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter gaban', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter nafato', 1, 30.0, 30.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'xaydh tasqiyad', 1, 14.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'ballash', 1, 6.0, 6.0);
  -- Sale: Walk-in Customer on 2026-09-20
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-09-20', 1.0, 1.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid brake', 1, 1.0, 1.0);
  -- Sale: c/kariin sacad on 2026-09-21
  INSERT INTO customers (name) VALUES ('c/kariin sacad') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'c/kariin sacad' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'c/kariin sacad', '2026-09-21', 141.0, 141.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'kabaan', 1, 140.0, 140.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 1.0, 1.0);
  -- Sale: dhuux cisman on 2026-09-21
  INSERT INTO customers (name) VALUES ('dhuux cisman') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'dhuux cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'dhuux cisman', '2026-09-21', 210.0, 210.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'baanad  ulo weyne ah', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil dheer', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f saliid', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil naafato', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 15.0, 15.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil caqaayad', 1, 15.0, 15.0);
  -- Sale: Walk-in Customer on 2026-09-22
  INSERT INTO customers (name) VALUES ('Walk-in Customer') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Walk-in Customer' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Walk-in Customer', '2026-09-22', 245.0, 245.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'caleen hore', 1, 50.0, 50.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'filter dheer', 1, 20.0, 20.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 25', 1, 110.0, 110.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f saliid gaban', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'fil naafato', 1, 30.0, 30.0);
  -- Sale: hasan ogaal on 2026-09-22
  INSERT INTO customers (name) VALUES ('hasan ogaal') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'hasan ogaal' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'hasan ogaal', '2026-09-22', 21.0, 21.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'haraaqo', 1, 2.0, 2.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'dhiiqo linstop', 1, 7.0, 7.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'shidaal', 1, 12.0, 12.0);
  -- Sale: m case on 2026-09-22
  INSERT INTO customers (name) VALUES ('m case') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'm case' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'm case', '2026-09-22', 175.0, 175.0, 'paid', 'Migrated from Excel Sheet2')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'saliid 30 l', 1, 125.0, 125.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f saliid gaban', 1, 35.0, 35.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'f nafato', 1, 15.0, 15.0);
END $$;

-- ================================================================
-- SHEET 3: Workshop Service Records (Adeega Meherad Dhako Spare Parts)
-- ================================================================
DO $$
DECLARE
  cust_id UUID;
  sale_id UUID;
BEGIN
  -- Service history for Dhuux Cisman's vehicle
  INSERT INTO customers (name, notes) VALUES ('Dhuux Cisman', 'Lacag hayn Cumar Cisman $14000') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Dhuux Cisman' LIMIT 1;
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Dhuux Cisman', '2026-07-01', 0, 0, 'credit', 'Workshop service - Adeega Meherad Dhako Spare Parts. Lacag hayn Cumar Cisman $14000. Sidiiq Cisman $1000 amaah. Magtii Maxamed Abdi Cisman.')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price, notes)
  VALUES (sale_id, 'Rabadh kamaan', 1, 0, 0, '6 xabo | Lacag hayn cumar cisman    $  14000');
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price, notes)
  VALUES (sale_id, 'kiibin', 1, 0, 0, '10 xao | sidiiq cisman      $ 1000 amaah sidiiq ku maqan');
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price, notes)
  VALUES (sale_id, 'buush roum  hore', 1, 0, 0, '10 xabo | 1/7/2026 dhuux');
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price, notes)
  VALUES (sale_id, 'buush roum dambe', 1, 0, 0, '10 xqbo | 2000 hayn cumar cisman');
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price, notes)
  VALUES (sale_id, 'kaanweyso ramoodh dambe', 1, 0, 0, '2 karton | magtii  maxamed abdi cisman');
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price, notes)
  VALUES (sale_id, 'buush jiide ramoodh', 1, 0, 0, '10 xabo | 1000 ayuu bixiyey dhuux');
END $$;

-- ================================================================
-- SHEET 4: Credit Accounts (Amaah Gaashi Gaadhiga Cumar)
-- ================================================================
DO $$
DECLARE
  cust_id UUID;
BEGIN
  INSERT INTO customers (name) VALUES ('AMAAH CUMAR') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'AMAAH CUMAR' LIMIT 1;
  INSERT INTO credit_accounts (customer_id, customer_name_raw, description, amount_owed, status, source_sheet, notes)
  VALUES (cust_id, 'AMAAH CUMAR', '60 caano iyo 200 ali baashe', 0, 'open', 'Sheet4', 'AMAAH GAASHI GAADHIGA CUMAR');
  INSERT INTO customers (name) VALUES ('nasteex') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'nasteex' LIMIT 1;
  INSERT INTO credit_accounts (customer_id, customer_name_raw, description, amount_owed, status, source_sheet, notes)
  VALUES (cust_id, 'nasteex', 'kabaalo 13', 0, 'open', 'Sheet4', 'AMAAH GAASHI GAADHIGA CUMAR');
  INSERT INTO customers (name) VALUES ('baraasado  mohamed siciid') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'baraasado  mohamed siciid' LIMIT 1;
  INSERT INTO credit_accounts (customer_id, customer_name_raw, description, amount_owed, status, source_sheet, notes)
  VALUES (cust_id, 'baraasado  mohamed siciid', '100 doller', 0, 'open', 'Sheet4', 'AMAAH GAASHI GAADHIGA CUMAR');
  INSERT INTO customers (name) VALUES ('khyre 100 sabarad 16/9/2026') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'khyre 100 sabarad 16/9/2026' LIMIT 1;
  INSERT INTO credit_accounts (customer_id, customer_name_raw, description, amount_owed, status, source_sheet, notes)
  VALUES (cust_id, 'khyre 100 sabarad 16/9/2026', '100 doller', 0, 'open', 'Sheet4', 'AMAAH GAASHI GAADHIGA CUMAR');
END $$;

-- ================================================================
-- SHEET 5: Workshop Credit (Amaahda Meharada - Bashiir and Ismaciil)
-- ================================================================
DO $$
DECLARE
  cust_id UUID;
  sale_id UUID;
BEGIN
  INSERT INTO customers (name, notes) VALUES ('Bashiir and Ismaciil', 'Amaahda Meharada') ON CONFLICT DO NOTHING;
  SELECT id INTO cust_id FROM customers WHERE name = 'Bashiir and Ismaciil' LIMIT 1;
  INSERT INTO credit_accounts (customer_id, customer_name_raw, description, amount_owed, status, source_sheet)
  VALUES (cust_id, 'Bashiir and Ismaciil', 'Amaahda Meharada - workshop credit account', 1885, 'open', 'Sheet5');
  INSERT INTO sales (customer_id, customer_name_raw, sale_date, total_amount, amount_paid, payment_status, notes)
  VALUES (cust_id, 'Bashiir and Ismaciil', '2026-09-01', 1885, 0, 'credit', 'Amaahda Meharada - Sheet 5')
  RETURNING id INTO sale_id;
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'bool beerin  6312', 1, 66.0, 105.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysaro bir ah', 1, 42.0, 48.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysaro caag ah', 1, 20.0, 24.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'cidiyo', 1, 39.0, 108.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush afar gees', 1, 17.5, 32.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, '2 dhiif ah', 1, 275.0, 800.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'footari', 1, 35.0, 50.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'canjalad dhiifka weyn', 1, 21.0, 38.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar 10 god le  ah', 1, 7.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar hawsin', 1, 7.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar dhiif 371', 1, 10.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'canjalad dhiifka yar', 1, 22.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lamdado', 1, 30.0, 70.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar', 1, 25.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush afar gees weyn', 1, 22.0, 40.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'geer yar canjalada', 1, 88.0, 160.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'cidi dhiif', 1, 32.0, 70.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar dhiif 371', 1, 25.0, 28.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'weysar hawsin', 1, 7.0, 14.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'boolbeerin geer box', 1, 18.0, 36.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'geer box', 1, 40.0, 80.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'buush afargees candho', 1, 10.0, 24.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'rabadh kirinkiis', 1, 3.0, 28.0);
  INSERT INTO sale_items (sale_id, product_name_raw, quantity, unit_price, total_price)
  VALUES (sale_id, 'lamdad karamsool juundo', 1, 4.0, 8.0);
END $$;

-- END OF MIGRATION 006
