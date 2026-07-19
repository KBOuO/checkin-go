export function CtaSection() {
  return (
    <section id="cta" className="mx-auto max-w-6xl px-4 pb-24 sm:px-6">
      <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#062a38] via-[#0e7490] to-[#22b8cf] px-6 py-16 text-center text-white sm:px-12">
        <div
          aria-hidden
          className="pointer-events-none absolute -right-10 -top-10 size-40 rotate-12 rounded-full border-4 border-dashed border-white/15"
        />
        <h2 className="text-3xl font-black sm:text-4xl">準備好出發了嗎？</h2>
        <p className="mx-auto mt-4 max-w-xl text-cyan-100">
          先在網頁收藏想去的景點，出發時帶上打卡趣 App——GPS
          打卡蓋章、蒐集你的島嶼印章冊。
        </p>
        <div className="mt-8 flex flex-wrap justify-center gap-4">
          <span
            aria-disabled
            className="cursor-default rounded-2xl border border-white/40 bg-white/10 px-6 py-3 font-bold"
          >
             App Store（即將上架）
          </span>
          <span
            aria-disabled
            className="cursor-default rounded-2xl border border-white/40 bg-white/10 px-6 py-3 font-bold"
          >
            ▶ Google Play（即將上架）
          </span>
        </div>
        <p className="mt-6 text-xs text-cyan-200/70">
          App 開發中——本頁為作品集示範，收藏功能已可在網頁體驗。
        </p>
      </div>
    </section>
  );
}
