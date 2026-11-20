# Open issues — MindMap fNIRS auth + history sync

Project: `https://dofmeimiyobqkaourgfk.supabase.co` (config in `supabase-config.js`)

## 1. Rotate the leaked secret key (high)
An `sb_secret_…` service-role key was pasted into chat. It bypasses RLS and must be
assumed compromised.
Action: Supabase Dashboard → Project Settings → API Keys → Secret keys → rotate, then
revoke the old key. Never place a secret key in `supabase-config.js` or the HTML.

## 2. Email confirmation blocks new accounts
`mailer_autoconfirm: false`: sign-up returns "check your inbox" and the account cannot
sign in until confirmed. Supabase's built-in mailer is rate-limited and often lands in
spam, which will look like broken registration.
Action: either disable Authentication → Providers → Email → Confirm email, or configure
custom SMTP under Authentication → Emails.

## 3. Redirect URLs not registered
Site URL / Redirect URLs must include the page actually being served
(e.g. `http://localhost:5500/MindMapWeb.html` and the production URL), otherwise the
OAuth callback and email-confirmation links return to the wrong place.
Action: Authentication → URL Configuration.

## 4. Auth + history sync not exercised end to end
Verified so far: publishable key is valid (HTTP 200 on `/auth/v1/settings`), the
`session_history` table exists and anon SELECT returns `[]` (RLS active), and the page
boots supabase-js with the header rendering "Sign in".
Not yet verified: sign-up, sign-in, sign-out, the insert on quiz submit, reload of
history after a fresh sign-in, and "Clear Logs" deleting server rows. These need a real
account and email delivery.

## 5. History is only stored when the checkbox is ticked
"Save the sessions history" gates cloud persistence. With it unticked nothing is written
to Supabase, and a session run on one device will not appear on another.
Action: decide whether account history should always be saved when signed in.

## 6. Schema stores scores as text
`retention` and `efficiency` are `text` (e.g. `"80.0%"`), which prevents sorting or
aggregating history in SQL. Change to numeric columns if analysis is needed.
