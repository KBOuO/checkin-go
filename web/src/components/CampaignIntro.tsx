import type { Campaign } from "@/lib/types";
import { Countdown } from "./Countdown";

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString("zh-TW", {
    timeZone: "Asia/Taipei",
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

export function CampaignIntro({ campaign }: { campaign: Campaign }) {
  return (
    <section id="campaign" className="mx-auto max-w-6xl px-4 py-20 sm:px-6">
      <div className="grid items-center gap-10 md:grid-cols-2">
        <div className="flex flex-col gap-5">
          <h2 className="text-3xl font-black text-cyan-950 sm:text-4xl">
            關於「{campaign.title}」
          </h2>
          <p className="leading-relaxed text-cyan-900/80">
            {campaign.description}
          </p>
          <dl className="flex flex-col gap-3 text-sm">
            <div className="flex gap-3">
              <dt className="shrink-0 rounded-md bg-cyan-100 px-2 py-0.5 font-bold text-cyan-800">
                活動期間
              </dt>
              <dd className="text-cyan-900">
                {formatDate(campaign.starts_at)} — {formatDate(campaign.ends_at)}
              </dd>
            </div>
            <div className="flex gap-3">
              <dt className="shrink-0 rounded-md bg-orange-100 px-2 py-0.5 font-bold text-orange-700">
                兌換獎勵
              </dt>
              <dd className="text-cyan-900">{campaign.reward}</dd>
            </div>
            <div className="flex gap-3">
              <dt className="shrink-0 rounded-md bg-emerald-100 px-2 py-0.5 font-bold text-emerald-700">
                達成條件
              </dt>
              <dd className="text-cyan-900">
                集滿 {campaign.stamp_goal} 枚景點印章（共{" "}
                {campaign.spot_ids.length} 枚可蒐集）
              </dd>
            </div>
          </dl>
        </div>
        <div className="rounded-3xl bg-gradient-to-br from-[#083344] to-[#0e7490] p-8 shadow-xl">
          <p className="mb-6 text-center font-bold tracking-widest text-cyan-200">
            距離活動結束還有
          </p>
          <Countdown endsAt={campaign.ends_at} />
        </div>
      </div>
    </section>
  );
}
