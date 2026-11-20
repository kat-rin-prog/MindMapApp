-- MindMap fNIRS - per-account session history
-- Run this once in: Supabase Dashboard -> SQL Editor -> New query -> Run
--
-- Every row belongs to the signed-in user. Row Level Security is what stops one
-- account from reading or deleting another account's history, so do not disable it.

create table if not exists public.session_history (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
    timestamp text not null,
    method text not null,
    load text,
    test_type text,
    retention text,
    efficiency text,
    created_at timestamptz not null default now()
);

create index if not exists session_history_user_created_idx
    on public.session_history (user_id, created_at desc);

alter table public.session_history enable row level security;

drop policy if exists "Users read own session history" on public.session_history;
create policy "Users read own session history"
    on public.session_history
    for select
    using (auth.uid() = user_id);

drop policy if exists "Users insert own session history" on public.session_history;
create policy "Users insert own session history"
    on public.session_history
    for insert
    with check (auth.uid() = user_id);

drop policy if exists "Users delete own session history" on public.session_history;
create policy "Users delete own session history"
    on public.session_history
    for delete
    using (auth.uid() = user_id);
