# Rare Wear — Supabase setup

This package is ready for Supabase. Supabase's browser client uses your project URL plus a publishable/anon key; do **not** put a secret/service_role key in the website. citeturn0search1turn0search3

## 1. Create the Supabase project
Create a project in Supabase and open **Project Settings → API**. Copy:
- Project URL
- Publishable key (or legacy anon key)

The site uses `@supabase/supabase-js` from the CDN. Supabase documents this browser setup and email/password Auth flow. citeturn0search0turn0search4

## 2. Run the database setup
Open **SQL Editor** in your Supabase project and run the complete `supabase.sql` file.

It creates:
- `profiles` — admin/customer roles
- `products` — products, prices, photos
- `site_settings` — business information/banner
- `orders` — customer orders
- `product-images` Storage bucket
- RLS policies for public storefront + admin-only management

Supabase recommends Row Level Security when exposing database tables through the client/Data API. citeturn0search8turn0search3

## 3. Create the admin login
In Supabase go to **Authentication → Users → Add user**.

Use your own admin email and a strong password.

Copy the user's UUID.

Then in SQL Editor run:

```sql
insert into public.profiles (id, role)
values ('PASTE-ADMIN-USER-UUID-HERE', 'admin')
on conflict (id) do update set role='admin';
```

The website checks the signed-in user's profile role before showing the dashboard.

## 4. Connect the website
Open `config.js` and fill in:

```js
window.RARE_WEAR_CONFIG = {
  SUPABASE_URL: 'https://YOUR-PROJECT.supabase.co',
  SUPABASE_PUBLISHABLE_KEY: 'YOUR-PUBLISHABLE-KEY',
  SUPABASE_ANON_KEY: ''
};
```

Do not use a `service_role`/secret key in this file.

## 5. Use the admin
Open `admin.html`.

Sign in using the Supabase admin email/password you created.

From the dashboard you can:
- add products
- edit products
- change prices
- upload product photos
- delete/deactivate products
- upload a new banner
- change phone/Instagram/address
- view recent orders
- export a backup

## 6. Put it online
Upload the complete folder to your chosen static host. Keep `index.html`, `admin.html`, `config.js`, `app.js`, `admin.js`, CSS, and `assets/` together.

For a production app using a framework/server, Supabase also provides server-side packages; this ZIP is intentionally a simple static storefront using the browser client. citeturn0search6

## Important security note
The publishable/anon key is intended for client-side use when RLS is correctly configured. Never publish a Supabase secret/service_role key. The included SQL uses RLS and an `is_admin()` role check for admin operations.
