import type { Campaign, Spot } from "./types";
import { FALLBACK_CAMPAIGN, FALLBACK_SPOTS } from "./fallback";

const API_BASE = process.env.API_BASE_URL ?? "http://localhost:8000";
const REVALIDATE_SECONDS = 3600;

async function fetchJson<T>(path: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    next: { revalidate: REVALIDATE_SECONDS },
  });
  if (!res.ok) {
    throw new Error(`API ${res.status}: ${path}`);
  }
  return res.json();
}

export async function getSpots(): Promise<{
  spots: Spot[];
  fromFallback: boolean;
}> {
  try {
    return { spots: await fetchJson<Spot[]>("/api/spots"), fromFallback: false };
  } catch {
    return { spots: FALLBACK_SPOTS, fromFallback: true };
  }
}

export async function getCurrentCampaign(): Promise<{
  campaign: Campaign;
  fromFallback: boolean;
}> {
  try {
    return {
      campaign: await fetchJson<Campaign>("/api/campaigns/current"),
      fromFallback: false,
    };
  } catch {
    return { campaign: FALLBACK_CAMPAIGN, fromFallback: true };
  }
}
