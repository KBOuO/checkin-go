import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import { Providers } from "@/components/Providers";

// Google Fonts 對 CJK 用 unicode-range 分片下發（我們的文案分散在整個
// CJK Unified 區段，實測仍要載 22 個檔、共 ~1.6MB，FCP 拖到 9 秒以上）。
// 改自架：用 fonttools 依「網站實際出現過的字」重新子集化（見
// scripts/subset-noto-sans-tc.py），5 個字重合計 ~540KB，且不必連
// fonts.gstatic.com（少一次 DNS/TLS）。文案有新增字時要重跑該腳本。
//
// 註：曾試過拆成兩個 localFont()（preload 首屏字重、其餘不 preload）
// 想再壓 Lighthouse 分數，但 next/font/local 的每個 localFont() 呼叫會
// 各自產生獨立的 font-family，拆開後 font-weight 無法在同一家族內跨檔
// 級聯，會讓部分文字掉回退字型——正確性優先於分數，故維持單一宣告。
const notoSansTC = localFont({
  variable: "--font-noto-sans-tc",
  display: "swap",
  src: [
    { path: "./fonts/noto-sans-tc-400.woff2", weight: "400", style: "normal" },
    { path: "./fonts/noto-sans-tc-500.woff2", weight: "500", style: "normal" },
    { path: "./fonts/noto-sans-tc-600.woff2", weight: "600", style: "normal" },
    { path: "./fonts/noto-sans-tc-700.woff2", weight: "700", style: "normal" },
    { path: "./fonts/noto-sans-tc-900.woff2", weight: "900", style: "normal" },
  ],
});

const siteUrl = process.env.SITE_URL ?? "http://localhost:3000";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "打卡趣 CheckinGo｜島嶼打卡季 — 集滿島嶼的印章，換一個夏天的故事",
  description:
    "2026 夏季限定「島嶼打卡季」：走訪全台 12 個精選景點，GPS 打卡蒐集限定印章，集滿 6 枚兌換獎勵。打卡趣 CheckinGo，把旅行變成一場集章遊戲。",
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "zh_TW",
    url: "/",
    siteName: "打卡趣 CheckinGo",
    title: "島嶼打卡季｜打卡趣 CheckinGo",
    description:
      "走訪全台 12 個精選景點，GPS 打卡集章換獎勵——把旅行變成一場集章遊戲。",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="zh-Hant-TW"
      className={`${notoSansTC.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col font-sans">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
