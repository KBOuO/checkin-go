"use client";

import { useFavorites } from "@/store/favorites";
import { useMounted } from "@/lib/useMounted";

export function SiteHeader() {
  const count = useFavorites((s) => s.ids.length);
  const mounted = useMounted();

  return (
    <header className="sticky top-0 z-50 border-b border-cyan-900/10 bg-[#fffdf8]/80 backdrop-blur">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between px-4 sm:px-6">
        <a href="#top" className="flex items-center gap-2">
          <span className="grid size-8 -rotate-6 place-items-center rounded-full border-2 border-dashed border-orange-500 text-sm font-black text-orange-600">
            趣
          </span>
          <span className="text-lg font-black tracking-wide text-cyan-950">
            打卡趣 <span className="text-cyan-700">CheckinGo</span>
          </span>
        </a>
        <nav className="hidden items-center gap-6 text-sm font-medium text-cyan-900 sm:flex">
          <a href="#campaign" className="hover:text-orange-600">
            活動介紹
          </a>
          <a href="#how" className="hover:text-orange-600">
            怎麼玩
          </a>
          <a href="#spots" className="hover:text-orange-600">
            精選景點
          </a>
        </nav>
        <div className="flex items-center gap-3">
          <span
            className="flex items-center gap-1 text-sm font-semibold text-rose-500"
            aria-label={`已收藏 ${mounted ? count : 0} 個景點`}
          >
            <svg
              viewBox="0 0 24 24"
              fill="currentColor"
              className="size-4"
              aria-hidden
            >
              <path d="M12 21s-6.7-4.3-9.3-8.5C.8 9.2 2.4 5.5 6 5.5c2 0 3.4 1.1 4 2.3.6-1.2 2-2.3 4-2.3 3.6 0 5.2 3.7 3.3 7-2.6 4.2-9.3 8.5-9.3 8.5z" />
            </svg>
            <span className="tabular-nums">{mounted ? count : 0}</span>
          </span>
          <a
            href="#cta"
            className="rounded-full bg-orange-500 px-4 py-1.5 text-sm font-bold text-white shadow-sm transition hover:bg-orange-600"
          >
            下載 App
          </a>
        </div>
      </div>
    </header>
  );
}
