# Rare Wear — Full Online Store

A mobile-friendly custom printing store for Rare Wear. Includes storefront, cart, WhatsApp ordering, custom enquiry form, and editable admin dashboard.

## Run immediately
Open `index.html` for the storefront. Open `admin.html` for the dashboard.

Local admin mode password: `rare123` (change it before publishing).

Local mode stores products/settings in the browser, so it is useful for testing but is NOT a multi-device online database.

## Make it truly online
1. Create a Supabase project.
2. Run `supabase.sql` in Supabase SQL Editor.
3. Create a public Storage bucket called `product-images` for product photos.
4. Create an admin user in Supabase Authentication.
5. Put the Supabase project URL and anon key into `config.js`.
6. Host this folder on your chosen static host.

## Payments
WhatsApp ordering is ready. For online payments, add your Razorpay/other payment gateway credentials and server-side order verification. Do not put secret payment keys in browser JavaScript.

## Business
Rare Wear
Parvathi Nagar, Medahalli, Bangalore 560049
WhatsApp: 6362619930
Instagram: _rare__wear_official
