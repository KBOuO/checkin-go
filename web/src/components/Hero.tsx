import type { Campaign } from "@/lib/types";

const delay = (ms: number) =>
  ({ "--fade-delay": `${ms}ms` }) as React.CSSProperties;

export function Hero({ campaign }: { campaign: Campaign }) {
  return (
    <section
      id="top"
      className="relative overflow-hidden bg-gradient-to-b from-[#062a38] via-[#0e7490] to-[#22b8cf] text-white"
    >
      {/* 裝飾：印章虛線圓圈 */}
      <div
        aria-hidden
        className="pointer-events-none absolute -left-16 top-12 size-56 rotate-12 rounded-full border-4 border-dashed border-white/15"
      />
      <div
        aria-hidden
        className="pointer-events-none absolute -right-20 bottom-8 size-72 -rotate-6 rounded-full border-4 border-dashed border-orange-300/30"
      />
      <div
        aria-hidden
        className="pointer-events-none absolute right-1/4 top-6 size-24 rotate-45 rounded-full border-2 border-dashed border-white/10"
      />

      <div className="relative mx-auto flex max-w-6xl flex-col items-start gap-6 px-4 py-24 sm:px-6 sm:py-32">
        <span
          style={delay(0)}
          className="animate-fade-up rounded-full border border-orange-300/60 bg-orange-500/20 px-4 py-1 text-sm font-semibold tracking-widest text-orange-200"
        >
          2026 夏季限定活動
        </span>
        <h1
          style={delay(100)}
          className="animate-fade-up text-5xl font-black leading-tight tracking-wide sm:text-7xl"
        >
          {campaign.title}
        </h1>
        <p
          style={delay(200)}
          className="animate-fade-up text-xl font-medium text-cyan-100 sm:text-2xl"
        >
          {campaign.slogan}
        </p>
        <p
          style={delay(300)}
          className="animate-fade-up max-w-xl text-cyan-50/80"
        >
          走訪全台 {campaign.spot_ids.length} 個精選景點，抵達現場完成 GPS
          打卡蒐集限定印章——集滿 {campaign.stamp_goal} 枚，兌換屬於你的夏天。
        </p>
        <div style={delay(400)} className="animate-fade-up mt-2 flex flex-wrap gap-3">
          <a
            href="#spots"
            className="rounded-full bg-orange-500 px-7 py-3 font-bold text-white shadow-lg shadow-orange-900/30 transition hover:bg-orange-400"
          >
            探索 12 個景點
          </a>
          <a
            href="#how"
            className="rounded-full border border-white/40 px-7 py-3 font-bold text-white transition hover:bg-white/10"
          >
            怎麼玩？
          </a>
        </div>
      </div>

      {/* 底部沙灘弧線 */}
      <svg
        aria-hidden
        viewBox="0 0 1440 64"
        className="block w-full text-[#fffdf8]"
        preserveAspectRatio="none"
      >
        <path
          fill="currentColor"
          d="M0 64h1440V32C1200 8 960 0 720 12S240 44 0 24v40z"
        />
      </svg>
    </section>
  );
}
