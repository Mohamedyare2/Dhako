-- ==============================================================================
-- SHAQADA CUSUB (NEW FEATURES): Deynta Meheradda & Warbixinta Faa'iidada
-- ==============================================================================

-- 1. Shirkadaha ama Dadka meheradda wax keena (Suppliers)
CREATE TABLE IF NOT EXISTS suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    phone TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Deymaha Meheradda lagu leeyahay (Business Debts / Accounts Payable)
CREATE TABLE IF NOT EXISTS business_debts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    supplier_name_raw TEXT NOT NULL,
    description TEXT,
    amount_owed NUMERIC(12,2) NOT NULL DEFAULT 0,
    amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0,
    status TEXT DEFAULT 'open', -- 'open' (weli lama bixin), 'settled' (waa la bixiyey)
    due_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Security (RLS) - U ogolow Admin-ka iyo Staff-ka inay arkaan, laakiin Admin keliya wax bedeli karo
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_debts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all authenticated users to read suppliers" ON suppliers FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow admins to manage suppliers" ON suppliers FOR ALL TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Allow all authenticated users to read business_debts" ON business_debts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow admins to manage business_debts" ON business_debts FOR ALL TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND role = 'admin')
);
