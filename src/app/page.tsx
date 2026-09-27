import { redirect } from 'next/navigation';

export default function Home() {
  // We'll add Supabase auth check here later to redirect to /login if not authenticated
  redirect('/dashboard');
}
