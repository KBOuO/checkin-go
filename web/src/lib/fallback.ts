import spotsJson from "@/data/spots.json";
import campaignsJson from "@/data/campaigns.json";
import type { Campaign, Spot } from "./types";

// API 無法連線時的靜態備援內容（與 api/data 種子同步）
export const FALLBACK_SPOTS = spotsJson as Spot[];
export const FALLBACK_CAMPAIGN = campaignsJson[0] as Campaign;
