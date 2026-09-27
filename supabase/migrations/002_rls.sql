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
