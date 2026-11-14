# Live configuration status (14 Nov 2026)

- The Supabase project `openwave-tv` is created in `ap-south-1` and reports ACTIVE_HEALTHY.
- The SQL schema and RLS policies are installed and security advisors reported no warnings.
- `cloud-config.js` has been connected using the public publishable key. **Do not replace it with a secret key.**
- **One step remains:** create an administrator through [Authentication → Users](https://supabase.com/dashboard/project/xfculbeozbyhaluywala/auth/users). Once created, its UUID can be granted membership in `public.openwave_admins` by an authenticated database administrator. Never publish a user's email or password in the repository.
- The public Global Favourites list is currently empty until the admin publishes the first channel.

---

# OpenWave TV — Global Favourites setup

OpenWave TV now has **My Favourites** (browser-local) and **Global Favourites** (shared worldwide).

The feature is installed in the website but stays inactive until a Supabase project is configured. Existing channels and personal favourites continue to work.

## Configure securely

1. Create a Supabase project at https://supabase.com/dashboard
2. In the **SQL Editor**, run `supabase/openwave-global-favourites.sql`.
3. In **Authentication → Users**, create or invite your administrator email (and set a secure password). Consider disabling public sign-ups under the authentication settings.
4. Copy that user's **UUID** from Authentication → Users.
5. In the SQL Editor run:
   `insert into public.openwave_admins (user_id) values ('YOUR_AUTH_USER_UUID');`
6. In Supabase **Project Settings → API**, copy the **Project URL** and the **publishable (or legacy anon) key**. Never use a secret/service_role key.
7. Edit `cloud-config.js` in this GitHub repository:
   ```javascript
   window.OPENWAVE_CLOUD = Object.freeze({
     url: 'https://YOUR_PROJECT.supabase.co',
     anonKey: 'YOUR_PUBLIC_PUBLISHABLE_OR_ANON_KEY'
   });
   ```
8. Let GitHub Pages deploy and refresh the page. Open **Global Favourites** and select **Admin sign in**. Sign in with your administrator email/password.
9. Select a channel in any normal category and click **Publish globally**. Visitors can then find it in **Global Favourites**.

## Security and behaviour

- Supabase Row Level Security restricts writes to approved admin UUIDs stored in `public.openwave_admins`.
- Public visitors have read-only access to `public.openwave_global_channels`.
- A local favourite never gets published automatically.
- The admin session is stored by the browser; the password is not stored by OpenWave TV.
- The Global Favourites feed reads the Supabase database on refresh / opening the tab.
- `cloud-config.js` contains **public browser credentials only**; no database password or service_role key.
- The app is static and hosted via GitHub Pages; Supabase is responsible for authentication and shared data.
- Stream licensing, regional restrictions and playback compatibility remain the broadcaster's responsibility.
- Review the categories and stream URLs before publishing to everyone.

## Suggested verification

1. In a normal tab, sign in as admin and publish one authorized, publicly available test channel.
2. In an incognito tab (not signed in), confirm the new Global Favourites channel appears and you cannot publish or remove it.
3. In a different browser, confirm personal favourites remain independent.
4. Sign out, then verify editing is no longer available.
5. Confirm an unrelated signed-in user cannot insert, update or delete rows, including by calling the API directly.

If credentials are not configured, the app displays a setup message instead of silently failing.
