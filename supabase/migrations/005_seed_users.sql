-- Enable pgcrypto for password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Insert Admin and Staff users into auth.users directly for testing
DO $$
DECLARE
    admin_uid UUID := gen_random_uuid();
    staff_uid UUID := gen_random_uuid();
BEGIN
    -- 1. Create Admin User (Email: admin@dhako.com | Password: adminpassword123)
    INSERT INTO auth.users (
        id, 
        instance_id, 
        email, 
        encrypted_password, 
        email_confirmed_at, 
        raw_app_meta_data, 
        raw_user_meta_data, 
        aud, 
        role
    )
    VALUES (
        admin_uid, 
        '00000000-0000-0000-0000-000000000000', 
        'admin@dhako.com', 
        crypt('adminpassword123', gen_salt('bf')), 
        now(), 
        '{"provider":"email","providers":["email"]}', 
        '{"full_name":"Dhako Admin"}', 
        'authenticated', 
        'authenticated'
    );
    
    -- Insert Admin Profile
    INSERT INTO public.profiles (id, full_name, role)
    VALUES (admin_uid, 'Dhako Admin', 'admin');

    -- 2. Create Staff User (Email: staff@dhako.com | Password: staffpassword123)
    INSERT INTO auth.users (
        id, 
        instance_id, 
        email, 
        encrypted_password, 
        email_confirmed_at, 
        raw_app_meta_data, 
        raw_user_meta_data, 
        aud, 
        role
    )
    VALUES (
        staff_uid, 
        '00000000-0000-0000-0000-000000000000', 
        'staff@dhako.com', 
        crypt('staffpassword123', gen_salt('bf')), 
        now(), 
        '{"provider":"email","providers":["email"]}', 
        '{"full_name":"Dhako Staff"}', 
        'authenticated', 
        'authenticated'
    );
    
    -- Insert Staff Profile
    INSERT INTO public.profiles (id, full_name, role)
    VALUES (staff_uid, 'Dhako Staff', 'staff');
END $$;
