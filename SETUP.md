# MO AI Website — Setup Guide

## 1. Turning on the signup forms (5 minutes)

The website has two built-in forms — a client enquiry form and a tasker
application form. Right now they work in **fallback mode**: they open
WhatsApp with the details pre-filled, so nothing is ever lost. To make them
submit directly to your inbox instead, connect a form service.

GitHub Pages only serves files — it can't receive form submissions on its
own. A form service handles that part for free.

### DONE — your Formspree endpoint is already connected

Endpoint in use: `https://formspree.io/f/xeajawzq`
It is already pasted into both `companies.html` and `contributors.html`.

**One thing left:** submit a test enquiry on the live site. Formspree asks you
to confirm the recipient address the first time — after that, submissions
arrive automatically at the email on that Formspree form. Make sure that
recipient is set to **hello@moannotation.com** under the form's Settings tab.

Submissions carry a `_replyto` field, so you can hit Reply in your inbox and
it goes straight back to the person who filled the form.

### Reference: how it was set up (Formspree free tier, 50 submissions/month)

1. Go to **formspree.io** and sign up using **hello@moannotation.com**
2. Click **+ New Form**, name it "MO AI Website"
3. Set the recipient email to **hello@moannotation.com**
4. Formspree gives you an endpoint that looks like:
   `https://formspree.io/f/xkgqwerty`
5. Open `index.html`, find this line near the bottom (search for FORM_ENDPOINT):

   ```js
   const FORM_ENDPOINT = "";
   ```

6. Paste your endpoint between the quotes:

   ```js
   const FORM_ENDPOINT = "https://formspree.io/f/xkgqwerty";
   ```

7. Save, re-upload `index.html` to GitHub, done.

Submit a test enquiry through the live site. The first submission asks you to
confirm your email address once — after that they arrive automatically.

### Alternatives

| Service | Free tier | Notes |
|---|---|---|
| Formspree | 50/month | Simplest, recommended |
| Web3Forms | 250/month | No account needed, uses an access key |
| Getform | 50/month | Similar to Formspree |
| Google Forms | Unlimited | Free forever, but you'd embed their form and lose the custom design |

All work the same way — swap the URL into `FORM_ENDPOINT`.

### When you outgrow the free tier

At 50+ enquiries a month, either upgrade Formspree (about $10/month) or move
the form to a **Cloudflare Worker** — you already have a Cloudflare account,
and Workers are free up to 100,000 requests a day. That's a bigger job; worth
doing once volume justifies it.

---

## 2. What happens to a submission

1. Visitor fills the form on moannotation.com
2. Submission is emailed to hello@moannotation.com
3. Success message shows on the page; the form clears
4. If sending fails, the visitor sees a message pointing them to WhatsApp
   and hello@moannotation.com — so a lead is never silently lost

Set up a filter in Zoho Mail so anything with subject "New client enquiry" or
"New tasker application" is labelled and never buried.

---

## 3. Deploying the site

Upload these to your GitHub Pages repo, keeping the folder structure:

```
index.html
assets/og-image.png
assets/favicon.ico
assets/favicon-32.png
assets/favicon-16.png
assets/apple-touch-icon.png
MO_AI_Capability_Deck.pdf
```

Do not change the `assets/` folder name — the link preview image, favicon and
capability deck download all point to it.

---

## 4. Worth doing soon

- **Google Search Console** — submit moannotation.com so the site starts
  appearing in search results
- **Cloudflare Web Analytics** — free, privacy-friendly; shows which pages and
  which posts actually drive enquiries
- **Test on your phone** — submit both forms end to end from mobile before you
  start driving traffic to the site


---

## 5. Turning on contributor accounts (Supabase — free)

The contributors page has a working signup, login, password reset and status
dashboard. It needs a backend to store accounts. Supabase's free tier covers
this comfortably.

1. Go to **supabase.com**, sign up with hello@moannotation.com, create a project
2. In the project, open **Settings → API** and copy:
   - Project URL
   - `anon` public key
3. Open `contributors.html`, find these two lines near the bottom:

   ```js
   const SUPABASE_URL = "";
   const SUPABASE_ANON_KEY = "";
   ```

4. Paste your values in, save, re-upload.

That alone gives you working accounts. To store application stages, also run
this in Supabase's **SQL Editor**:

```sql
create table contributors (
  id uuid primary key references auth.users on delete cascade,
  name text, email text, city text, skill text, device text,
  hours text, experience text,
  stage text default 'Applied',
  created_at timestamptz default now()
);

alter table contributors enable row level security;

create policy "own row read"  on contributors for select using (auth.uid() = id);
create policy "own row write" on contributors for insert with check (auth.uid() = id);
```

Row Level Security means each contributor can only ever read their own record —
important, since this holds personal data.

To move someone along the pipeline, open the table in Supabase and change their
`stage` to Screened, Verified, Assessed, Trained, Signed or Active. They see it
next time they sign in.

**Until you paste those keys:** the signup form emails you instead (via
Formspree, or WhatsApp as a last resort), the Sign in tab is disabled, and a
notice explains that accounts aren't switched on yet. Nobody hits a dead end.

---

## 6. Page structure

```
index.html          Gateway — visitor chooses Company or Contributor
companies.html      Everything client-facing
contributors.html   Everything contributor-facing, incl. accounts
404.html            Branded not-found page
assets/style.css    Shared stylesheet for all pages
```

Upload all of them, plus the `assets/` folder and the capability deck PDF.
