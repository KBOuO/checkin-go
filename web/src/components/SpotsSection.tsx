import type { Spot } from "@/lib/types";
import { SpotCard } from "./SpotCard";

export function SpotsSection({ spots }: { spots: Spot[] }) {
  return (
    <section id="spots" className="mx-auto max-w-6xl px-4 py-20 sm:px-6">
      <div className="mb-10 flex flex-col gap-2">
        <h2 className="text-3xl font-black text-cyan-950 sm:text-4xl">
          精選景點 × {spots.length}
        </h2>
        <p className="text-cyan-900/70">
          北、中、南、東到離島——每一枚印章，都是一段路上的風景。
        </p>
      </div>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {spots.map((spot, i) => (
          <SpotCard key={spot.id} spot={spot} index={i} />
        ))}
      </div>
    </section>
  );
}
