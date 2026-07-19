const STEPS = [
  {
    step: "01",
    title: "收藏想去的景點",
    body: "瀏覽 12 個精選景點，按下愛心收藏，規劃你的打卡路線。",
    color: "border-cyan-500 text-cyan-600",
  },
  {
    step: "02",
    title: "到現場 GPS 打卡",
    body: "抵達景點後打開打卡趣 App，進入打卡範圍即可蓋下限定印章。",
    color: "border-orange-500 text-orange-600",
  },
  {
    step: "03",
    title: "集滿印章換獎勵",
    body: "集滿 6 枚兌換獎勵，全部蒐集完成再解鎖「環島達人」徽章。",
    color: "border-emerald-500 text-emerald-600",
  },
];

export function HowItWorks() {
  return (
    <section id="how" className="bg-cyan-50/60 py-20">
      <div className="mx-auto max-w-6xl px-4 sm:px-6">
        <h2 className="text-center text-3xl font-black text-cyan-950 sm:text-4xl">
          三步驟，把旅行變成集章遊戲
        </h2>
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {STEPS.map(({ step, title, body, color }) => (
            <div
              key={step}
              className="reveal flex flex-col items-center gap-4 rounded-3xl bg-white p-8 text-center shadow-sm"
            >
              <span
                className={`grid size-16 -rotate-6 place-items-center rounded-full border-4 border-dashed text-2xl font-black ${color}`}
              >
                {step}
              </span>
              <h3 className="text-xl font-bold text-cyan-950">{title}</h3>
              <p className="text-sm leading-relaxed text-cyan-900/70">{body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
