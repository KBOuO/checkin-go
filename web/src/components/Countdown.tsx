"use client";

import { useEffect, useState } from "react";

type Remaining = { d: number; h: number; m: number; s: number } | "ended";

function remainingUntil(endsAt: string): Remaining {
  const diff = new Date(endsAt).getTime() - Date.now();
  if (diff <= 0) return "ended";
  const s = Math.floor(diff / 1000);
  return {
    d: Math.floor(s / 86400),
    h: Math.floor((s % 86400) / 3600),
    m: Math.floor((s % 3600) / 60),
    s: s % 60,
  };
}

export function Countdown({ endsAt }: { endsAt: string }) {
  // 首次 render 固定為 null，避免 SSR 與 client 時間差造成 hydration 不一致
  const [remaining, setRemaining] = useState<Remaining | null>(null);

  useEffect(() => {
    setRemaining(remainingUntil(endsAt));
    const timer = setInterval(() => setRemaining(remainingUntil(endsAt)), 1000);
    return () => clearInterval(timer);
  }, [endsAt]);

  if (remaining === "ended") {
    return (
      <p className="text-center text-lg font-bold text-cyan-100">
        本季活動已結束，敬請期待下一季
      </p>
    );
  }

  const tiles = [
    { label: "天", value: remaining?.d },
    { label: "時", value: remaining?.h },
    { label: "分", value: remaining?.m },
    { label: "秒", value: remaining?.s },
  ];

  return (
    <div role="timer" aria-label="活動倒數" className="flex justify-center gap-3">
      {tiles.map(({ label, value }) => (
        <div key={label} className="flex flex-col items-center gap-1">
          <span className="grid min-w-16 place-items-center rounded-xl bg-white/10 px-3 py-4 text-3xl font-black tabular-nums text-white">
            {value === undefined ? "--" : String(value).padStart(2, "0")}
          </span>
          <span className="text-xs font-medium text-cyan-200">{label}</span>
        </div>
      ))}
    </div>
  );
}
