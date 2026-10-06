-- 1. TRUNCATE dhammaan miisaska (Tables) si xogta tijaabada ah loo tirtiro
TRUNCATE TABLE 
  sale_items, 
  sales, 
  business_debts, 
  suppliers, 
  credit_accounts, 
  stock_movements, 
  products, 
  customers, 
  categories 
CASCADE;

-- 2. DIB U GALINTA CATEGORIES
INSERT INTO categories (name_so, name_en, description) VALUES
('Saliid / Dacawo', 'Oil & Grease', 'Saliidaha gawaadhida iyo dacawada'),
('Filtarada', 'Filters', 'Saliid filter, hawo filter, iwm.'),
('Shaka Khafis', 'Shock Absorbers', 'Shaka khafiska hore iyo kan dambe'),
('Tuubo', 'Hoses', 'Tuubooyinka biyaha, hawo, iyo shidaalka'),
('Bool / Baanad', 'Bolts & Nuts', 'Boolal iyo baanado kala duwan'),
('Qalab / Tools', 'Tools', 'Furayaal, dhagaxyo, dhanbaraasyo, iwm.'),
('Kiliish / Okiyo', 'Clutch & Glasses', 'Qalabka kiliishka iyo muraayadaha'),
('Koronto / Electrical', 'Electrical', 'Iswiijyo, fiyuus, laydhadh, iwm.'),
('Guud / General', 'General Parts', 'Alaabooyinka guud ee aan qayb gaar ah lahayn');

-- 3. FADLAN KADIB MARKA AAD RUN GARAYSO SCRIPT-GAN, 
-- FUR FILE-KA "006_seed_new_data.sql" EE KU JIRA "supabase/migrations"
-- KADIBNA SOO KOOBIYEE OO HALKAN KU RUN GARAY SI XOGTII EXCEL-KA AY U SOO NOQOTO.
