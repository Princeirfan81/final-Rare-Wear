-- Rare Wear online backend schema for Supabase
create table if not exists public.products (id uuid primary key default gen_random_uuid(), name text not null, category text not null, price numeric(10,2) not null default 0, image_url text, description text, active boolean not null default true, created_at timestamptz not null default now());
create table if not exists public.orders (id uuid primary key default gen_random_uuid(), customer_name text not null, phone text not null, address text, items jsonb not null, total numeric(10,2) not null default 0, payment_method text default 'COD', status text not null default 'new', created_at timestamptz not null default now());
alter table public.products enable row level security; alter table public.orders enable row level security;
create policy "public can view active products" on public.products for select using (active = true);
create policy "authenticated admins manage products" on public.products for all to authenticated using (true) with check (true);
create policy "customers can create orders" on public.orders for insert with check (true);
create policy "authenticated admins view orders" on public.orders for select to authenticated using (true);
create policy "authenticated admins update orders" on public.orders for update to authenticated using (true) with check (true);
-- Storage: create a bucket named product-images in Supabase Storage. Set it public for storefront images.
