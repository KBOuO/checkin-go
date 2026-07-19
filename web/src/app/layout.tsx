import type { Metadata } from "next";
import { Noto_Sans_TC } from "next/font/google";
import "./globals.css";
import { Providers } from "@/components/Providers";

// 不指定 weight → 使用可變字型：單一組切片涵蓋所有字重，
// 比固定 4 個字重省下約 3/4 的字型流量
const notoSansTC = Noto_Sans_TC({
  variable: "--font-noto-sans-tc",
  subsets: ["latin"],
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
