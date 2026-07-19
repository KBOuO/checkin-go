"use client";

import { motion } from "framer-motion";
import type { Spot } from "@/lib/types";
import { useFavorites } from "@/store/favorites";
import { useMounted } from "@/lib/useMounted";

const GRADIENTS = [
  "from-cyan-600 to-sky-400",
  "from-orange-500 to-amber-400",
  "from-emerald-600 to-teal-400",
  "from-violet-600 to-fuchsia-400",
];

export function SpotCard({ spot, index }: { spot: Spot; index: number }) {
  const mounted = useMounted();
  const isFavorite = useFavorites((s) => s.ids.includes(spot.id));
  const toggle = useFavorites((s) => s.toggle);
  const fav = mounted && isFavorite;

  return (
    <article className="reveal group overflow-hidden rounded-3xl bg-white shadow-sm ring-1 ring-cyan-900/5 transition hover:shadow-lg">
      <div
        className={`relative flex h-36 flex-col justify-between bg-gradient-to-br p-4 ${GRADIENTS[index % GRADIENTS.length]}`}
      >
        <div className="flex items-start justify-between">
          <span className="rounded-full bg-white/85 px-3 py-0.5 text-xs font-bold text-cyan-900">
            {spot.city}
          </span>
          <span
            aria-hidden
            className="grid size-12 rotate-12 place-items-center rounded-full border-2 border-dashed border-white/70 text-sm font-black text-white/90 transition group-hover:rotate-0"
          >
            {String(index + 1).padStart(2, "0")}
          </span>
        </div>
        <h3 className="text-2xl font-black tracking-wide text-white drop-shadow-sm">
          {spot.name}
        </h3>
      </div>
      <div className="flex flex-col gap-3 p-5">
        <p className="line-clamp-3 text-sm leading-relaxed text-cyan-900/75">
          {spot.description}
        </p>
        <div className="flex items-center justify-between">
          <div className="flex flex-wrap gap-1.5">
            {spot.tags.map((tag) => (
              <span
                key={tag}
                className="rounded-full bg-cyan-50 px-2.5 py-0.5 text-xs font-medium text-cyan-700"
              >
                #{tag}
              </span>
            ))}
          </div>
          <motion.button
            type="button"
            onClick={() => toggle(spot.id)}
            whileTap={{ scale: 0.8 }}
            whileHover={{ scale: 1.1 }}
            aria-pressed={fav}
            aria-label={fav ? `取消收藏${spot.name}` : `收藏${spot.name}`}
            className={`shrink-0 rounded-full p-2 transition-colors hover:bg-rose-50 ${
              fav ? "text-rose-500" : "text-cyan-900/30"
            }`}
          >
            <svg
              viewBox="0 0 24 24"
              fill={fav ? "currentColor" : "none"}
              stroke="currentColor"
              strokeWidth={2}
              strokeLinejoin="round"
              className="size-5"
              aria-hidden
            >
              <path d="M12 21s-6.7-4.3-9.3-8.5C.8 9.2 2.4 5.5 6 5.5c2 0 3.4 1.1 4 2.3.6-1.2 2-2.3 4-2.3 3.6 0 5.2 3.7 3.3 7-2.6 4.2-9.3 8.5-9.3 8.5z" />
            </svg>
          </motion.button>
        </div>
      </div>
    </article>
  );
}
