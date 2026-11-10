# Physio Kolkata — Android wrapper project

**App label:** Physio Kolkata  
**Application ID:** `com.physiokolkata.app`  
**Web app:** Original V49 single-page application (kept in `web/index.html`)  
**Wrapper:** Capacitor 7

## এই প্যাকেজে কী আছে
- V49-এর মূল HTML ও Supabase setup SQL
- Capacitor configuration (নাম ও application ID সেট করা)
- আপনার দেওয়া logo থেকে তৈরি 48–1024 px app icon PNG
- HTML-এ থাকা service-worker registration যেন 404 না দেয়, তার জন্য minimal `web/sw.js`

## Windows-এ APK build করার ধাপ

1. Node.js LTS এবং Android Studio ইনস্টল করুন। Android Studio থেকে Android SDK ও একটি SDK Platform ইনস্টল করুন।
2. এই ফোল্ডারটি extract করে PowerShell/Terminal-এ ওই ফোল্ডারে যান।
3. চালান:

   ```powershell
   npm install
   npx cap add android
   npx cap sync android
   npx cap open android
   ```

4. Android Studio-তে Gradle sync শেষ হলে **Build → Build Bundle(s) / APK(s) → Build APK(s)** নির্বাচন করুন।
5. আপনার পাঠানো logo-কে launcher icon করতে Android Studio-তে `android/app/src/main`-এ right-click করে **New → Image Asset** নির্বাচন করুন। `assets/physio-kolkata-512.png` ফাইলটি foreground/source হিসেবে দিন, নাম `ic_launcher` রাখুন, তারপর Finish করে আবার APK build করুন।
6. Debug APK সাধারণত এখানে তৈরি হবে:
   `android/app/build/outputs/apk/debug/app-debug.apk`

## গুরুত্বপূর্ণ
- এই পরিবেশে Android SDK/Gradle platform নেই এবং npm package registry-তে সংযোগ timeout হয়েছে। তাই এখানে installable APK compile করা যায়নি; এই ZIP হলো প্রস্তুত Capacitor wrapper/source project, APK নয়।
- Supabase-এর URL/key এবং authentication configuration আপনার মূল HTML-এর মতোই রাখা হয়েছে। Production release-এর আগে Supabase RLS policies, file permissions, login, PDF upload/download এবং backup Android device-এ পরীক্ষা করুন।
- `V49_SUPABASE_SETUP.sql` ফাইলটি শুধু reference/setup script; এটি স্বয়ংক্রিয়ভাবে database-এ চালানো হয় না।
- iOS project এই প্যাকেজে অন্তর্ভুক্ত নয়।
