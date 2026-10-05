-- RARE WEAR — Supabase production setup
-- Run this entire file in Supabase SQL Editor.
-- Then create your admin user in Authentication > Users and run the profile INSERT shown at the bottom.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'customer' check (role in ('admin','customer')),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  price numeric(10,2) not null default 0 check (price >= 0),
  image_url text,
  description text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  id integer primary key check (id = 1),
  name text not null default 'Rare Wear',
  phone text not null default '6362619930',
  instagram text not null default '_rare__wear_official',
  address text not null default 'Parvathi Nagar, Medahalli, Bangalore 560049',
  banner text not null default 'assets/banner.png',
  updated_at timestamptz not null default now()
);

insert into public.site_settings (id) values (1) on conflict (id) do nothing;

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  phone text not null,
  address text,
  items jsonb not null default '[]'::jsonb,
  total numeric(10,2) not null default 0 check (total >= 0),
  payment_method text not null default 'WhatsApp/COD',
  status text not null default 'new' check (status in ('new','confirmed','printing','ready','shipped','completed','cancelled')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.site_settings enable row level security;
alter table public.orders enable row level security;

-- Helper used by RLS. It checks the signed-in user's role without exposing auth.users.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- Profiles: an authenticated user can see only their own profile. Admins can read profiles.
drop policy if exists "profile self read" on public.profiles;
create policy "profile self read" on public.profiles for select to authenticated using (id = auth.uid() or public.is_admin());
drop policy if exists "admins manage profiles" on public.profiles;
create policy "admins manage profiles" on public.profiles for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Products: storefront can read active products. Admins have full CRUD.
drop policy if exists "public read active products" on public.products;
create policy "public read active products" on public.products for select to anon, authenticated using (active = true or public.is_admin());
drop policy if exists "admins manage products" on public.products;
create policy "admins manage products" on public.products for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Settings: storefront can read the single settings row; only admins can change it.
drop policy if exists "public read site settings" on public.site_settings;
create policy "public read site settings" on public.site_settings for select to anon, authenticated using (id = 1);
drop policy if exists "admins manage site settings" on public.site_settings;
create policy "admins manage site settings" on public.site_settings for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Orders: customers can create orders. Only admins can read/update/delete them.
drop policy if exists "customers create orders" on public.orders;
create policy "customers create orders" on public.orders for insert to anon, authenticated with check (true);
drop policy if exists "admins read orders" on public.orders;
create policy "admins read orders" on public.orders for select to authenticated using (public.is_admin());
drop policy if exists "admins update orders" on public.orders;
create policy "admins update orders" on public.orders for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admins delete orders" on public.orders;
create policy "admins delete orders" on public.orders for delete to authenticated using (public.is_admin());

-- Storage bucket for product and banner images. Public read, admin-only upload/update/delete.
insert into storage.buckets (id,name,public) values ('product-images','product-images',true) on conflict (id) do update set public=true;

drop policy if exists "public read rare wear images" on storage.objects;
create policy "public read rare wear images" on storage.objects for select to public using (bucket_id='product-images');
drop policy if exists "admins upload rare wear images" on storage.objects;
create policy "admins upload rare wear images" on storage.objects for insert to authenticated with check (bucket_id='product-images' and public.is_admin());
drop policy if exists "admins update rare wear images" on storage.objects;
create policy "admins update rare wear images" on storage.objects for update to authenticated using (bucket_id='product-images' and public.is_admin()) with check (bucket_id='product-images' and public.is_admin());
drop policy if exists "admins delete rare wear images" on storage.objects;
create policy "admins delete rare wear images" on storage.objects for delete to authenticated using (bucket_id='product-images' and public.is_admin());

-- Optional starter products. The website also works with local fallback products until you import/add them online.
insert into public.products (name,category,price,image_url,description) values
('Classic T-Shirt','T-Shirts',399,'assets/tshirt.png','Premium custom printed T-shirt.'),
('White Mug','Mugs',199,'assets/white-mug.png','Personalized photo/name mug.'),
('Black Mug','Mugs',249,'assets/black-mug.png','Premium black custom mug.'),
('Magic Mug','Mugs',299,'assets/magic-mug.png','Heat-reveal magic mug.'),
('Blue Mug','Mugs',229,'assets/blue-mug.png','Blue handle personalized mug.'),
('Water Bottle','Bottles',349,'assets/water-bottle.png','Custom printed water bottle.'),
('Marble Tile','Tiles',299,'assets/marble-tile.png','Personalized marble-look tile.'),
('Photo Tile','Tiles',399,'assets/photo-tile.png','Custom photo tile gift.'),
('Caps','Caps',299,'assets/caps.png','Custom printed cap.'),
('Plates','Plates',399,'assets/plates.png','Personalized decorative plate.')
on conflict do nothing;

-- AFTER creating your admin user in Supabase Authentication, replace the UUID below and run:
-- insert into public.profiles (id, role) values ('YOUR-AUTH-USER-UUID','admin')
-- on conflict (id) do update set role='admin';
