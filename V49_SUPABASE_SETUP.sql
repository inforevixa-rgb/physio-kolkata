-- Physio Kolkata V49: Platform Admin staff visibility and role control
-- Run this complete script once in Supabase SQL Editor while signed in as project owner.

create or replace function public.platform_admin_staff_directory(p_search text default '')
returns table (
  id uuid,
  full_name text,
  role text,
  email text,
  staff_id text,
  designation text,
  mobile_no text,
  is_active boolean
)
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_caller_email text;
  v_caller_role text;
  v_q text := lower(trim(coalesce(p_search, '')));
begin
  select lower(u.email), lower(trim(p.role))
    into v_caller_email, v_caller_role
  from auth.users u
  join public.profiles p on p.id = u.id
  where u.id = auth.uid() and p.is_active = true;

  if coalesce(v_caller_email, '') <> 'info.revixa@gmail.com'
     or coalesce(v_caller_role, '') <> 'admin' then
    raise exception 'Only the active Platform Admin can view the complete staff directory';
  end if;

  return query
  select p.id,
         coalesce(to_jsonb(p)->>'full_name', ''),
         lower(coalesce(to_jsonb(p)->>'role', 'staff')),
         coalesce(u.email, ''),
         coalesce(to_jsonb(p)->>'staff_id', ''),
         coalesce(to_jsonb(p)->>'designation', ''),
         coalesce(to_jsonb(p)->>'mobile_no', ''),
         coalesce((to_jsonb(p)->>'is_active')::boolean, false)
  from public.profiles p
  join auth.users u on u.id = p.id
  where (
    v_q = ''
    or lower(coalesce(to_jsonb(p)->>'full_name','')) like '%'||v_q||'%'
    or lower(coalesce(u.email,'')) like '%'||v_q||'%'
    or lower(coalesce(to_jsonb(p)->>'staff_id','')) like '%'||v_q||'%'
    or lower(coalesce(to_jsonb(p)->>'designation','')) like '%'||v_q||'%'
    or lower(coalesce(to_jsonb(p)->>'mobile_no','')) like '%'||v_q||'%'
    or lower(coalesce(to_jsonb(p)->>'role','')) like '%'||v_q||'%'
  )
  order by case when lower(u.email) = 'info.revixa@gmail.com' then 0 else 1 end,
           lower(coalesce(to_jsonb(p)->>'full_name',''));
end;
$$;

revoke all on function public.platform_admin_staff_directory(text) from public;
grant execute on function public.platform_admin_staff_directory(text) to authenticated;

create or replace function public.platform_admin_set_user_role(p_user_id uuid, p_role text)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_caller_email text;
  v_caller_role text;
  v_target_email text;
  v_new_role text := lower(trim(coalesce(p_role, '')));
begin
  select lower(u.email), lower(trim(p.role))
    into v_caller_email, v_caller_role
  from auth.users u
  join public.profiles p on p.id = u.id
  where u.id = auth.uid() and p.is_active = true;

  if coalesce(v_caller_email, '') <> 'info.revixa@gmail.com'
     or coalesce(v_caller_role, '') <> 'admin' then
    raise exception 'Only the active Platform Admin can change user roles';
  end if;

  if p_user_id is null or p_user_id = auth.uid() then
    raise exception 'Platform Admin cannot change their own role';
  end if;

  if v_new_role not in ('admin', 'staff') then
    raise exception 'Role must be admin or staff';
  end if;

  select lower(email) into v_target_email
  from auth.users where id = p_user_id;

  if v_target_email is null then
    raise exception 'Target user account not found';
  end if;

  if v_target_email = 'info.revixa@gmail.com' then
    raise exception 'Platform Admin account is protected';
  end if;

  update public.profiles
  set role = v_new_role
  where id = p_user_id;

  if not found then
    raise exception 'Target user profile not found';
  end if;

  return jsonb_build_object('success', true, 'user_id', p_user_id, 'email', v_target_email, 'role', v_new_role);
end;
$$;

revoke all on function public.platform_admin_set_user_role(uuid, text) from public;
grant execute on function public.platform_admin_set_user_role(uuid, text) to authenticated;
