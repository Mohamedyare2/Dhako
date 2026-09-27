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
